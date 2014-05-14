4 ::second => dur T;
T- (now%T) => now;

SndBuf buf => Gain g => dac;
1024 => buf.chunks;
"grandfather_clock.wav"=> buf.read;
1 => g.gain;
1.0 => float rate;
0.1 => float freq;
0.01 => float vol;
fun void clock(){
	0 => buf.pos;
    0 => buf.play;
	while(true) 
	{
    	//0=> buf.pos;
        <<<buf.pos>>>;
    	Std.rand2f(vol+.5,vol+.9) => buf.gain;
    	freq  => buf.freq;
    	rate  => buf.rate;
        2::second => now;
		//(1.0/freq)::second=> now;
        <<<"here">>>;
        <<<buf.pos>>>;
	    <<<buf.samples>>>;
    
	}
}
//rate;
//freq;
//volume;
//stop;


fun void getKeyboard() {
    KBHit kb;
    <<<"[Q] [W] =>", " Rate [DOWN] [UP]">>>;
    <<<"[A] [S] =>", " Freq [DOWN] [UP]">>>;
    <<<"[Z] [X] =>", " Vol  [DOWN] [UP]">>>;

    <<<"", "">>>;
    <<<"", "">>>;
    <<<"", "">>>;
    <<<"", "">>>;
    print();

    while (true) {
        kb => now;

        while (kb.more()) {

            kb.getchar() => int c;

            if (c == 113) { // Q rate down
                if ( rate - 0.01 >=0)
					.01 -=> rate;
            } else if (c == 119) { // W rate up
					.01 +=> rate;
            } else if (c == 97)  { // A freq down
                .01 -=> freq;
            } else if (c == 115) { // S freq up 
                .01 +=> freq;
            } else if (c == 122) { // Z volume down
                vol - 0.001 => vol;
            } else if (c == 120) { // X volume up 
                vol + 0.001 => vol;
            }
            
            
        }
        print();
    }
}
1::second => dur sec;
fun void print() {
    <<<"\033[3ANow:    ", now / sec >>>;
    <<<"Rate: ", rate>>>;
    <<<"freq: ", freq>>>;
    <<<"vol : ", vol>>>;
}


fun void printLoop() {
    while (true) {
        print();
        100::ms => now;
    }
}

spork ~ getKeyboard();
//spork ~ printLoop();
spork ~ clock();
while(true) 1::second => now;
