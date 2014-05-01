SinOsc s1;
SinOsc s2;
SinOsc s3;
SinOsc s4;
[s1,s2,s3,s4] @=> SinOsc  sins[] ;
//[48,55,62,76] @=> int notes[];
1 => int base;
[48,55,62,69]@=>int notes[];
[.8,.6,.4,0.2] @=> float gains[];
[ [1.0,1.0,1.0,1.0],[1.0,1.0,1.5,.5],[.75,.25,.75,.25],[.6,.2,.6,.2],[.3,.1,.3,.1]]@=> float period[][];
[1,0] @=> int tenutos[];


ADSR e1 => dac;
ADSR e2 => dac;
ADSR e3 => dac;
ADSR e4 => dac;
[e1,e2,e3,e4] @=> ADSR adsrs[];





e1.set( 10::ms, 8::ms, .5, 500::ms );
e2.set( 10::ms, 8::ms, .5, 500::ms );
e3.set( 10::ms, 8::ms, .5, 500::ms );
// set gain
e4.set( 10::ms, 8::ms, .5, 500::ms );
//s4 => ADSR e4 => JCRev j => dac;
//.3 => j.mix;

0 => int period_mode ;
.00 => float vol;
1 => int tenuto;
0 => int note_random;
0 => int base_note_change; 
// note random?
for (int i; i< 4;i++)
{
    notes[i] => Std.mtof => sins[i].freq;
    gains[i]*vol => sins[i].gain;
    sins[i] => adsrs[i];

}

1::second => dur sec;

fun void print() {
    <<<"\033[6ANow:    ", now / sec >>>;
    if (note_random == 1) {
        <<<"Random:  ON", "">>>;
    } else {
        <<<"Random:  OFF", "">>>;
    }
    <<<"Rhythm: ", period_mode>>>;
    if (tenuto == 1) {
        <<<"Tenuto:  ON", "">>>;
    } else {
        <<<"Tenuto:  OFF", "">>>;
    }
    <<<"Vol:    ", vol >>>;
    <<<"base change", base_note_change>>>;
}

fun void printLoop() {
    while (true) {
        print();
        100::ms => now;
    }
}

fun void getKeyboard() {
    KBHit kb;
    <<<"[1] [2] =>", " Random [ON] [OFF]">>>;
    <<<"[3] [4] =>", " base   [Down][Up]">>>;
    <<<"[Q] [W] =>", " Rhythm [UP] [DOWN]">>>;
    <<<"[A] [S] =>", " Tenuto [UP] [DOWN]">>>;
    <<<"[Z] [X] =>", " Vol    [UP] [DOWN]">>>;

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
                1 =>  note_random;
            }else if (c == 50 ) {
                0 =>  note_random;
            }

            else if (c == 113) { // Q
                if ( period_mode+ 1< 5)
					1 +=> period_mode;
            } else if (c == 119) { // W
                if (period_mode -1 >=0)
					1 -=> period_mode;
            } else if (c == 97)  { // A
                1 => tenuto;
            } else if (c == 115) { // S
                0 => tenuto;
            } else if (c == 122) { // Z
                vol + 0.001 => vol;
            } else if (c == 120) { // X
                vol - 0.001 => vol;
            }
            else if (c==51){
                1 -=> base_note_change;
            }else if (c==52) {
                1 +=> base_note_change;
            }
            
            
        }
        print();
    }
}

    /*

    e1.keyOn();

    2::second => now;
    e2.keyOn();


    2::second => now;
    e3.keyOn();

    2::second => now;
    e4.keyOn();

    2::second => now;
    */
fun void bass (){
    for (int i;i<4;i++){
        //Math.random2(1,3) => int chaS_index;
        //notes[chaS_index] => int cur_note;
        i => int chaS_index;
        //cur_note + Math.random2(-1,1)*2  => cur_note;
        //cur_note => notes[chaS_index];

        notes[chaS_index] => Std.mtof => sins[chaS_index].freq;
        gains[chaS_index]*vol => sins[chaS_index].gain;

        adsrs[i].keyOn();
        period[period_mode][i]::second => now;
        if(tenuto==0)
            adsrs[i].keyOff();

    }


    while(1){
        for (int i;i<4;i++){
            //Math.random2(1,3) => int chaS_index;

            i => int chaS_index;
            int cur_note;
            if (note_random ==0){
                if (i==0)
                     notes[chaS_index] + base_note_change=> cur_note;
                else
                    notes[chaS_index] => cur_note;
            }

            else
                notes[chaS_index] + Math.random2(-1,1)*2  => cur_note;
            //cur_note => notes[chaS_index];

            cur_note => Std.mtof => sins[chaS_index].freq;
            gains[chaS_index]*vol => sins[chaS_index].gain;

            adsrs[i].keyOn();

            period[period_mode][i]::second => now;
            if(tenuto==0)
                adsrs[i].keyOff();

        }


    }
}

spork ~ getKeyboard();
spork ~ printLoop();
spork ~ bass();
while(true) 1::second=>now;
