import("stdfaust.lib");

// This dsp patch demonstrates MIDI keyboard control //

// From the Manual:
// "Note that if you execute this code in the Faust Online IDE with polyphony mode activated, you should be able to control this simple synth with any MIDI keyboard connected to your computer. This will only work if you're using Google Chrome (most other browsers are not MIDI-compatible)."

// In Chrome connect MIDI Input on the right panel
// to the keyboard connected to the computer
// if you don't have a keyboard you can use the computer keyboard keys:
//  W E   T Y U   O P 
// A S D F G H J K L ;
// the above corresponds to a piano layout of black and white keys, one octave+
// octave changes are made by pressing either X for going an octave up
// or Z for going an octave lower
// MAKE SURE YOU CLICK INTO THE RIGHT HAND PANEL BEFORE USING THE COMP KEYBOARD FOR PLAYING MIDI NOTES !!! If you have accidentally typed into the editor expecting to send MIDI, simply undo the changes, and click with mouse outside of the editor panel.

// The Faust IDE has a control on the left panel called
// "Poly Voices"
// Poly Voices MUST BE SET TO 1 OR HIGHER ! USE 4, 8, etc. for playing chords
// the DEFAULT setting "MONO" DOES NOT work with MIDI !

// In Poly Voices mode >= 1, the parameters freq, gain, and gate are 
// automatically mapped to MIDI note, MIDI velocity, and note-on/off message 
freq = hslider("freq",200,50,1000,0.01);
gain = hslider("gain",0.2,0,1,0.01);
gate = button("gate") : si.smoo;

process = os.sawtooth(freq)*gain*gate <: _,_;