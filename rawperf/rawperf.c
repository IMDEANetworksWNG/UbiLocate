/***************************************************************************
 *                                                                         *
 *          ###########   ###########   ##########    ##########           *
 *         ############  ############  ############  ############          *
 *         ##            ##            ##   ##   ##  ##        ##          *
 *         ##            ##            ##   ##   ##  ##        ##          *
 *         ###########   ####  ######  ##   ##   ##  ##    ######          *
 *          ###########  ####  #       ##   ##   ##  ##    #    #          *
 *                   ##  ##    ######  ##   ##   ##  ##    #    #          *
 *                   ##  ##    #       ##   ##   ##  ##    #    #          *
 *         ############  ##### ######  ##   ##   ##  ##### ######          *
 *         ###########    ###########  ##   ##   ##   ##########           *
 *                                                                         *
 *            S E C U R E   M O B I L E   N E T W O R K I N G              *
 *                                                                         *
 * This file is part of NexMon.                                            *
 *                                                                         *
 * Copyright (c) 2016 NexMon Team                                          *
 *                                                                         *
 * NexMon is free software: you can redistribute it and/or modify          *
 * it under the terms of the GNU General Public License as published by    *
 * the Free Software Foundation, either version 3 of the License, or       *
 * (at your option) any later version.                                     *
 *                                                                         *
 * NexMon is distributed in the hope that it will be useful,               *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           *
 * GNU General Public License for more details.                            *
 *                                                                         *
 * You should have received a copy of the GNU General Public License       *
 * along with NexMon. If not, see <http://www.gnu.org/licenses/>.          *
 *                                                                         *
 **************************************************************************/

#define _XOPEN_SOURCE 700

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <byteswap.h>

#include <sys/time.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <sys/param.h> // for MIN macro

#include <sys/ioctl.h>
#include <arpa/inet.h>
#ifdef BUILD_ON_RPI
#include <types.h> //not sure why it was removed, but it is needed for typedefs like `uint`
#include <linux/if.h>
#else
#include <net/if.h>
#endif
#include <stdbool.h>
#define TYPEDEF_BOOL
#include <errno.h>

#include <wlcnt.h>

#include <nexioctls.h>

#include <typedefs.h>
#include <bcmwifi_channels.h>
#include <b64.h>

#if ANDROID
#include <sys/system_properties.h>
#endif

struct nexio {
    struct ifreq *ifr;
    int sock_rx_ioctl;
    int sock_rx_frame;
    int sock_tx;
};

extern int nex_ioctl(struct nexio *nexio, int cmd, void *buf, int len, bool set);
extern struct nexio *nex_init_ioctl(const char *ifname);
extern struct nexio *nex_init_udp(unsigned int securitycookie, unsigned int txip);
extern struct nexio *nex_init_netlink(void);

char            *ifname = "wlan0";

static char doc[] = "rawperf -- yet another iperf style utility";

void usage() {
    char* usage_str = "rawperf version 0.0.1\n"
        "     Usage: rawperf [ifnth]\n"
        "          -i    name of interface\n"
        "          -f    filename with frame data\n"
        "          -n    number of frames to send\n"
        "          -t    delay in us between frames\n"
        "          -q    number of frames before sending full matrix\n"
        "          -h    prints this message\n";
    
    fprintf(stderr, "%s\n", usage_str);
}


// compute the difference left - right
int compute_delta(struct timeval* left, struct timeval* right) {
    return ((int)(left->tv_sec - right->tv_sec)) * 1000000 + (left->tv_usec - right->tv_usec);
}

int
main(int argc, char **argv)
{
    struct nexio *nexio;
    int ret;
    int buf = 0;

    int c;

    char *delay_string = NULL;
    char *filename_string = NULL;
    char *number_string = NULL;
    char *fullmatrixevery_string = NULL;

    while ((c = getopt (argc, argv, "hq:i:f:n:t:")) != EOF) {
        switch (c) {
            case 'i':
                ifname = optarg;
                break;

            case 'f':
                filename_string = optarg;
                break;

            case 'n':
                number_string = optarg;
                break;

            case 't':
                delay_string = optarg;
                break;

            case 'q':
                fullmatrixevery_string = optarg;
                break;

            case 'h':
                usage();
                return 0;
        }
    }

    int repeat = 0;
    if (number_string != NULL) {
        repeat = strtol (number_string, NULL, 0);
    }

    int delay_set_by_user = 0;
    if (delay_string != NULL) {
        delay_set_by_user = strtol (delay_string, NULL, 0);
    }

    int fullmatrixevery = 0;
    if (fullmatrixevery_string != NULL) {
        fullmatrixevery = strtol (fullmatrixevery_string, NULL, 0);
    }

    if (filename_string == NULL) {
        fprintf (stderr, "Missing filename, terminating\n");
        return 1;
    }

    FILE *fptr = fopen (filename_string, "rb");
    if (!fptr) {
        fprintf (stderr, "Cannot open file for reading, terminating\n");
        return 1;
    }
    fseek(fptr, 0, SEEK_END);
    unsigned int fsize = (unsigned int) ftell(fptr);

    char *buffer = (char *) malloc (fsize);
    if (!buffer) {
        fprintf (stderr, "Cannot allocate memory for this frame, terminating\n");
        fclose (fptr);
        return 1;
    }
    fseek(fptr, 0, SEEK_SET);
    fread(buffer, sizeof(unsigned char), fsize, fptr);
    fclose(fptr);
    
#ifdef USE_NETLINK
    nexio = nex_init_netlink();
#else
    nexio = nex_init_ioctl(ifname);
#endif

    int adjust = 0;
    int delay = 0;
    struct timeval now;
    struct timeval last_packet_time;
    gettimeofday(&last_packet_time, NULL);

#define	HYST_TOP 20
#define	HYST_BOTTOM 10
    int doing_hyst = 0;
    int before_full_matrix = fullmatrixevery;
    int times_entered_hyst = 0;
    int every_now_and_then = 100;
    for (unsigned int r = 0; r < repeat; r++) {
        gettimeofday(&now, NULL);
        adjust = delay_set_by_user + compute_delta( &last_packet_time, &now );
        last_packet_time = now;
        if ( adjust > 0  ||  delay > 0 ) {
            delay += adjust;
        }
        if (!doing_hyst) {
            char *rate = ((char*) buffer) + 4;
            rate[0] = 0x10;
            if (fullmatrixevery) {
                if (before_full_matrix == 0) {
                    rate[0] = 0x40;
                    before_full_matrix = fullmatrixevery;
                }
                before_full_matrix --;
            }
            ret = nex_ioctl(nexio, 529, buffer, fsize, true);
        } else {
            ret = nex_ioctl(nexio, 530, buffer, fsize, true);
        }

        every_now_and_then --;
        if (every_now_and_then == 0) {
       	    every_now_and_then = 100;
            fprintf (stdout, "Entered hyst = %d\n", times_entered_hyst);
        }
        
        int queuelength = * (int *) (buffer);
        if (doing_hyst == 0 && queuelength > HYST_TOP) {
            // fprintf (stdout, "Entering hysteresis\n");
            doing_hyst = 1;
            times_entered_hyst ++;
        }
        if (doing_hyst == 1 && queuelength <HYST_BOTTOM) {
            // fprintf (stdout, "Exiting hysteresis\n");
            doing_hyst = 0;
        }
        // fprintf (stdout, "%d\n", queuelength);
        if( delay > 0 ) {
            usleep(delay);
        }
    }
    return 0;
}
