all: cmdserver sendcmd sendfile receivefile

cmdserver: cmdserver.o
	$(CC) $(LDFLAGS) -o cmdserver cmdserver.o

sendcmd: sendcmd.o
	$(CC) $(LDFLAGS) -o sendcmd sendcmd.o

sendfile: sendfile.o
	$(CC) $(LDFLAGS) -o sendfile sendfile.o

receivefile: receivefile.o
	$(CC) $(LDFLAGS) -o receivefile receivefile.o

cmdserver.o: cmdserver.c
	$(CC) $(CFLAGS) -c cmdserver.c

sendcmd.o: sendcmd.c
	$(CC) $(CFLAGS) -c sendcmd.c

sendfile.o: sendfile.c
	$(CC) $(CFLAGS) -c sendfile.c

receivefile.o: receivefile.c
	$(CC) $(CFLAGS) -c receivefile.c

clean:
	rm -rf cmdserver sendcmd sendfile receivefile *.o
