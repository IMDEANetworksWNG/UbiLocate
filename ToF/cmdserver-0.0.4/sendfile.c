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
        "sendfile version 0.0.3\n"
        "     Usage: sendfile [hpsrl]\n"
        "                   -h print this message\n"
        "                   -p remote port\n"
        "                   -s remote server\n"
        "                   -r remote file name\n"
        "                   -l local file name\n"
        "\n";
    fprintf(stdout, "%s\n", usage_str);
}

int main(int argc, char *argv[])
{
    int c, retc;
    char *server_string = NULL;
    char *port_string = NULL;
    char *local_file_string = NULL;
    char *remote_file_string = NULL;
    struct sockaddr_in local;
    struct sockaddr_in remote;
    struct hostent* convert;
    int soc = -1;
    FILE *fptr = NULL;
    
#define SERVER_PORT 12000
    int port = SERVER_PORT;
    char *bufferize_filename = NULL;
        
    while ((c = (char) getopt(argc, argv, "hp:s:r:l:")) != EOF) {
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

            case 'l':
                local_file_string = optarg;
                break;

            case 'r':
                remote_file_string = optarg;
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

    // send file name: two bytes for length
    char *cmd_dup = malloc(strlen(remote_file_string) + 4);
    if(cmd_dup == NULL) {
        fprintf(stderr, "Error duplicating commad in memory\n");
        goto outError;
    }
    
    *(uint16_t *) (cmd_dup + 0) = ntohs(T_RFILE);
    *(uint16_t *) (cmd_dup + 2) = ntohs(strlen(remote_file_string));
    strcpy(cmd_dup + 4, remote_file_string);
    retc = send(soc, cmd_dup, strlen(remote_file_string) + 4, 0);
     
    if(retc == -1) {
        fprintf(stderr, "Error sending remote file name\n");
        goto outError;
    }

    fptr = fopen(local_file_string, "rb");
    if(!fptr) {
        fprintf(stderr, "Error accessing local file\n");
        goto outError;
    }

    while(1) {
#define BUFFER_LENGTH 2048
        char *buffer[BUFFER_LENGTH];
        int retc = fread(buffer, 1, BUFFER_LENGTH, fptr);
        if(retc <= 0)
            goto outError;

        send(soc, buffer, retc, 0);
    }
        
  outError:
    if(soc != -1)
        close(soc);
    if(fptr != NULL)
        fclose(fptr);
    
    return -1;
}
