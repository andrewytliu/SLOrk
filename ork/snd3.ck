Blit oscb => LPF lpf => Envelope envb => JCRev rev => Gain s => dac;
SawOsc oscs => Envelope envs => s;


0.5 => s.gain;
0.1 => lpf.Q;

10.0 => oscb.gain;
0.0 => oscs.gain;
10 => oscb.harmonics;
0 => int overdrive;

[8, 7, 5, 3] @=> int comp[];


[[[0, 4, 7, 12, 16, 19],
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

int currentBar;
0.5 => float volume;
0 => int ornament; //0:: no ornament, 1: appoggiatura, 2: turu
0 => int chordno;

fun void setFreq(int freq) {
    freq => Std.mtof => oscb.freq;
    freq => Std.mtof => oscs.freq;
}

fun Envelope getEnv() {
    if (overdrive == 0) {
        return envb;
    } else {
        return envs;
    }
}

fun void setTone(int base) {
    getEnv().keyOff();

    base + 5 => Std.mtof => lpf.freq;
    volume => s.gain;

    getEnv().keyOn();
    if (ornament == 0 ) // no ornament
        setFreq(base);
    else if (ornament == 1 ){ //
        setFreq(base - 1);
        100::ms => now;
        setFreq(base);
    }
    else if (ornament == 2) {
        setFreq(base);
        100::ms => now;
        setFreq(base + 2);
        50::ms => now;
        setFreq(base);
        50::ms => now;
        setFreq(base - 1);
        50::ms => now;
        setFreq(base);
    } else if (ornament ==3 ){
        setFreq(base);
        100::ms => now;
        setFreq(base + 12);
        100::ms => now;
        setFreq(base);
        100::ms => now;
        setFreq(base + 12);
        100::ms => now;
        setFreq(base);
        100::ms => now;
    }
}


fun void play() {
    Math.random2(0, chords[chordno][currentBar].cap() - 1) => int pick;
    chords[chordno][currentBar][pick] => int note;
    setTone(60 + note);
}

fun void stop() {
    getEnv().keyOff();
}

fun void getKeyboard() {
    Hid hi;
    HidMsg msg;

    0 => int device;
    if (!hi.openKeyboard(device)) me.exit();

    while (true) {
        hi => now;

        while (hi.recv(msg)) {
            if (msg.ascii == 32) { // space
                if (msg.isButtonDown()) {
                    play();
                } else {
                    stop();
                }
            }

            if (msg.ascii ==81){ //Q
                if (msg.isButtonDown()){
                    if(ornament-1 >= 0)
                        1 -=> ornament;
                }
            } else if (msg.ascii == 87){ //W
                if (msg.isButtonDown()){
                    if(ornament+1 <= 3 )
                        1 +=> ornament;
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

            if (msg.ascii == '1' && msg.isButtonDown()) {
                0 => overdrive;
                10.0 => oscb.gain;
                0.0 => oscs.gain;
            }
            if (msg.ascii == '2' && msg.isButtonDown()) {
                1 => overdrive;
                0.0 => oscb.gain;
                0.4 => oscs.gain;
            }
        }
    }
}

fun void runBar() {
    while (true) {
        for (int i; i < 8; ++i) {
            i => currentBar;
            2::second => now;
            stop();
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
<<<"", "">>>;
fun void print() {
    "\033[5D\033[6A" => string ctrl;

    if (network == 0) {
        <<<ctrl, " -   +  Network:  OFF", "">>>;
    } else {
        <<<ctrl, " -   +  Network:  ON", "">>>;
    }

    if (overdrive == 0) {
        <<<" [1] [2] OD:       OFF", "">>>;
    } else {
        <<<" [1] [2] OD:       ON", "">>>;
    }

    <<<" [Q] [W] Ornament:", ornament>>>;
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
