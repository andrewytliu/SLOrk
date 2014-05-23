// Sounds so good with Sqr Tri and Sin !! 

SinOsc signal => Gain one; 
signal => Gain two; 

.75 => one.gain; 
1.0 - one.gain() => two.gain; 

one => SqrOsc overdrive => LPF lpf => dac; 
two => TriOsc od2 => lpf => dac; 



1 => overdrive.sync; // set sync option to Phase Mod. 
1 => od2.sync; 

1 => signal.gain; 
48 =>signal.freq; 

SinOsc roller => blackhole; 

2 => roller.sync; 
10 => roller.gain; 
3.147 => roller.freq; 

signal => roller; 

72 => lpf.freq; 

while (true) { 
    lpf.freq() + roller.last() => lpf.freq; 
    4::ms => now; 
    if (Std.rand2f(0.,1.) < .005) { 
        change() => signal.freq;    
    } 
} 

fun float change () { 
    Std.rand2f(0.,1.) => float rand; 
    
    if ( rand < 0.4 ) { 
        return 48.0; 
    } else if ( rand < 0.8 ) { 
        return 37.0; 
    } else { 
        return 33.0; 
    } 
} 
