#define MUSICIAN_HEARCHECK_MINDELAY 4
#define MUSIC_MAXLINES 1000
#define MUSIC_MAXLINECHARS 300

#define BPM_TO_TEMPO_SETTING(value) (600 / round(value, 1))

//Return values of song/should_stop_playing()

///When the song should stop being played
#define STOP_PLAYING 1
///Will ignore the instrument checks and play the song anyway.
#define IGNORE_INSTRUMENT_CHECKS 2

///it's what monkeys play!
#define MONKEY_SONG "BPM: 200\nC4/0,14,C,A4-F2,F3,A3,F-F2,A-F,F4,G4,F,D4-Bb2-G2\nD3,G3,D-G2,G3-G2,D,D4-G3,D,B4-B2,G,B3,G-B2,B3-B2\nG4,A4,G,E4-C3,E3,G3,E-C,G-C,E,E4-G,E,C5-E-A3,C4\nA-E3,C,E4-C3,A4-C4,B4-A3-A2,C5-C4,D5-F-B3,D4,B-F3\nD,F4-D3,D4,F-B-B2,G4-D,A4-C-F3,F,C/2,B3/2,A3-C3/2\nB/2,C4,E-C3,F4,G-C,F-F3,F-C,C4/2,B/2,A-A2/2,G3/2\nF/I"
