8 => int beats;

SndBuf snd[2];
int choose[beats];

"snare-hop.wav" => snd[0].read;
"hihat.wav"     => snd[1].read;

for (int i; i < snd.cap(); ++i) {
    snd[i] => dac;
}

for (int i; i < choose.cap(); ++i) {
    -1 => choose[i];
}

fun void play(int i) {
    0 => snd[i].pos;
    snd[i].play();
}

/*while (true) {
    0 => buf.pos;
    buf.play();
    1::second => now;
}*/

fun void toggle(int pos, int val) {
    if (choose[pos] == val) -1 => choose[pos];
    else val => choose[pos];
}

fun void getKeyboard() {
    KBHit kb;

    while (true) {
        kb => now;

        while (kb.more()) {
            kb.getchar() => int c;

            if (c >= 49 && c <= 56) {
                toggle(c - 49, 0);
            }
            if (c == 'q') toggle(0, 1);
            if (c == 'w') toggle(1, 1);
            if (c == 'e') toggle(2, 1);
            if (c == 'r') toggle(3, 1);
            if (c == 't') toggle(4, 1);
            if (c == 'y') toggle(5, 1);
            if (c == 'u') toggle(6, 1);
            if (c == 'i') toggle(7, 1);
        }
    }
}

0 => int currentBeat;

fun void runBar() {
    while (true) {
        for (int i; i < beats; ++i) {
            if (choose[i] > 0) {
                play(choose[i]);
            }
            250::ms => now;
        }
    }
}

0 => int network;

fun void recvOrk() {
    OscRecv recv;
    6449 => recv.port;
    recv.listen();
    recv.event("beat", "i") @=> OscEvent oe;

    while (true) {
        oe => now;
        if (network == 0) {
            1 => network;
        }

        while (oe.nextMsg() != 0) {
            oe.getInt() => currentBeat;
        }
    }
}

<<<"", "">>>;
<<<"", "">>>;
<<<"", "">>>;

fun void print() {
    "\033[5D\033[3A" => string ctrl;
    if (network == 0) {
        <<<ctrl, "Network: OFF", "">>>;
    } else {
        <<<ctrl, "Network: ON", "">>>;
    }
    <<<" [", currentBeat ,"]">>>;
    <<<" [", choose[0], "] [", choose[1], "] [", choose[2], "] [", choose[3], "] [", choose[4], "] [", choose[5], "] [", choose[6], "] [", choose[7], "]">>>;
}

fun void printLoop() {
    while (true) {
        print();
        100::ms => now;
    }
}

fun void reportSelf(string hostname, string newclient) {
    OscSend xmit;
    xmit.setHost(hostname, 5501);

    while (network == 0) {
        xmit.startMsg("report", "s");
        newclient => xmit.addString;
        5::second => now;
    }
}


string myself;
if (me.args() > 1) {
    me.arg(1) => myself;
} else {
    Std.getenv("NET_NAME") => myself;
}

if (me.args() > 0) {
    spork ~ reportSelf(me.arg(0), myself);
    spork ~ recvOrk();
} else {
    spork ~ runBar();
}
spork ~ getKeyboard();
spork ~ printLoop();
while (true) { 1::second => now; }