
20 => int maxClient;
0 => int clients;

string hostnames[maxClient];
OscSend xmit[maxClient];
6449 => int port;

250::ms => dur beat;
8 => int barPerGroup;
8 => int beatPerBar;

fun void loop() {
    while( true ) {

        for (int i; i < barPerGroup; ++i) {
            // sending group
            for (int j; j < clients; ++j) {
                xmit[j].startMsg("group", "i");
                i => xmit[j].addInt;
            }

            for (int j; j < beatPerBar; ++j) {
                for (int k; k < clients; ++k) {
                    xmit[k].startMsg("beat", "i");
                    j => xmit[k].addInt;
                }
                beat => now;
            }
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