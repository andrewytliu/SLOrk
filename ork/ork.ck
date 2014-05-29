
20 => int maxClient;
0 => int clients;

string hostnames[maxClient];
OscSend xmit[maxClient];
6449 => int outPort;

250::ms => dur beat;
64 => int beatPerGroup;

fun void sendGroup(int msg) {
    for (int j; j < clients; ++j) {
        xmit[j].startMsg("beat", "i");
        msg => xmit[j].addInt;
    }
}

fun void loop() {
    while( true ) {
        for (int i; i < beatPerGroup; ++i) {
            sendGroup(i);
            beat => now;
        }
    }
}

fun void setupClient(string name, int port) {
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
            setupClient(client, outPort);
        }
    }
}

fun void getKeyboard() {
    KBHit kb;

    while (true) {
        kb => now;

        while (kb.more()) {
            kb.getchar() => int c;

            if (c == 'z') {
                sendGroup(-1);
                <<<"Destruction start", "">>>;
            }

            if (c == 'x') {
                sendGroup(-2);
                <<<"END", "">>>;
            }
        }
    }
}

spork ~ loop();
spork ~ recvReport();
spork ~ getKeyboard();
while(true) { 1::second => now; }
