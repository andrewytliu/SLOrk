// Courtesy of http://electro-music.com/forum/topic-19287.html&postorder=asc
class Overdrive
{
   // this overdrive UGen applies f(x) = x^3 / (1 + abs(x^3)) waveshaping function
   // to the "in"put signal and output to "out".

   Gain in; Gain out; // chuck or unchuck this to the outside world to connect;

   // prepare input ^ 3
   in => Gain CubeOfInput;
   in => Gain inDummy1 => CubeOfInput;
   in => Gain inDummy2 => CubeOfInput;
   3 => CubeOfInput.op;

   // prepare abs(input ^ 3)
   CubeOfInput => FullRect Abs;

   // prepare 1 + abs(input ^ 3) .. to be used as the "divisor"
   Step one => Gain divisor;
   1.0 => one.next;
   Abs => divisor;

   // calculate input^3 / (1 + abs(input ^ 3)) and send to "out"
   CubeOfInput => out;
   divisor => out;
   4 => out.op; // <-- make out do a division of the inputs
}

SawOsc osc1 => BPF bpf1 => Gain oscs;
SawOsc osc2 => BPF bpf2 => oscs;
SawOsc osc3 => BPF bpf3 => oscs;
SawOsc osc4 => BPF bpf4 => oscs;

[osc1,osc2,osc3,osc4] @=> SawOsc oscS[];
[bpf1,bpf2,bpf3,bpf4] @=> BPF bpfS[];

oscs => JCRev rev => Delay d => Envelope envs => dac;
d => Gain fbk => d;

Overdrive od;
TriOsc tris => od.in;
od.out => Envelope envt => dac;

0 => tris.gain;

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
0.5 => float volume;
0 => int chordno;
1 => int thickness ; // level: 1 - 4
0 => int overdrive;


[4,2,1] @=> int lasts[];
0 => int density;

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

        for ( 0=> int i ; i < thickness; i++){
            chords[chordno][currentBar][i]  + 48 => int note;
            note => Std.mtof => oscS[i].freq;
            note => Std.mtof => bpfS[i].freq;
            gains[i] * volume => oscS[i].gain;
        }
    } else {
        chords[chordno][currentBar][0] + 48 => int note;
        note => Std.mtof => tris.freq;
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
            /*
            if (msg.ascii == 32) { // space
                if (msg.isButtonDown()) {
                    play();
                } else {
                    stop();
                }
            }
            */
            // thickness
            /*
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
            } 

            */
            if (msg.ascii ==81){ //Q
                if (msg.isButtonDown()){
                    if(density-1 >= 0)
                        0 -=> density;
                }
            } else if (msg.ascii == 87){ //W
                if (msg.isButtonDown()){
                    if(density+1 <= 4 )
                        1 +=> density;
                }
            } 
            else if (msg.ascii == 90) { // Z
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
                0.6 => tris.gain;
            }
        }
    }
}


fun void runBar() {
    while (true) {
        for (int i; i < 8; ++i) {
            i => currentBar;
            //2::second => now;
            //stop();
            4 => int q;
            2::second => dur total;
            while(q > 0 ) {
                Math.random2(0,3) => int pick;
                chords[chordno][currentBar][pick] + Math.random2(0,1)*12 + 48 => int note;
                note  => Std.mtof => oscS[0].freq;
                note => Std.mtof => bpfS[0].freq;
                gains[0] * volume => oscS[0].gain;
                getEnv().keyOn();
                int l;
                if (density == 0) {0 => l;}
                else if (density ==1) {Math.random2(0,1)=> l;}
                else if (density ==2) {Math.random2(0,2)=> l;}
                else if (density ==3 ) {Math.random2(1,2)=> l;}
                else if (density ==4 ) {Math.random2(2,2)=> l;}


                int last;
                if (lasts[l] >q)  q => last;
                else lasts[l] => last;
                last -=> q;
                
                last*500::ms => now; //last smallest 200 2, largest 4
                getEnv().keyOff();

                //last -=> total;
            }


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
            stop();
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

    //<<<" [Q] [W] Thickness:", thickness>>>;
    <<<" [Q] [W] Density:", density>>>;
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
