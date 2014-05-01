1::second => dur period;
.0000 => float vol;
2=> int base_note;// not use
[1.0, .5,.25,0.125] @=> float staccatos[];


0 => int staccato;

1::second => dur sec;

fun void print() {
    <<<"\033[5ANow:       ", now / sec >>>;
    <<<"Staccato:  ", staccato >>>;
    <<<"Period:    ", period >>>;
    <<<"Tone:      ", base_note >>>;
    <<<"Vol:       ", vol >>>;
}

fun void printLoop() {
    while (true) {
        print();
        100::ms => now;
    }
}

fun void getKeyboard() {
    KBHit kb;

    <<<"[1] [2] =>", " Staccato [UP] [DOWN]">>>;
    <<<"[Q] [W] =>", " Speed    [UP] [DOWN]">>>;
    <<<"[A] [S] =>", " Tone     [UP] [DOWN]">>>;
    <<<"[Z] [X] =>", " Vol      [UP] [DOWN]">>>;

    <<<"", "">>>;
    <<<"", "">>>;
    <<<"", "">>>;
    <<<"", "">>>;
    <<<"", "">>>;
    <<<"", "">>>;
    print();

    while (true) {
        kb => now;

        while (kb.more()) {

            kb.getchar() => int c;
            if (c == 49) {
                if (staccato + 1 < 4)
                    1 +=>  staccato;;
            } else if (c == 50 ) {
                if (staccato - 1 >=0)
                    1 -=>  staccato;;
            } else if (c == 113) { // Q
				if (period-0.25::second>=0::second)
                	.25::second -=> period;
            } else if (c == 119) { // W
                .25::second +=> period;
            } else if (c == 97)  { // A
                1 +=> base_note;
            } else if (c == 115) { // S
                1 -=> base_note;
            } else if (c == 122) { // Z
                vol + 0.005 => vol;
            } else if (c == 120) { // X
                vol - 0.005 => vol;
            }
        }
        print();
    }
}

fun void bell (float p )
{
    TriOsc s => Envelope e => JCRev r=>dac;
    [ 0, 7, 9, 11 ] @=> int hi[];
    1 => r.mix;
    .1::second => e.duration;



    while(true){
        vol => s.gain;
        Std.mtof(hi[Math.random2(0,3)]+Math.random2(base_note,base_note+1)*12 +48) => s.freq;
        e.keyOn();
        if(Math.random2f(0,1) < 0.5){
            period*staccatos[staccato] => now;
            e.keyOff();
            period*(1.0-staccatos[staccato]) => now;
        }
        else {
             .5*period*staccatos[staccato]=> now;
             e.keyOff();
             .5*period*(1.0-staccatos[staccato]) => now;
        }


}
}
spork ~ getKeyboard();
spork ~ printLoop();
spork ~ bell(1.0);
//1.5 ::second => now;
//spork ~ bell(0.5);
while(true) 1::second => now;
//wwwwwwwwwww
