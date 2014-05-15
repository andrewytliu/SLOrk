// host name and port
["localhost"] @=> string hostnames[];
6449 => int port;
hostnames.cap() => int clients;

// send object
OscSend xmit[clients];

// aim the transmitter
for (int i; i < clients; ++i) {
    xmit[i].setHost(hostnames[i], port);
}

2::second => dur beat;
4 => int beatPerBar;

fun void loop() {
    while( true ) {

        for (int i; i < beatPerBar; ++i) {
            for (int j; j < clients; ++j) {
                xmit[j].startMsg( "beat", "i" );
                i => xmit[j].addInt;
            }

            beat => now;
        }
    }
}

spork ~ loop();
while(true) { 1::second => now; }