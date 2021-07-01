#include <stdio.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <errno.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <sys/stat.h>

#include "types.h"

void usage() 
{
    char *usage_str =
        "cmdserver version 0.0.4\n"
        "     Usage: cmdserver [hp]\n"
        "                   -h print this message\n"
        "                   -p remote port\n"
        "\n";
    fprintf(stdout, "%s\n", usage_str);
}

void killer(int num)
{
    sigset_t set, oldset;
    pid_t pid;
    int status, exitstatus;

    sigemptyset(&set);
    sigaddset(&set, SIGCHLD);
    sigprocmask(SIG_BLOCK, &set, &oldset);

    while( (pid = waitpid((pid_t) -1, &status, WNOHANG))>0) {
        if(WIFEXITED(status)) {
            exitstatus = WEXITSTATUS(status);
            fprintf(stderr,
                    "Child process exited, pid=%d, exit status=%d\n",
                    (int)pid, exitstatus);
        }
        else if(WIFSIGNALED(status)) {
            exitstatus = WTERMSIG(status);
            fprintf(stderr,
                    "Child process terminated by signal %d, pid = %d\n",
                    exitstatus, (int) pid);
        }
        else if(WIFSTOPPED(status)) {
            exitstatus = WSTOPSIG(status);
            fprintf(stderr,
                    "Child process stopped by signal %d, pid = %d\n",
                    exitstatus, (int) pid);
        }
        else {
            fprintf(stderr,
                    "Child process misteriously dead, pid = %d\n",
                    (int) pid);
        }
    }

    signal(SIGCHLD, killer);
    sigemptyset(&set);
    sigaddset(&set, SIGCHLD);
    sigprocmask(SIG_UNBLOCK, &set, &oldset);
}

int daemonize()
{
    int fd;
    
    switch (fork()) {
        case -1:
            fprintf(stdout, "Error in fork\n");
            return (-1);
        case 0:
            break;
        default:
            exit(-1);
    }
    
    if(setsid() == -1) {
        fprintf(stdout, "Error in setsid\n");
        return -1;
    }

    if((fd = open("/dev/null", O_RDWR, 0)) != -1) {
        (void)dup2(fd, STDIN_FILENO);
        (void)dup2(fd, STDOUT_FILENO);
        (void)dup2(fd, STDERR_FILENO);
        if(fd > STDERR_FILENO)
            (void)close(fd);
    }
    return 0;
}

int main(int argc, char *argv[])
{
    int c, retc;
    char *port_string = NULL;
    int soc = -1;
    struct sockaddr_in local;
    
#define SERVER_PORT 12000
    int port = SERVER_PORT;

    if(signal(SIGCHLD, killer) == SIG_ERR) {
        fprintf(stderr, "Error: %s\n", strerror(errno));
        goto outError;
    }
    
    while ((c = getopt(argc, argv, "hp:")) != EOF) {
        switch(c) {
            case 'h':
                usage();
                goto outError;

            case 'p':
                port_string = optarg;
                break;

            default:
                goto outError;
        }
    }

    if(port_string != NULL) {
        port = atoi(port_string);
        if(port < 0 || port > 65535) {
            fprintf(stderr, "Invalid server port\n");
            goto outError;
        }
    }

    if (daemonize() < 0) {
        fprintf(stderr, "Failed to daemonize: %s\n", strerror(errno));
        goto outError;
    }

    local.sin_family = PF_INET;
    local.sin_port = htons((short) port);
    local.sin_addr.s_addr = INADDR_ANY;

    soc = socket(PF_INET, SOCK_STREAM, 0);
    if( soc == -1 ) {
        fprintf(stderr, "Cannot create socket\n");
        goto outError;
    }

    int val = 1;
    if(setsockopt(soc, SOL_SOCKET, SO_REUSEADDR, &val, sizeof(val)) == -1) {
        fprintf(stderr, "Cannot set socket option: %s\n", strerror(errno));
        goto outError;
    }

    if(bind(soc, (struct sockaddr*) &local, sizeof(local)) == -1) {
        fprintf(stderr, "Cannot bind socket\n");
        goto outError;
    }

    if( (retc = listen(soc, 1)) == -1) {
        fprintf(stderr, "Error during listen\n");
        close(soc);
        goto outError;
    }

    while(1) {
        struct sockaddr_in remote;
        socklen_t remsize = sizeof(remote);
        int connectsoc = -1;
        
        if( (retc = connectsoc = accept(soc, (struct sockaddr *) &remote, &remsize)) == -1) {
            fprintf(stderr,"Error in accpt\n");
            break;
        }
          
        int pid = fork();
      
        if( !pid ) {

            fprintf(stdout, "Connected [%s,%u] -> %u\n",
                    inet_ntoa(remote.sin_addr),
                    (unsigned int) ntohs(remote.sin_port),
                    (unsigned int) ntohs(local.sin_port));

            // grab first four bytes:
            // [0-1] encode types, 0 command, 1 path to save file
            // [2-3] length of command or file name
#define INIT_BUFFER_LENGTH 4
            char initbuffer[INIT_BUFFER_LENGTH];
            int to_read = 4;
            int offset = 0;
            char *varbuffer = NULL;
            type_t type;
            int len, retc;
            FILE *fptr = NULL;

            while(to_read > 0) {
                retc = read(connectsoc, initbuffer + offset, to_read);
                if(retc == -1) {
                    fprintf(stderr, "Receive error or unexpected termination: %s\n", strerror(errno));
                    goto terminate;
                }
                to_read -= retc;
                offset += retc;
            }

            type = (type_t) ntohs(*(uint16_t*) initbuffer);
            len = ntohs(*(uint16_t*) (initbuffer + 2));
            fprintf(stdout, "type = %d, len = %d\n", (int) type, len);
            
            varbuffer = malloc(len + 1);
            if(varbuffer == NULL) {
                fprintf(stderr, "Cannot allocate memory for temp buffer\n");
                goto terminate;
            }

            // now try to drain the requested number of bytes
            to_read = len;
            offset = 0;
            
            while(to_read > 0) {
                retc = read(connectsoc, varbuffer + offset, to_read);
                if(retc == -1) {
                    fprintf(stderr, "Receive error or unexpected termination: %s\n", strerror(errno));
                    goto terminate;
                }
                to_read -= retc;
                offset += retc;
            }
            varbuffer[len] = 0;

            if(type == T_TFILE && len > 0) {

                chunk ck;
                
                fptr = fopen(varbuffer, "rb");
                if(!fptr) {
                    char errmsg[] = "Can not open file for reading\n";
                    ck.type = C_MSG;
                    snprintf(ck.data, CHUNK_DATA_SIZE, "%s", errmsg);
                    ck.len = strlen(ck.data);
                    fprintf(stderr, "%s", errmsg);
                    send(connectsoc, &ck, sizeof(ck), 0);
                    goto terminate;
                }

                int running = 1;

                while(running) {
                    int byteread = fread(ck.data, 1, CHUNK_DATA_SIZE, fptr);
                    ck.len = 0;
                    if(byteread > 0) {
                        ck.type = C_DATA;
                        ck.len = byteread;
                    }
                    else {
                        if(feof(fptr))
                            running = 0;
                            
                        else if(ferror(fptr)) {
                            char errmsg[] = "Error during read\n";
                            ck.type = C_MSG;
                            snprintf(ck.data, CHUNK_DATA_SIZE, "%s", errmsg);
                            fprintf(stderr, "%s", errmsg);
                            ck.len = strlen(ck.data);
                            running = 0;
                        }
                    }
                    if(ck.len > 0)
                        send(connectsoc, &ck, sizeof(ck), 0);
                }
                
                goto terminate;
            }
            
            if(type == T_RFILE && len > 0) {
                
                fptr = fopen(varbuffer, "wb");
                if(!fptr) {
                    char errmsg[] = "Can not open file for writing\n";
                    fprintf(stderr, "%s", errmsg);
                    send(connectsoc, errmsg, strlen(errmsg), 0);
                    goto terminate;
                }
                
                while(1) {
#define BUFFER_LENGTH 2048
                    char buffer[BUFFER_LENGTH];
                    retc = read(connectsoc, buffer, BUFFER_LENGTH);

                    if(retc == -1) {
                        char errmsg[] = "Error during read\n";
                        fprintf(stderr, "%s", errmsg);
                        send(connectsoc, errmsg, strlen(errmsg), 0);
                        goto terminate;
                    }

                    if(retc == 0)
                        break;

                    if(fwrite(buffer, 1, retc, fptr) < retc) {
                        char errmsg[] = "Error during write\n";
                        fprintf(stderr, "%s", errmsg);
                        send(connectsoc, errmsg, strlen(errmsg), 0);
                        goto terminate;
                    }
                }
                
                goto terminate;
            }
            
            if(type == T_COMMAND && len > 0) {

#define MAX_PARS 128
                char *args[MAX_PARS];
                int _read_fd[2] = {-1, -1};
                int _write_fd[2] = {-1, -1};
                char *start_buffer = varbuffer;
                int par = 0;

                // if a shell is available then start the command using it
                struct stat shellstat;
#define CMDPATH "/bin/bash"
                int ret = stat(CMDPATH, &shellstat);
                if(ret == 0 && ((shellstat.st_mode & S_IXUSR) != 0)) {
                    args[0] = CMDPATH;
                    args[1] = "-c";
                    args[2] = start_buffer;
                    args[3] = NULL;
                }
                else {
                    char *token;

                    while( (token = strsep(&start_buffer, " ")) != NULL && par < MAX_PARS) {
                        if( (int) strlen(token) != 0) {
                            args[par] = token;
                            par++;
                        }
                    }
                    args[par] = NULL;
                
                    if(par == MAX_PARS) {
                        fprintf(stderr, "Too many parameters in the command, failure\n");
                        goto exitFinal;
                    }
                }
                
                int kk;
                for(kk = 0; kk < par; kk++)
                    printf("token %d, len = %d: %s\n", kk, (int) strlen(args[kk]), args[kk]);

                if(socketpair(AF_UNIX, SOCK_STREAM, 0, _write_fd) < 0 ||
                   socketpair(AF_UNIX, SOCK_STREAM, 0, _read_fd) < 0) {
                    fprintf(stderr, "Error on socket\n");
                    goto exitFinal;
                }

                int pid2;
                
                if( ! (pid2 = fork()) ) {
                    close(soc);
                    close(connectsoc); // to be checked
                    dup2(_read_fd[1] ,STDOUT_FILENO);
                    dup2(_read_fd[1] ,STDERR_FILENO);
                    dup2(_write_fd[1],STDIN_FILENO);
                    close(_read_fd[0]);
                    close(_read_fd[1]);
                    close(_write_fd[0]);
                    close(_write_fd[1]);
                    execvp(args[0], args);
                    fprintf(stderr, "Error: %s\n", strerror(errno));
                    return -1;
                }

                close(_read_fd[1]);
                close(_write_fd[1]);

                char buffer[2048];

                while(1) {
                    int retc = read(_read_fd[0], buffer, 2048);
                    if(retc == -1) {
                        fprintf(stderr, "Error: %s\n", strerror(errno));
                        goto exitFinal;
                    }
                    if(retc == 0) break;
                    retc = send(connectsoc, buffer, retc, 0);
                    if(retc == -1) {
                        fprintf(stderr, "Error in sending back to client\n");
                        goto exitFinal;
                    }
                }
              exitFinal:
                close(_write_fd[0]);
                close(_read_fd[0]);
            }
            
          terminate:
            close(connectsoc);
            if(varbuffer != NULL)
                free(varbuffer);
            if(fptr != NULL)
                fclose(fptr);

            exit(-1);
        }
        
        close(connectsoc);
        fprintf(stdout, "Waiting a new one\n");
    }
    
    return 0;

  outError:
    return -1;
    
}
