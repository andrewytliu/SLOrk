
SawOsc osc1 => BPF bpf1 => Gain oscs;
SawOsc osc2 => BPF bpf2 => oscs;
SawOsc osc3 => BPF bpf3 => oscs;
SawOsc osc4 => BPF bpf4 => oscs;

[osc1,osc2,osc3,osc4] @=> SawOsc oscS[];
[bpf1,bpf2,bpf3,bpf4] @=> BPF bpfS[];

oscs => JCRev rev => Delay d => Envelope env => dac;
d => Gain fbk => d;

.2 => rev.gain;
0.5 => oscs.gain;
15::ms => d.delay;
0.75 => fbk.gain;

[2.0, 1.0, 1.0, 1.0] @=> float gains[];
for (int i; i < gains.cap(); ++i) {
    0.0 => oscS[i].freq;
    0.0 => oscS[i].gain;
    0.5 => bpfS[i].Q;
}

//.5::second => env.duration;

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

0 => int currentBar;
0 => int currentBeat;

0.0 => float volume;
0 => int chordno;
1 => int thickness ; // level: 1 - 4
0 => int overdrive;
0 => int density;
0 => int crash;


fun void mute() {
    for (int i; i < gains.cap(); ++i) {
        0.0 => oscS[i].freq;
        0.0 => oscS[i].gain;
    }
}

fun void play() {
    env.keyOff();
    mute();

    for (0=> int i; i < thickness; i++) {
        chords[chordno][currentBar][i]  + 48 => int note;
        note => Std.mtof => oscS[i].freq;
        note => Std.mtof => bpfS[i].freq;
        gains[i] * volume *0.5 => oscS[i].gain;
    }

    env.keyOn();
}

fun void playSingle() {
    env.keyOff();
    mute();

    int pick;
    if (thickness < 4) {
        thickness => pick;
    } else {
        0 => pick;
    }

    chords[chordno][currentBar][pick] + 48 + Math.random2(-1,0)*12 => int note;
    note => Std.mtof => oscS[pick].freq;
    note => Std.mtof => bpfS[pick].freq;
    gains[0] * volume*0.8=> oscS[pick].gain;

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

            if (c == 'a') if (thickness - 1 >= 1) 1 -=> thickness;
            if (c == 's') if (thickness + 1 <= 4) 1 +=> thickness;
            if (c == 'z') {
                0.05 -=> volume;
                if (volume < 0) 0.0 => volume;
            }
            if (c == 'x') 0.05 +=> volume;

            //if (c == '1') if (density - 1 >= 0) 1 -=> density;
            //if (c == '2') if (density + 1 <= 2) 1 +=> density;
        }
    }
}

[4,2,1] @=> int lasts[];

fun void playBar() {
    if (density == 0 && currentBeat % 8 == 0) {
        play();
    } else if (density == 1 && currentBeat % 8 == 0) {
        play();
    } else if (density == 1 && currentBeat % 8 == 4) {
        playSingle();
    } else if (density == 2 && currentBeat % 4 == 0) {
        play();
    } else if (density == 2 && currentBeat % 4 == 2) {
        playSingle();
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

0 => int network;

fun void recvOrk() {
    OscRecv recv;
    6449 => recv.port;
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
                if (rbeat == -2) {
                    stop();
                    2::second => now;
                    1 => crash;
                }
                if (rbeat < -2) {
                    -3 - rbeat => chordno;
                    if (chordno == 3 || chordno == 5 || chordno == 6)
                        2 => density;
                    if (chordno == chords.cap()-1 || chordno == chords.cap()-2){
                        4 => thickness;
                        0 => density;
                    }
                }
            }
        }
    }
}

<<<"", "">>>;
<<<"", "">>>;
<<<"", "">>>;
<<<"", "">>>;

fun void print() {
    "\033[5D\033[4A" => string ctrl;

    if (network == 0) {
        <<<ctrl, " -   +     V1    V2    V3     Network:    OFF", "">>>;
    } else {
        <<<ctrl, " -   +     V1    V2    V3     Network:    ON", "">>>;
    }
    //<<<" [1] [2] Density:  ", density>>>;
    //<<<" [Q] [W] Thickness:", thickness>>>;
    <<<" [A] [S]    1-4   1-4   ---    Thickness: ", thickness>>>;
    <<<" [Z] [X]                       Volume:    ", volume>>>;
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
while (true) {
    if (crash > 0) break;
    second => now;
}
