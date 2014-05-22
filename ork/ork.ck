
20 => int maxClient;
0 => int clients;

string hostnames[maxClient];
OscSend xmit[maxClient];
OscSend ymit[maxClient];
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
                    ymit[k].startMsg("beat", "i");
                    j => ymit[k].addInt;
                }
                beat => now;
            }
        }
    }
}

fun void setupClient(string name) {
    name => hostnames[clients];
    xmit[clients].setHost(name, port);
    ymit[clients].setHost(name, port + 1);
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

            0 => int flag;

            for (int i; i < clients; ++i) {
                if (hostnames[i] == client) {
                    1 => flag;
                    break;
                }
            }

            if (flag != 0) {
                <<<"Reconnecting:", client>>>;
                continue;
            }

            <<<"Reporting:", client>>>;
            setupClient(client);
        }
    }
}

spork ~ loop();
spork ~ recvReport();
while(true) { 1::second => now; }