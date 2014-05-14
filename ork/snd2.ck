SawOsc osc1 => Gain s;
SawOsc osc2 => s;
SawOsc osc3 => s;
SawOsc osc4 => s;
s => JCRev rev => Delay d => Envelope env => BPF bpf => dac;
d => Gain fbk => d;

//80 => Std.mtof => l.freq;
//60 => Std.mtof => voc.freq;
//20 => voc.harmonics;
//0.5 => voc.noteOn;
//0.5 => voc.controlOne;
//2 => voc.controlTwo;

0.2 => s.gain;
15::ms => d.delay;
0.99 => fbk.gain;
10 => bpf.Q;

1.0 => osc2.gain;
0.9 => osc1.gain;
0.5 => osc3.gain;
0.3 => osc4.gain;

1::second => env.duration;

fun void setTone(int base) {
    env.keyOff();
    <<<"Setting: ", base>>>;
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

int currentBar;

fun void play() {
    Math.random2(0, chords[currentBar].cap() - 1) => int pick;
    chords[currentBar][pick] => int note;
    setTone(48 + note);
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

spork ~ getKeyboard();
spork ~ runBar();
while (true) { 1::second => now; }

