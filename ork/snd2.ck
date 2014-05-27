class Interpolate
{
    // todo:  add static methods for other interpolations

    fun static float linear(float value, float sourceMin, float sourceMax, float targetMin, float targetMax)
    {
        return targetMin + (targetMax - targetMin) * ((value - sourceMin) / (sourceMax - sourceMin));
    }
}

class Effect extends Chubgraph
{
    Gain dry;
    Gain wet;

    0.0 => float _dryGain;
    1.0 => float _wetGain;

    _dryGain => dry.gain;
    _wetGain => wet.gain;

    // chuck inlet to effect to wet
    wet => outlet;
    inlet => dry => outlet;

    // running by default
    true => int _running;

    fun float mix(float f)
    {
        f => _wetGain;
        1.0 - f => _dryGain;

        _wetGain => wet.gain;
        _dryGain => dry.gain;
        return _wetGain;
    }

    fun float mix()
    {
        return _wetGain;
    }

    fun void start()
    {
        if (!_running)
        {
            _dryGain => dry.gain;
            _wetGain => wet.gain;
            true => _running;
        }
    }

    fun void stop()
    {
        if (_running)
        {
            1.0 => dry.gain;
            0.0 => wet.gain;
            false => _running;
        }
    }

    fun void toggle()
    {
        if (_running)
        {
            stop();
        }
        else
        {
            start();
        }
    }

    fun int running()
    {
        return _running;
    }
}

class Tremolo extends Effect
{
    Gain tremolo;
    SinOsc sinLfo;
    SqrOsc sqrLfo;
    TriOsc triLfo;
    0.33 => float sinMix;
    0.33 => float sqrMix;
    0.33 => float triMix;
    1.0 => float _rate;
    1.0 => float _depth;

    {
        inlet => tremolo => wet;
        sinLfo => blackhole;
        sqrLfo => blackhole;
        triLfo => blackhole;

        rate(_rate);
        depth(_depth);

        spork ~ _tickAtSampleRate();
    }

    fun float rate()
    {
        return _rate;
    }

    fun float rate(float rate)
    {
        rate => _rate;
        _rate => sinLfo.freq;
        _rate => sqrLfo.freq;
        _rate => triLfo.freq;
        return _rate;
    }

    fun float depth()
    {
        return _depth;
    }

    fun float depth(float depth)
    {
        depth => _depth;
        _depth * sinMix => sinLfo.gain;
        _depth * sqrMix => sqrLfo.gain;
        _depth * triMix => triLfo.gain;
        return _depth;
    }

    fun void _tickAtSampleRate()
    {
        while (true)
        {
            1::samp => now;
            sinLfo.last() * sinMix + sqrLfo.last() * sqrMix + triLfo.last() * triMix => float last;
            Interpolate.linear(last, -1.0, 1.0, 0.0, 1.0) => tremolo.gain;
        }
    }
}

SawOsc osc1 => BPF bpf1 => Gain oscs;
SawOsc osc2 => BPF bpf2 => oscs;
SawOsc osc3 => BPF bpf3 => oscs;
SawOsc osc4 => BPF bpf4 => oscs;

[osc1,osc2,osc3,osc4] @=> SawOsc oscS[];
[bpf1,bpf2,bpf3,bpf4] @=> BPF bpfS[];

oscs => JCRev rev => Delay d => Envelope envs => dac;
d => Gain fbk => d;

/* Overdrive od;
TriOsc tris => od.in;
od.out => Gain ofbk => Echo e1 => Echo e2 => Echo e3 => Echo e4 => Echo e5 => Delay odelay => Envelope envt => dac;
25::ms => odelay.delay;
odelay => ofbk;
0.75 => ofbk.gain;

0 => tris.gain; */

SawOsc bee1 => Gain tris;
SawOsc bee2 => tris;
tris => LPF tplf => Tremolo tremolo => ADSR envt => dac;

envt.set(10::ms, 8::ms, 0.8, 60::ms);
//bee1.noteOn(1.0);
//bee2.noteOn(1.0);
5.0 => tremolo.rate;
8.0 => tremolo.depth;


.2 => rev.gain;
0.5 => oscs.gain;
15::ms => d.delay;
0.75 => fbk.gain;

[1.0, 1.0, 1.0, 1.0] @=> float gains[];
for (int i; i < gains.cap(); ++i) {
    0.0 => oscS[i].freq;
    0.0 => oscS[i].gain;
    0.5 => bpfS[i].Q;
}

//.5::second => env.duration;

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
2.0 => float volume;
0 => int chordno;
1 => int thickness ; // level: 1 - 4
0 => int overdrive;

fun Envelope getEnv() {
    if (overdrive == 0) {
        return envs;
    } else {
        return envt;
    }
}

fun void setTone() {
    getEnv().keyOff();

    if (overdrive == 0) {
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
    } else {
        0.0 => tris.gain;
        chords[chordno][currentBar][0] + 48 => int note1;
        note1 => Std.mtof => bee1.freq;
        chords[chordno][currentBar][1] + 24 => int note2;
        note2 => Std.mtof => bee2.freq;
        note1 + 24 => Std.mtof => tplf.freq;
        0.6 => tris.gain;
    }


    //chords[currentBar][0] + 48 => Std.mtof => osc1.freq;
    //chords[currentBar][1] + 48 => Std.mtof => osc2.freq;
    //chords[currentBar][2] + 48 => Std.mtof => osc3.freq;
    //chords[currentBar][0] + 48 + 12 => Std.mtof => osc4.freq;

    getEnv().keyOn();
}
fun void play() {
    //Math.random2(0, chords[currentBar].cap() - 1) => int pick;
    //chords[currentBar][pick] => int note;
    setTone();//setTone(48 + note);
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
            if (msg.ascii == '1' && msg.isButtonDown()) {
                0 => overdrive;
                1.0 => oscs.gain;
                0.0 => tris.gain;
            }
            if (msg.ascii == '2' && msg.isButtonDown()) {
                1 => overdrive;
                0.0 => oscs.gain;
                2.0 => tris.gain;
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
    recv.event("beat", "i") @=> OscEvent oe;

    while (true) {
        oe => now;
        if (network == 0) {
            1 => network;
        }

        while (oe.nextMsg() != 0) {
            oe.getInt() => int rbeat;
            rbeat / 8 => currentBar;
            if (rbeat % 8 == 0) {
                stop();
            }
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
        <<<ctrl, " -   +  Network:   OFF", "">>>;
    } else {
        <<<ctrl, " -   +  Network:   ON", "">>>;
    }

    if (overdrive == 0) {
        <<<" [1] [2] OD:        OFF", "">>>;
    } else {
        <<<" [1] [2] OD:        ON", "">>>;
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
