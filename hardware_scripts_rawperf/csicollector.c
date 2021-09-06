#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <pcap/pcap.h>
#include <stdint.h>

#define DEFAULT_PORT 10000
#define MAX_SENDER 20
#define BUF_LEN 2000
#define PACKET_MAX_LENGTH 65536
#define TIMESTAMP_LENGTH 8
#define CRC_LEN 4
#define UDP_HEADER_LENGTH 8

#define noDEBUG

char udp_buffer[BUF_LEN];
char pkt_buffer[BUF_LEN + 28 + 4];

void usage() {
    char* usage_str = "csicollector version 0.0.1\n"
        "     Usage: csicollector [ph]\n"
        "          -p    port to send udp packet\n"
        "          -h    prints this message\n";

    fprintf(stderr, "%s\n", usage_str);
}

typedef struct sender {
    struct in_addr src;
    pcap_dumper_t* writefile;
    pcap_t* output_pcap;
} sender_t;

sender_t senders_data [MAX_SENDER];
int senders = 0;

int main(int argc, char *argv [])
{
    int c;
    char *port_string = NULL;
    char *check;
    int port;
    int soc;
    struct sockaddr_in local;
    struct sockaddr_in remote;

    while ((c = getopt (argc, argv, "p:h")) != EOF) {
        switch (c) {
            case 'p':
                port_string = optarg;
                break;

            case 'h':
                usage();
                return 0;
        }
    }

    if (port_string == NULL) {
        port = DEFAULT_PORT;
    } else {
        port = strtol (port_string, &check, 10);
        if ((char) *check || port < 1 || port > 65535) {
            fprintf (stderr, "Invalid port: %s\n", port_string);
            return 1;
        }
    }
 
    soc = socket (PF_INET, SOCK_DGRAM, 0);
    if (soc == -1) {
        fprintf (stderr, "Cannot create socket\n");
        return 1;
    }
    local.sin_family = PF_INET;
    local.sin_port = htons ((short) port);
    local.sin_addr.s_addr = htonl (INADDR_ANY);
    if (bind (soc, (struct sockaddr*) &local, sizeof (local)) == -1) {
        perror ("Error binding socket");
        close(soc);
        return 1;
    }

    while (1) {
        int udp_buffer_length;
        int longAdr;
        longAdr = sizeof (remote);
        udp_buffer_length = recvfrom (soc, udp_buffer, BUF_LEN, 0, (struct sockaddr*) &remote, &longAdr);

        if (udp_buffer_length == -1)
            break;

        int kk;
        for (kk = 0; kk < senders; kk ++) {
            if (senders_data [kk].src.s_addr == remote.sin_addr.s_addr) {
#ifdef DEBUG
                fprintf (stdout, "found sender %d\n", kk);
#endif // DEBUG
                break;
            }
        }

        if (kk == senders) {
            if (senders == MAX_SENDER) {
                fprintf (stderr, "Maximum number of senders reached, cannot add this one\n");
                continue;
            }

            char writefile_string [255];
            snprintf (writefile_string, 255, "trace%s.pcap", inet_ntoa(remote.sin_addr)); 
            senders_data [kk].src = remote.sin_addr;
            senders_data [kk].output_pcap = pcap_open_dead (DLT_EN10MB, PACKET_MAX_LENGTH);
            if (senders_data [kk].output_pcap == NULL) {
                fprintf (stderr, "Error when adding new output_pcap\n");
                return 1;
            }
            senders_data [kk].writefile =
                pcap_dump_open(senders_data [kk].output_pcap,
                               writefile_string);
            if (senders_data [kk].writefile == NULL) {
                fprintf (stderr, "Error when adding new writefile\n");
                return 1;
            }
            senders ++;
#ifdef DEBUG
            fprintf (stdout, "sender = %d\n", senders);
#endif // DEBUG

        }
        int tv_sec = * (int *) (udp_buffer);
        int tv_usec  = * (int *) (udp_buffer + 4);

        uint8_t mac_header [] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
                                 0x4e, 0x45, 0x58, 0x4d, 0x4f, 0x4e,
                                 0x08, 0x00};
        uint8_t ip_header [] = {0x45, 0x00, 0x04, 0xae, 0x00, 0x00, 0x40, 0x00, 0x40, 0x11,
                                0x22, 0x2c, 0x0a, 0x0a, 0x0a, 0x0a, 0xff, 0xff, 0xff, 0xff};
        uint8_t udp_header [] = {0x15, 0x7c, 0x15, 0x7c, 0x00, 0x00, 0x00, 0x00};
        * (short *) (udp_header + 4) = htons (UDP_HEADER_LENGTH + udp_buffer_length - TIMESTAMP_LENGTH);

        char *pkt_head = pkt_buffer;
        memcpy (pkt_head, mac_header, sizeof (mac_header));
        pkt_head = pkt_head + sizeof (mac_header);
        memcpy (pkt_head, ip_header, sizeof (ip_header));
        pkt_head = pkt_head + sizeof (ip_header);
        memcpy (pkt_head, udp_header, sizeof (udp_header));
        pkt_head = pkt_head + sizeof (udp_header);
        memcpy (pkt_head, udp_buffer + TIMESTAMP_LENGTH, udp_buffer_length - TIMESTAMP_LENGTH);
        pkt_head = pkt_head + udp_buffer_length - TIMESTAMP_LENGTH;
        memset (pkt_head, 0, CRC_LEN);

        struct pcap_pkthdr pkt;
        struct timeval ts;
        ts.tv_sec = tv_sec;
        ts.tv_usec = tv_usec;
        pkt.ts = ts;
        pkt.caplen = sizeof (mac_header) +
                     sizeof (ip_header) +
                     sizeof (udp_header) +
                     udp_buffer_length - TIMESTAMP_LENGTH +
                     CRC_LEN;
        pkt.len = pkt.caplen;
        pcap_dump ((u_char*) senders_data [kk].writefile, &pkt, pkt_buffer);
        pcap_dump_flush (senders_data [kk].writefile);
#ifdef DEBUG
        fprintf (stdout, "received %03d byte(s) from [%s,%u]: ",
      	       udp_buffer_length,
      	       inet_ntoa(remote.sin_addr),
      	       ntohs(remote.sin_port));
        fprintf (stdout, "%d\n", pkt.len);
#endif // DEBUG
    }

    return 0;
}
