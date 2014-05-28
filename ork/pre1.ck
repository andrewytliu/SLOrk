8 => int beats;
8 => int bars;

0 => int currentBeat;
0 => int currentBar;

Gain g;
SndBuf snd[3];
SndBuf glock[12];
int choose[beats];

0.0 => float vol;
0.0 => g.gain;

[
[[0, 3, 7],
[0, 3, 8],
[0, 5, 8],
[2, 7, 11],
[0, 3, 7],
[0, 3, 8],
[0, 5, 8],
[2, 7, 11]],

[[0, 3, 7],
[0, 3, 8],
[0, 5, 8],
[2, 7, 11],
[3, 7, 10],
[0, 3, 8],
[2, 5, 8],
[2, 7, 11]],

[[0, 3, 7],
[0, 3, 7],
[0, 5, 8],
[2, 5, 7],
[0, 2, 5],
[0, 3, 7],
[0, 5, 8],
[2, 7,11]],

[[0, 4, 7],
[0, 4, 9],
[0, 5, 9],
[2, 7, 11],
[0, 4, 7],
[0, 4, 9],
[0, 5, 9],
[2, 7, 11]],

[[0, 4, 7],
[0, 4, 9],
[0, 5, 9],
[2, 7, 11],
[4, 8, 11],
[0, 4, 9],
[2, 5, 9],
[2, 7, 11]],

[[0, 4, 7],
[0, 7, 11],
[4, 5, 9],
[0, 4, 7],
[0, 2, 9],
[0, 7, 11],
[0, 5, 9],
[2, 7,11]],

[[0, 4, 7],
 [0, 4, 7],
 [0, 3, 7],
 [0, 3, 7],
 [0, 4, 7],
 [0, 4, 7],
 [0, 4, 7],
 [0, 4, 7]]
 ] @=> int chords[][][];

0 => int chordno;

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
    glock[i] => g => dac;
}

for (int i; i < snd.cap(); ++i) {
    0.0 => snd[i].gain;
    snd[i] => g => dac;
}

for (int i; i < choose.cap(); ++i) {
    -1 => choose[i];
}

fun void play(int i) {
    choose[i] => int pick;

    vol => g.gain;
    if (pick == 3) {
        Math.random2(0, chords[chordno][currentBar].cap() - 1) => int cpick;
        chords[chordno][currentBar][cpick] => int note;
        vol => glock[note].gain;
        0 => glock[note].pos;
        glock[note].play();
    } else if (pick >= 0) {
        vol => snd[pick].gain;
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

            if (c == '.') 0.01 -=> vol;
            if (c == '/') 0.01 +=> vol;
            if (c == 'l' && chordno - 1 >= 0) 1 -=> chordno;
            if (c == ';' && chordno + 1 <= 6) 1 +=> chordno;
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
            oe.getInt() => int rbeat;
            rbeat % 8 => currentBeat;
            rbeat / 8 => currentBar;
            play(currentBeat);
        }
    }
}

<<<"", "">>>;
<<<"", "">>>;
<<<"", "">>>;
<<<"", "">>>;
<<<"", "">>>;
<<<"", "">>>;

fun void print() {
    "\033[5D\033[6A" => string ctrl;
    if (network == 0) {
        <<<ctrl, " -   +  Network: OFF", "">>>;
    } else {
        <<<ctrl, " -   +  Network: ON", "">>>;
    }
    <<<" [L] [;] ChordNo:", chordno>>>;
    <<<" [.] [/] Volume: ", vol>>>;
    <<<" [", currentBar ,"] [", currentBeat, "], 0 => snare, 1 => hihat, 2 => kick, 3 => glockenspiel">>>;
    <<<"", "">>>;
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