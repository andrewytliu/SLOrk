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

fun void setTone(int base) {
    env.keyOff();
    base => Std.mtof => osc1.freq;

    base + 5 => Std.mtof => lpf.freq;
    //Math.random2(0, comp.cap() - 1) => int pick;
    //comp[pick] => int diff;
    //base - diff => Std.mtof => osc2.freq;
    //base + 7 => Std.mtof => osc2.freq;
    //base - 1 => Std.mtof => osc4.freq;
    env.keyOn();
}

[[0, 4, 7, 12, 16, 19],
 [0, 4, 9, 12 ,16, 21],
 [0, 5, 9, 12 ,17, 21],
 [2, 7, 11, 14, 19, 23]] @=> int chords[][];

int currentBar;

fun void play() {
    Math.random2(0, chords[currentBar].cap() - 1) => int pick;
    chords[currentBar][pick] => int note;
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
    recv.event("beat", "i") @=> OscEvent oe;

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

fun void print() {
    if (network == 0) {
        <<<"\033[2ANetwork: OFF", "">>>;
    } else {
        <<<"\033[2ANetwork: ON", "">>>;
    }
    <<<"[", currentBar ,"]">>>;
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

spork ~ reportSelf(me.arg(0), myself);
spork ~ getKeyboard();
spork ~ printLoop();
// spork ~ runBar();
spork ~ recvOrk();
while (true) { 1::second => now; }
