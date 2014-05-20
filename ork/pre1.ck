8 => int beats;
4 => int bars;
0.2 => float gain;

0 => int currentBeat;
0 => int currentBar;

SndBuf snd[3];
SndBuf glock[12];
int choose[beats];

[[0, 4, 7],
 [0, 4, 9],
 [0, 5, 9],
 [2, 7, 11],
 [0, 4, 7],
 [0, 4, 9],
 [0, 5, 9],
 [2, 7, 11]] @=> int chords[][];

"snare-hop.wav" => snd[0].read;
"hihat.wav"     => snd[1].read;
"kick.wav"      => snd[2].read;

"glockenspiel/c.wav" => glock[0].read;
"glockenspiel/c+1.wav" => glock[1].read;
"glockenspiel/d.wav" => glock[2].read;
"glockenspiel/d+1.wav" => glock[3].read;
"glockenspiel/e.wav" => glock[4].read;
"glockenspiel/f.wav" => glock[5].read;
"glockenspiel/f+1.wav" => glock[6].read;
"glockenspiel/g.wav" => glock[7].read;
"glockenspiel/g+1.wav" => glock[8].read;
"glockenspiel/a.wav" => glock[9].read;
"glockenspiel/a+1.wav" => glock[10].read;
"glockenspiel/b.wav" => glock[11].read;

for (int i; i < glock.cap(); ++i) {
    0.0 => glock[i].gain;
    glock[i] => dac;
}

for (int i; i < snd.cap(); ++i) {
    0.0 => snd[i].gain;
    snd[i] => dac;
}

for (int i; i < choose.cap(); ++i) {
    -1 => choose[i];
}

fun void play(int i) {
    choose[i] => int pick;

    if (pick == 3) {
        Math.random2(0, chords[currentBar].cap() - 1) => int cpick;
        gain => glock[chords[currentBar][cpick]].gain;
        0 => glock[chords[currentBar][cpick]].pos;
        glock[cpick].play();
    } else if (pick >= 0) {
        gain => snd[pick].gain;
        0 => snd[pick].pos;
        snd[pick].play();
    }
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

            if (c == 'a') toggle(0, 2);
            if (c == 's') toggle(1, 2);
            if (c == 'd') toggle(2, 2);
            if (c == 'f') toggle(3, 2);
            if (c == 'g') toggle(4, 2);
            if (c == 'h') toggle(5, 2);
            if (c == 'j') toggle(6, 2);
            if (c == 'k') toggle(7, 2);

            if (c == 'z') toggle(0, 3);
            if (c == 'x') toggle(1, 3);
            if (c == 'c') toggle(2, 3);
            if (c == 'v') toggle(3, 3);
            if (c == 'b') toggle(4, 3);
            if (c == 'n') toggle(5, 3);
            if (c == 'm') toggle(6, 3);
            if (c == ',') toggle(7, 3);
        }
    }
}

fun void runBar() {
    while (true) {
        for (int j; j < bars; ++j) {
            j => currentBar;
            for (int i; i < beats; ++i) {
                i => currentBeat;
                play(i);
                250::ms => now;
            }
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
            play(currentBeat);
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
    <<<" [", currentBar ,"] [", currentBeat, "]">>>;
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