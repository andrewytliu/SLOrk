[0, 2, 4, 5, 7, 9, 11] @=> int major[];
[0, 2, 3, 5, 7, 8, 10] @=> int minor[];
[0, 2, 4, 6, 8, 10] @=> int full[];
[0, 2, 4, 7, 9] @=> int penta[];

TriOsc s => ADSR a => JCRev rev => dac;
a.set(100::ms, 10::ms, 0.3, 20::ms);
//Std.mtof(base_note + 30) => lpf.freq;

250::ms => dur period;
0 => int movement;
0.0 => s.gain;
60 => int base_note;

[[1.0,1.0,1.0,1.0], [1.5,0.5,1.5,0.5],
 [0.5,1.5,0.5,1.5], [0.5,0.5,0.5,2.5]] @=> float pattern[][];
[0, 1, 2, 4] @=> int patch[];

fun void print() {
    <<<"\033[3APeriod: ", period >>>;
    <<<"Note:   ", base_note >>>;
    <<<"Vol:    ", s.gain()>>>;
}

fun void getKeyboard(int scale[]) {
    KBHit kb;

    <<<"[Q] [W] =>", " Speed [UP] [DOWN]">>>;
    <<<"[A] [S] =>", " Base  [UP] [DOWN]">>>;
    <<<"[Z] [X] =>", " Vol   [UP] [DOWN]">>>;
    <<<"[D] [F] =>", " Oct   [UP] [DOWN]">>>;
    <<<"", "">>>;
    <<<"", "">>>;
    <<<"", "">>>;
    <<<"", "">>>;
    print();

    while (true) {
        kb => now;

        while (kb.more()) {
            kb.getchar() => int c;
            if (c == 113) { // Q
                10::ms -=> period;
            } else if (c == 119) { // W
                10::ms +=> period;
            } else if (c == 97)  { // A
                if (movement == scale.cap() - 1) {
                    12 - scale[movement] +=> base_note;
                } else {
                    scale[movement + 1] - scale[movement] +=> base_note;
                }
                //scale[movement] +=> base_note;
                (movement + 1) % scale.cap() => movement;
            } else if (c == 115) { // S
                if (movement > 0) {
                    scale[movement] - scale[movement - 1] -=> base_note;
                } else {
                    12 - scale[scale.cap() - 1] -=> base_note;
                }
                (movement + scale.cap() - 1) % scale.cap() => movement;
            } else if (c == 122) { // Z
                s.gain() + 0.05 => s.gain;
            } else if (c == 120) { // X
                s.gain() - 0.05 => s.gain;
            } else if (c == 100)  { // D
                12 +=> base_note;
            } else if (c == 102) { // F
                12 -=> base_note;
            }
            print();
        }
    }
}

fun void evolvePatch(int scale[]) {
    Math.random2(0, patch.cap()-1) => int which;
    int r;

    while (true) {
        Math.random2(0, scale.cap()-1) => r;
        if (r == patch[which]) continue;
        if (patch[(which + patch.cap() - 1) % patch.cap()] == r) continue;
        if (patch[(which + patch.cap() + 1) % patch.cap()] == r) continue;
        r => patch[which];
        break;
    }
}

fun void playScale(int scale[]) {
    while (true) {
        for (int j; j < 2; j++) {
            for (int i; i < 4; i++) {
                scale[patch[i]] + base_note => Std.mtof => s.freq;
                a.keyOn();
                period * pattern[0][i] => now;
            }
        }
        //Math.random2(0, major.cap()-1) => patch[Math.random2(0, patch.cap()-1)];
        evolvePatch(scale);
    }
}

spork ~ getKeyboard(major);
playScale(major);
