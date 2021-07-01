#include <stdio.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdint.h>
#include <sys/file.h>

#include "types.h"

void usage() 
{
    char *usage_str =
        "sendcmd version 0.0.3\n"
        "     Usage: sendcmd [hpsbc]\n"
        "                   -h print this message\n"
        "                   -p remote port\n"
        "                   -s remote server\n"
        "                   -b file name\n"
        "                   -c \"command to execute\"\n"
        "\n";
    fprintf(stdout, "%s\n", usage_str);
}

int main(int argc, char *argv[])
{
    int c, retc;
    char *server_string = NULL;
    char *port_string = NULL;
    char *command_string = NULL;
    struct sockaddr_in local;
    struct sockaddr_in remote;
    struct hostent* convert;
    int soc = -1;
    
#define SERVER_PORT 12000
    int port = SERVER_PORT;
    char *bufferize_filename = NULL;
        
    while ((c = (char) getopt(argc, argv, "hp:s:c:b:")) != EOF) {
        switch(c) {
            case 'h':
                usage();
                goto outError;

            case 'p':
                port_string = optarg;
                break;

            case 's':
                server_string = optarg;
                break;

            case 'c':
                command_string = optarg;
                break;

            case 'b':
                bufferize_filename = optarg;
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

    if(server_string == NULL ||
       (convert = gethostbyname(server_string)) == NULL) {
        fprintf(stderr, "Invalid server\n");
        goto outError;
    }
    
    remote.sin_family = AF_INET;
    remote.sin_port = htons((short) port);
    remote.sin_addr = *(struct in_addr*) convert->h_addr_list[0];

    soc = socket(PF_INET, SOCK_STREAM, 0);
    if( soc == -1 ) {
        fprintf(stderr, "Cannot create socket\n");
        goto outError;
    }

    local.sin_family = AF_INET;
    local.sin_port = htons(0);
    local.sin_addr.s_addr = htonl(INADDR_ANY);

#define MAX_FILENAME 128
    int cnt = 0;
    char fnamecnt[MAX_FILENAME];
    FILE *fptrsem = NULL;
    if(bufferize_filename != NULL) {
        if(snprintf(fnamecnt, MAX_FILENAME, "%s.cnt", bufferize_filename) >= MAX_FILENAME) {
            fprintf(stderr, "Filename too long\n");
            goto outError;
        }
        char fnamesem[MAX_FILENAME];
        if(snprintf(fnamesem, MAX_FILENAME, "sendcmd%s.sem", bufferize_filename) >= MAX_FILENAME) {
            fprintf(stderr, "Filename too long\n");
            goto outError;
        }
        fptrsem = fopen(fnamesem, "wt");
        if(!fptrsem) {
            fprintf(stderr, "Cannot open semaphore file\n");
            goto outError;
        }
        int fdsem = fileno(fptrsem);
        int locksem = flock(fdsem, LOCK_EX|LOCK_NB);
        if(locksem != 0) {
            fprintf(stderr, "Cannot lock: %s\n", strerror(errno));
            fclose(fptrsem);
            goto outError;
        }
        
        FILE *fptrcnt = fopen(fnamecnt, "rt");
        if(fptrcnt) {
            char buffer[2048];
            char *retc = fgets(buffer, sizeof(buffer), fptrcnt);
            if(ferror(fptrcnt)) {
                fprintf(stderr, "Error during reading: %s\n", strerror(errno));
                fclose(fptrcnt);
                fclose(fptrsem);
                goto outError;
            }
            if(retc != NULL) {
                cnt = atoi(buffer); 
            } else {
                cnt = 0;
            }
            fclose(fptrcnt);
        }
    }
    
    if( bind(soc, (struct sockaddr*) &local, sizeof(local)) == -1 ) {
        close(soc);
        fprintf(stderr, "Cannot bind socket\n");
        goto outError;
    }

    if( connect(soc, (struct sockaddr*)&remote, sizeof(remote)) < 0 ) {
        close(soc);
        fprintf(stderr, "Cannot connect to remote server\n");
        goto outError;
    }

    // send command: two bytes for length
    char *cmd_dup = malloc(strlen(command_string) + 4);
    if(cmd_dup == NULL) {
        fprintf(stderr, "Error duplicating commad in memory\n");
        goto outError;
    }
    
    *(uint16_t *) (cmd_dup + 0) = htons(T_COMMAND);
    *(uint16_t *) (cmd_dup + 2) = htons(strlen(command_string));
    strcpy(cmd_dup + 4, command_string);
    retc = send(soc, cmd_dup, strlen(command_string) + 4, 0);
     
    if(retc == -1) {
        fprintf(stderr, "Error sending command\n");
        goto outError;
    }

    while(1) {
        cnt++;

        // now wait for response
#define BUFFER_LENGTH 2048
        char buffer[BUFFER_LENGTH + 1];

        retc = read(soc, buffer, BUFFER_LENGTH);

        if(retc == -1) {
            fprintf(stderr, "Error: %s\n", strerror(errno));
            close(soc);
            goto outError;
        }
        
        if(retc == 0) break;

        buffer[retc] = 0;
        printf("%s", buffer);

        if(bufferize_filename != NULL) {
            char fname[MAX_FILENAME];
            if(snprintf(fname, MAX_FILENAME, "%s%d", bufferize_filename, cnt) >= MAX_FILENAME) {
                fprintf(stderr, "Filename too long\n");
                goto outError;
            }

            FILE *fptr = fopen(fname, "wt");
            if(fptr == NULL) {
                fprintf(stderr, "Can't write-open file: %s\n",
                        strerror(errno));
                goto outError;
            }
            int fd = fileno(fptr);
            int lock = flock(fd, LOCK_EX|LOCK_NB);
            if(lock != 0) {
                fprintf(stderr, "Cannot lock: %s\n", strerror(errno));
            }
            else {
                fprintf(fptr, "%s", buffer);
            }
            fclose(fptr);

            FILE *fptrcnt = fopen(fnamecnt, "wt");
            if(!fptrcnt) {
                fprintf(stderr, "Cannot open counter for writing\n");
                fclose(fptrsem);
                goto outError;
            }
            fprintf(fptrcnt, "%d\n", cnt);
        }
    }
 
    if(fptrsem != NULL)
        fclose(fptrsem);
    
    close(soc);
    return 0;
    
  outError:
    return -1;
}
