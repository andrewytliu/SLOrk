
20 => int maxClient;
0 => int clients;

string hostnames[maxClient];
OscSend xmit[maxClient];
6449 => int port;

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

fun void setupClient(string name) {
    name => hostnames[clients];
    xmit[clients].setHost(name, port);
    clients++;
}

fun void recvReport()
{
    OscRecv recv;
    5501 => recv.port;
    recv.listen();

    recv.event("report, s") @=> OscEvent oe;

    while (true) {
        oe => now;

        while( oe.nextMsg() != 0 ) {
            oe.getString()  => string client;
            <<<"Reporting:", client>>>;
            setupClient(client);
        }
    }
}

spork ~ loop();
spork ~ recvReport();
while(true) { 1::second => now; }