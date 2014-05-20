Blit osc1 => Gain s;
Blit osc2 => s;
Blit osc3 => s;
Blit osc4 => s;
s => LPF lpf => Envelope env => JCRev rev => dac;

//80 => Std.mtof => l.freq;
//60 => Std.mtof => voc.freq;
//20 => voc.harmonics;
//0.5 => voc.noteOn;
//0.5 => voc.controlOne;
//2 => voc.controlTwo;

0.5 => s.gain;
0.1 => lpf.Q;

0.0 => osc2.gain;
1.0 => osc1.gain;
0.0 => osc3.gain;
0.0 => osc4.gain;
10 => osc1.harmonics;
3 => osc2.harmonics;
3 => osc3.harmonics;
3 => osc4.harmonics;



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
 [2, 7, 11, 14, 17, 19]]] @=> int chords[][][];

int currentBar;
0 => float volume;
0 => int ornament; //0:: no ornament, 1: appoggiatura, 2: turu
0 => int chordno;
fun void setTone(int base) {
    env.keyOff();
    //base => Std.mtof => osc1.freq;

    base + 5 => Std.mtof => lpf.freq;
    volume => osc1.gain;
    //Math.random2(0, comp.cap() - 1) => int pick;
    //comp[pick] => int diff;
    //base - diff => Std.mtof => osc2.freq;
    //base + 7 => Std.mtof => osc2.freq;
    //base - 1 => Std.mtof => osc4.freq;
    env.keyOn();
    if (ornament == 0 ) // no ornament
        base => Std.mtof => osc1.freq;
    else if (ornament == 1 ){ //
        base -1  => Std.mtof => osc1.freq;
        100::ms => now;
        base => Std.mtof => osc1.freq;
    }
    else if (ornament == 2) {
        base   => Std.mtof => osc1.freq;
        100::ms => now;
        base + 2   => Std.mtof => osc1.freq;
        50::ms => now;
        base  => Std.mtof => osc1.freq;
        50::ms => now;
        base -1  => Std.mtof => osc1.freq;
        50::ms => now;
        base => Std.mtof => osc1.freq;
    }
}


fun void play() {
    Math.random2(0, chords[chordno][currentBar].cap() - 1) => int pick;
    chords[chordno][currentBar][pick] => int note;
    setTone(60 + note);
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
                    if(ornament+1 <= 2 )
                        1 +=> ornament;
                }
            } else if (msg.ascii == 90) { // Z
                if (msg.isButtonDown()){
                    if(volume - 0.2 >=0) {
                        0.2 -=> volume;
                    }
                }   

            } else if (msg.ascii == 88)  {//X
                if (msg.isButtonDown()){
                    0.2 +=> volume;                   
                }
            } else if (msg.ascii == 65) { // A
                if (msg.isButtonDown()){
                    if( chordno - 1 >=0) {
                        1 -=> chordno;
                    }
                }   

            } else if (msg.ascii == 83)  {//S
                if (msg.isButtonDown()){
                    if(chordno + 1 <=2) {
                        1 +=> chordno;
                    }                   
                }
            }


        }
    }
}

fun void runBar() {
    while (true) {
        for (int i; i < chords.cap(); ++i) {
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
        <<<ctrl, "        Network:  OFF", "">>>;
    } else {
        <<<ctrl, "        Network:  ON", "">>>;
    }

    <<<" [Q] [W] Ornament:", ornament>>>;
    <<<" [A] [S] ChordNo:", chordno>>>;
    <<<" [Z] [X] Volume:", volume>>>;
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
