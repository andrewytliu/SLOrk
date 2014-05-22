SawOsc osc1 => BPF bpf1 => Gain s;
SawOsc osc2 => BPF bpf2 => s;
SawOsc osc3 => BPF bpf3 => s;
SawOsc osc4 => BPF bpf4 => s;

[osc1,osc2,osc3,osc4] @=> SawOsc oscS[];
[bpf1,bpf2,bpf3,bpf4] @=> BPF bpfS[];

s => JCRev rev => Delay d => Envelope env => dac;
d => Gain fbk => d;

.2 => rev.gain;
0.5 => s.gain;
15::ms => d.delay;
0.75 => fbk.gain;

[1.0, 1.0, 1.0, 1.0] @=> float gains[];
for (int i; i < gains.cap(); ++i) {
    0.0 => oscS[i].freq;
    0.0 => oscS[i].gain;
    0.5 => bpfS[i].Q;
}

.5::second => env.duration;
/*
fun void setTone(int base) {
    env.keyOff();
    base => Std.mtof => bpf.freq;

    base => Std.mtof => osc1.freq;
    base + 4 => Std.mtof => osc2.freq;
    base + 7 => Std.mtof => osc2.freq;
    base + 11 => Std.mtof => osc4.freq;
    env.keyOn();
}

[[0, 4, 7],
[0, 4, 9],
[0, 5, 9],
[2, 7]] @=> int chords[][];
*/
[[[0, 4, 7,12],
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
 [0, 4, 7, 12],
 [0, 4, 7, 12]]

] @=> int chords[][][];

int currentBar;
0 => float volume;
0 => int chordno;
1 => int thickness ; // level: 1 - 4

fun void setTone() {
    env.keyOff();

    for (int i; i < gains.cap(); ++i) {
        0.0 => oscS[i].freq;
        0.0 => oscS[i].gain;
    }

    for (int i ; i < thickness; i++){
        chords[chordno][currentBar][i] + 48 => int note;
        note => Std.mtof => oscS[i].freq;
        note => Std.mtof => bpfS[i].freq;
        gains[i] * volume => oscS[i].gain;
    }


    //chords[currentBar][0] + 48 => Std.mtof => osc1.freq;
    //chords[currentBar][1] + 48 => Std.mtof => osc2.freq;
    //chords[currentBar][2] + 48 => Std.mtof => osc3.freq;
    //chords[currentBar][0] + 48 + 12 => Std.mtof => osc4.freq;

    env.keyOn();
}
fun void play() {
    //Math.random2(0, chords[currentBar].cap() - 1) => int pick;
    //chords[currentBar][pick] => int note;
    setTone();//setTone(48 + note);
}

fun void stop() {
    env.keyOff();
}

fun void getKeyboard() {
    Hid hi;
    HidMsg msg;

    0 => int device;
    if (!hi.openKeyboard(device)) me.exit();

    while (true) {
        hi => now;

        while (hi.recv(msg)) {
            ///<<<msg.ascii>>>;
            if (msg.ascii == 32) { // space
                if (msg.isButtonDown()) {
                    play();
                } else {
                    stop();
                }
            }
            // thickness
            if (msg.ascii ==81){ //Q
                if (msg.isButtonDown()){
                    if(thickness-1 >= 1)
                        1 -=> thickness;
                }
            } else if (msg.ascii == 87){ //W
                if (msg.isButtonDown()){
                    if(thickness+1 <= 4 )
                        1 +=> thickness;
                }
            } else if (msg.ascii == 90) { // Z
                if (msg.isButtonDown()){
                    if(volume - 0.05 >=0) {
                        0.05 -=> volume;
                    }
                }

            } else if (msg.ascii == 88)  {//X
                if (msg.isButtonDown()){
                    0.05 +=> volume;
                }
            } else if (msg.ascii == 65) { // A
                if (msg.isButtonDown()){
                    if( chordno - 1 >=0) {
                        1 -=> chordno;
                    }
                }

            } else if (msg.ascii == 83)  {//S
                if (msg.isButtonDown()){
                    if(chordno + 1 <=3) {
                        1 +=> chordno;
                    }
                }
            }

        }
    }
}

fun void runBar() {
    while (true) {
        for (int i; i < 8; ++i) {
            i => currentBar;
            2::second => now;
            //stop();
        }
    }
}

0 => int network;

fun void recvOrk() {
    OscRecv recv;
    6449 => recv.port;
    recv.listen();
    recv.event("group", "i") @=> OscEvent oe;

    while (true) {
        oe => now;
        if (network == 0) {
            1 => network;
        }

        while (oe.nextMsg() != 0) {
            oe.getInt() => currentBar;
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
        <<<ctrl, " -   +  Network:   OFF", "">>>;
    } else {
        <<<ctrl, " -   +  Network:   ON", "">>>;
    }

    <<<" [Q] [W] Thickness:", thickness>>>;
    <<<" [A] [S] ChordNo:  ", chordno>>>;
    <<<" [Z] [X] Volume:   ", volume>>>;
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
