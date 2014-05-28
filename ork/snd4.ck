
TriOsc osc => Envelope env => JCRev rev => dac;

[
[[0, 3, 7,12],
[-4, 0, 3, 8],
[-7, -4, 0, 5],
[-5, -1, 2, 7],
[0, 3, 7,12],
[-4, 0, 3, 8],
[-7, -4, 0, 5],
[-5, -1, 2, 7]],

[[0, 3, 7,12],
[-4, 0, 3, 8],
[-7, -4, 0, 5],
[-5, -1, 2, 7],
[-5, -2, 3, 7],
[-4, 0, 3, 8],
[-10, -7, -4, 2],
[-5, -1, 2, 7]],

[[0, 3, 7,12],
[-2, 3, 7, 12],
[-4, 0, 5, 12],
[-5, 2, 5, 11],
[-7, 0, 2, 8],
[-9, 0, 7, 12],
[-10,0, 5, 8],
[-5, 2, 7,11]],

[[0, 4, 7,12],
[-3, 0, 4, 9],
[-7, -3, 0, 5],
[-5, -1, 2, 7],
[0, 4, 7,12],
[-3, 0, 4, 9],
[-7, -3, 0, 5],
[-5, -1, 2, 7]],

[[0, 4, 7,12],
[-3, 0, 4, 9],
[-7, -3, 0, 5],
[-5, -1, 2, 7],
[-8, -4, -1,4],
[-3, 0, 4, 9],
[-10, -7, -3, 2],
[-5, -1, 2, 7]],

[[0, 4, 7,12],
[-1, 0, 7, 12],
[-3, 4, 5, 12],
[-5, 0, 4, 11],
[-7, 0, 2, 9],
[-8, 0, 7, 11],
[-10,0, 5, 9],
[-5, 2, 7,11]],

[[0, 4, 7, 12],
 [0, 4, 7, 12],
 [0, 3, 7, 12],
 [0, 3, 7, 12],
 [0, 4, 7, 12],
 [0, 4, 7, 12],
 [0, 3, 7, 12],
 [0, 3, 7, 12]],

[[0, 4, 7, 12],
 [0, 4, 7, 12],
 [0, 4, 7, 12],
 [0, 4, 7, 12],
 [0, 4, 7, 12],
 [0, 4, 7, 12],
 [0, 4, 7, 12],
 [0, 4, 7, 12]]
] @=> int chords[][][];

[
[0,2,3,5,7,8,11],
[0,2,4,5,7,9,11]
] @=> int scales[][];

0 => int currentBar;
0 => int currentBeat;
0.0 => float volume;
0 => int chordno;
0 => int density;

fun void play(int pick) {
    env.keyOff();
    //chords[chordno][currentBar][pick] + Math.random2(0,1)*12 + 72 => int note;
    Math.random2f(0,1) => float f;
    int note;
    if (f>0.2) {
        Math.random2(0, chords[chordno][currentBar].cap() - 1) => int pick;

        chords[chordno][currentBar][pick] + Math.random2(0,1)*12 + 72 => note;
    }
    else {
        int index ;
        if(chordno < 3) 0=> index;
        else 1=>index;
        scales[index][Math.random2(0,6)] + Math.random2(0,1)*12 + 72 => note;
    }
    note => Std.mtof => osc.freq;
    volume*0.1 => osc.gain;
    env.keyOn();
}

fun void stop() {
    env.keyOff();
}

fun void getKeyboard() {
    KBHit kb;

    while (true) {
        kb => now;

        while (kb.more()) {
            kb.getchar() => int c;

            if (c == 'q') if (density - 1 >= 0) 1 -=> density;
            if (c == 'w') if (density + 1 <= 5) 1 +=> density;
            if (c == 'z') if (volume - 0.05 >= 0) 0.05 -=> volume;
            if (c == 'x') 0.05 +=> volume;
            if (c == 'a') if (chordno - 1 >= 0) 1 -=> chordno;
            if (c == 's') if (chordno + 1 < chords.cap()) 1 +=> chordno;
        }
    }
}

0 => int lastPick;

fun void playBar() {
    Math.random2(0,3) => int pick;
    if (currentBeat == 0) Math.random2(0,1) => lastPick;

    if (density == 0 && currentBeat % 8 == 0) {
        play(pick);
    } else if (density == 1 && lastPick == 0 && currentBeat % 8 == 0) {
        play(2);
    } else if (density == 1 && lastPick == 0 && currentBeat % 8 == 4) {
        play(1);
    } else if (density == 1 && lastPick == 1 && currentBeat % 8 == 0) {
        play(0);
    } else if (density == 1 && lastPick == 1 && currentBeat % 8 == 4) {
        play(1);
    } else if (density == 2 && lastPick == 0 && currentBeat % 8 == 0) {
        play(2);
    } else if (density == 2 && lastPick == 0 && currentBeat % 8 == 6) {
        play(1);
    } else if (density == 2 && lastPick == 1 && currentBeat % 8 == 0) {
        play(0);
    } else if (density == 2 && lastPick == 1 && currentBeat % 8 == 6) {
        play(1);
    }  else if (density == 3 && currentBeat % 2 == 0) {
        play(pick);
    } else if (density == 4 && currentBeat % 8 == 0) {
        play(0);
    } else if (density == 4 && currentBeat % 8 > 1) {
        play(currentBeat % 4);
    } else if (density == 5) {
        play(currentBeat % 4);
    }
}

fun void runBar() {
    while (true) {
        for (int i; i < 64; ++i) {
            i / 8 => currentBar;
            i % 8 => currentBeat;
            playBar();
            250::ms => now;
        }
    }
}

fun void endDestruct() {
    Noise n => BiQuad f => Gain g => dac;
    .99 => f.prad;
    .05 => f.gain;
    1 => f.eqzs;
    0.0 => float t;
    0 => float gain;

    while( true ) {
        100.0 + Std.fabs(Math.sin(t)) * 15000.0 => f.pfreq;
        t + .01 => t;
        5::ms => now;
        0.0001 +=> gain;
        gain * volume => g.gain;
    }
}

0 => int network;

fun void recvOrk() {
    OscRecv recv;
    1234 => recv.port;
    recv.listen();
    recv.event("beat", "i") @=> OscEvent oe;

    while (true) {
        oe => now;
        1 => network;

        while (oe.nextMsg() != 0) {
            oe.getInt() => int rbeat;

            if (rbeat >= 0) {
                rbeat / 8 => currentBar;
                rbeat % 8 => currentBeat;
                playBar();
            } else {
                if (rbeat == -1) spork ~ endDestruct();
                if (rbeat == -2) {
                    stop();
                    2::second => now;
                    0/0;
                }
            }
        }
    }
}

<<<"", "">>>;
<<<"", "">>>;
<<<"", "">>>;
<<<"", "">>>;
<<<"", "">>>;
fun void print() {
    "\033[5D\033[5A" => string ctrl;

    if (network == 0) {
        <<<ctrl, " -   +     V1    V2    V3     Network:  OFF", "">>>;
    } else {
        <<<ctrl, " -   +     V1    V2    V3     Network:  ON", "">>>;
    }

    <<<" [Q] [W]    0-2   3-5   3-5    Density: ", density>>>;
    <<<" [A] [S]    0-2   3-5   6-7    ChordNo: ", chordno>>>;
    <<<" [Z] [X]                       Volume:  ", volume>>>;
    <<<" [", currentBar ,"]">>>;
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
