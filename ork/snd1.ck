SawOsc osc1 => Gain s;
SawOsc osc2 => s;
SawOsc osc3 => s;
SawOsc osc4 => s;
s => Envelope env => JCRev rev => BPF bpf => dac;

//80 => Std.mtof => l.freq;
//60 => Std.mtof => voc.freq;
//20 => voc.harmonics;
//0.5 => voc.noteOn;
//0.5 => voc.controlOne;
//2 => voc.controlTwo;

1.0 => osc2.gain;
0.9 => osc1.gain;
0.5 => osc3.gain;
0.3 => osc4.gain;

fun void setTone(int base) {
    env.keyOff();
    base => Std.mtof => bpf.freq;
    50 => bpf.Q;
    base => Std.mtof => osc1.freq;
    base + 4 => Std.mtof => osc2.freq;
    base + 7 => Std.mtof => osc2.freq;
    base - 1 => Std.mtof => osc4.freq;
    env.keyOn();
}

setTone(80);
1::second => now;
setTone(79);
1::second => now;
setTone(77);
1::second => now;
setTone(75);
1::second => now;
setTone(77);
2::second => now;
1::second => env.duration;
env.keyOff();
2::second => now;
