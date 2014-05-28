Blit osc => LPF lpf => Envelope env => JCRev rev => dac;


0.0 => osc.gain;
0.1 => lpf.Q;

10.0 => osc.gain;
0.0 => osc.gain;
10 => osc.harmonics;

[8, 7, 5, 3] @=> int comp[];

[

[[0, 4, 7, 12, 16, 19],
 [0, 4, 9, 12 ,16, 21],
 [0, 5, 9, 12 ,17, 21],
 [2, 7, 11, 14, 19, 23],
 [0, 4, 7, 12, 16, 19],
 [0, 4, 9, 12 ,16, 21],
 [0, 5, 9, 12 ,17, 21],
 [2, 7, 11, 14, 19, 23]],

 [[0, 4, 7, 12, 16, 19],
 [0, 4, 9, 12 ,16, 21],
 [0, 5, 9, 12 ,17, 21],
 [2, 7, 11, 14, 19, 23],
 [-1, 2, 4, 8, 11, 14],
 [0, 4, 9, 12 ,16, 21],
 [2, 5, 9, 14 ,17, 21],
 [2, 7, 11, 14, 17, 19]],

  [[0, 4, 7, 12, 16, 19],
 [-1, 2, 4, 7 , 11, 16],
 [0, 4, 5, 9 , 12, 16],
 [0, 4, 7, 11, 12, 16],
 [2, 5, 9, 12 , 14, 17],
 [0, 4, 7, 12, 16, 19],
 [2, 5, 9, 12 , 14, 17],
 [2, 7, 11, 14, 17, 19]],

[[0, 4, 7, 12, 16, 19],
 [0, 4, 7, 12, 16, 19],
 [0, 3, 7, 12, 15, 19],
 [0, 3, 7, 12, 15, 19],
 [0, 4, 7, 12, 16, 19],
 [0, 4, 7, 12, 16, 19],
 [0, 4, 7, 12, 16, 19],
 [0, 4, 7, 12, 16, 19]]

 ] @=> int chords[][][];

0 => int currentBar;
0 => int currentBeat;
0.0 => float volume;
0 => int ornament; // 0: no ornament, 1: appoggiatura, 2: turu
0 => int chordno;
0 => int density;

fun void setTone(int base) {
    env.keyOff();

    base + 5 => Std.mtof => lpf.freq;
    volume => osc.gain;

    if (ornament == 0) {
        base => Std.mtof => osc.freq;
    } else if (ornament == 1) {
        base - 1 => osc.freq;
        100::ms => now;
        base => Std.mtof => osc.freq;
    } else if (ornament == 2) {
        base => Std.mtof => osc.freq;
        100::ms => now;
        base + 2 => Std.mtof => osc.freq;
        50::ms => now;
        base => Std.mtof => osc.freq;
        50::ms => now;
        base - 1 => Std.mtof => osc.freq;
        50::ms => now;
        base => Std.mtof => osc.freq;
    } else if (ornament == 3){
        base => Std.mtof => osc.freq;
        100::ms => now;
        base + 12 => Std.mtof => osc.freq;
        100::ms => now;
        base => Std.mtof => osc.freq;
        100::ms => now;
        base + 12 => Std.mtof => osc.freq;
        100::ms => now;
        base => Std.mtof => osc.freq;
        100::ms => now;
    }
    env.keyOn();
}


fun void play() {
    Math.random2(0, chords[chordno][currentBar].cap() - 1) => int pick;
    chords[chordno][currentBar][pick] + Math.random2(0,1)*12 + 48 => int note;
    setTone(note);
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

            if (c == '1') if (ornament - 1 >= 0) 1 -=> ornament;
            if (c == '2') if (ornament + 1 <= 3) 1 +=> ornament;
            if (c == 'q') if (density - 1 >= 0) 1 -=> density;
            if (c == 'w') if (density + 1 <= 4) 1 +=> density;
            if (c == 'z') if (volume - 0.05 >= 0) 0.05 -=> volume;
            if (c == 'x') 0.05 +=> volume;
            if (c == 'a') if (chordno - 1 >= 0) 1 -=> chordno;
            if (c == 's') if (chordno + 1 <= chords.cap()) 1 +=> chordno;
        }
    }
}

[4, 2, 1] @=> int lasts[];
0 => int last;

fun void playBar() {
    if (currentBeat == 0) 0 => last;

    if (last == 0) {
        int ppick;
        if (density == 0) 0 => ppick;
        if (density == 1) Math.random2(0, 1) => ppick;
        if (density == 2) Math.random2(0, 2) => ppick;
        if (density == 3) Math.random2(1, 2) => ppick;
        if (density == 4) Math.random2(2, 2) => ppick;
        play();
        lasts[ppick] => last;
    }
    1 -=> last;
}

0 => int network;

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
            rbeat / 8 => currentBar;
            rbeat % 8 => currentBeat;
            playBar();
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
        <<<ctrl, " -   +  Network:  OFF", "">>>;
    } else {
        <<<ctrl, " -   +  Network:  ON", "">>>;
    }
    <<<" [1] [2] Ornament:", ornament>>>;
    <<<" [Q] [W] Density: ", density>>>;
    <<<" [A] [S] ChordNo: ", chordno>>>;
    <<<" [Z] [X] Volume:  ", volume>>>;
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
