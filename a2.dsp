import("stdfaust.lib"); // a phasor
pha(f, deg) = os.lf_sawpos_phase(f, deg);
pulse_wave_mod(a) = -(0.5) : * (0.5) : *(2*ma.PI*a) : 0, cos : max;
// Miller Puckette pp. 154
// a := modulation index or duty cycle
// when a = 1 this is the von Hann window
// when a > 1 then the positive wave period is compressed pulse_wave_mod(a) = -(0.5) : * (0.5) : *(2*ma.PI*a) : 0, cos : max;
gain = hslider("gain", 0.1, 0., 1., 0.01) : si.smoo;
freq = hslider("freq", 100, 20, 1000, 0.1) : si.smoo;
mod = hslider("mod", 2, 1, 200, 0.01) : si.smoo;
// the result is a pulse wave with wavetable stretching by Miller // the signal is driven by a phasor
//Pulse1 =
 
 /********************************************
*
*Pulse wave Ring Modulation
*
*********************************************/


//pulse2
pha2(f, deg) = os.lf_sawpos_phase(f, deg);
// Miller Puckette pp. 154
// a := modulation index or duty cycle, note the half wave rectification // when a = 1 this is the von Hann window
// when a > 1 then the wave period is compressed
pulse_wave(b) = -(0.5) : * (0.5) : *(2*ma.PI*b) : 0, cos : max;
// a cosine generator that can be driven by a phasor with output range [0 ... 1]
coswav(f) = *(2*ma.PI*f) : cos ;

gainRing = hslider("gainRingModular", 0.1, 0., 1., 0.01) : si.smoo; 
freqR = hslider("freqRingModular", 100, 20, 1000, 0.1) : si.smoo; 
modR = hslider("modRingModular", 2, 1, 40, 0.01) : si.smoo; 
 
// ring-modulated pulsetrain for formant generation
harm = hslider("harmRingModular", 1, 1, 20, .1) : si.smoo;
//process = pha(freq,0) : pulse_wave_mod(mod) : *(gain) ;
pulseWave1 = hgroup("0.PulseWaveStrecting",pha(freq,0) : pulse_wave_mod(mod) : *(gain)) ;
pulseWave2 = hgroup("0.PulseWaveRingModular",pha2(freqR ,0) <: pulse_wave(modR), coswav(harm) :> * : *(gainRing));
mixer = pulseWave1 + pulseWave2 ;
/********************************************
*
*MODE FILTER
*
*********************************************/
modeFilter(f,t60) = fi.tf21(b0,b1,b2,a1,a2) with{ b0 = 1;
b1 = 0;
b2 = -1;
w = 2*ma.PI*f/ma.SR;
r = pow(0.001,1/float(t60*ma.SR)); a1 = -2*r*cos(w);
a2 = r^2;
};
mode(f,t60,gainMOD) = modeFilter(f,t60)*gainMOD;
gatMOD = checkbox("MODFILTER: On/Off") ;
freqMOD = hslider("MODFILTER: freq", 300, 20, 4000, 5) : si.smoo; 
gainMOD = hslider("MODFILTER: gain", 0.0004, 0, .02, 0.0001) ;
bw = hslider("MODFILTER: bandwidth", 1, 0.5, 20, 0.1) : si.smoo;
ratio1 = hslider("ratio1[style:knob]", 1.1, 0.1, 5, 0.01) : si.smoo; 
ratio2 = hslider("ratio2[style:knob]", 1.9, 0.1, 5, 0.01) : si.smoo; 
ratio3 = hslider("ratio3[style:knob]", 3.3, 0.1, 5, 0.01) : si.smoo;
mute = *(1-checkbox("mute"));
//MDF =  : select2(gat, _) ;
test =  _ <: _, _ : fi.resonlp(freqMOD, bw, 1), fi.resonlp(freqMOD*2, bw, 1):> route(1,4,1,1,1,2,1,3,1,4) : mode(freqMOD, 2.2, 1), mode(freqMOD*ratio1, 2.2, 1), mode(freqMOD*ratio2, 4, 1), mode(freqMOD*ratio3, 3, 1) : route(4,1,1,1,2,1,3,1,4,1) : * (gainMOD) : aa.hardclip2 ;
MODFilter = hgroup("1.MODFILTER", _ <: _, test : select2(gatMOD)) ;
//process =   test;
/******************************************************
*
*Distortion
*
*******************************************************/
freqDist = hslider("freq", 250, 20, 1000, .1) : si.smoo;
gainDist = hslider("gain", .1, 0, 1.5, 0.01) : si.smoo; 
m2s = _ <: _,_;
dist1(g) = max(g, 1), _ : * : ma.tanh; 
dist2(g) = max(g, 1) : ma.tanh;
dist(g) = dist1(g), dist2(g) : / : fi.dcblocker;
drive = hslider("drive", 1, 1, 100, 0.01) ;
source = _ ;
// source = os.oscsin(freq); 
// source = os.triangle(freq); 
// source = os.sawtooth(freq);
filtf = hslider("filter_freq", 0.5, 0, 1, 0.001) ;
filtq = hslider("filter_Q", 10, 0.5, 20, 0.1) ;
byp = checkbox("DISTORTION");

DISTORTION = hgroup("2.DiSRORTION", _ : dist(drive)*gainDist  <: _ , ve.oberheimLPF(filtf,filtq) : select2(byp)) ;
// process = DISTORTION ;
/*************************************************************************************
*
*
*ADSR
*
*
*
**************************************************************************************/
sourceADSR = _;
btn = button("ADSR ON/OFF") ;
envelope(att, dec, sus, rel, gat, ind) = en.adsre(att, dec, sus, gat, rel) * ind;
op(source, att, dec, sus, rel, gat, ind) = sourceADSR <: _,  envelope(att, dec, sus, rel,gt , ind)*mod_ratio_1*_ : select2(btn);

// button to trigger the EG
gt = checkbox("dummy");

// setting the fundamental frequency of the carrier op
freqADSR = hslider("c_freq", 200, 20, 2000, 0.01);

// setting the modulation frequency by a factor, the modulation ratio
mod_ratio_1 = hslider("m_ratio_1", 2., 0.01, 10, 0.01);
// setting the modulation index, i.e. the gain of the modulator output
mod_index_1 = hslider("m_index_1", 500., 1., 2000, 0.01);

A_c = vslider("h:operator_1/[0]A_c[style:knob]",0.3,0.,10.,0.1);
D_c = vslider("h:operator_1/[1]D_c[style:knob]",1.,0.,10.,0.1);
S_c = vslider("h:operator_1/[2]S_c[style:knob]",0.3,0.,1.,0.1);
R_c = vslider("h:operator_1/[3]R_c[style:knob]",2.,0.,10.,0.1);
gainADSR = hslider("Gain", .35, 0, 1.5, 0.01) : si.smoo;
ADSR =  hgroup("3.ADSR" , op(_,A_c, D_c, S_c, R_c, gt, mod_index_1))  ;

// setting the modulation frequency by a factor, the modulation ratio
mod_ratio_2 = hslider("m_ratio_2", 2., 0.01, 10, 0.01);
// setting the modulation index, i.e. the gain of the modulator output
mod_index_2 = hslider("m_index_2", 500., 1., 2000, 0.01);

/*****************************************************************
*
*
*reverB
*
*
*******************************************************************/
freqRE = hslider("freq", 250, 20, 1000, .1) : si.smoo;
gainRE = hslider("gain", .35, 0, 1.5, 0.01) : si.smoo; 
//m2s = _ <: _,_;
distt1(gg) = max(gg, 1), _ : * : ma.tanh; 
distt2(gg) = max(gg, 1) : ma.tanh;
distt(gg) = distt1(gg), distt2(gg) : / : fi.dcblocker;
drivee = hslider("drive", 13, 1, 100, 0.01) : si.smoo;
sourcee = _ ;
// source = os.oscsin(freq); 
// source = os.triangle(freq); 
// source = os.sawtooth(freq);
filtff = hslider("filter_freq", 0.01, 0, 1, 0.001) : si.smoo;
filtqq = hslider("filter_Q", 0.5, 0.5, 20, 0.1) : si.smoo;
bypp = checkbox("ReverB ON/OFF");

// process = source : dist(drive) * gain <: ve.oberheimLPF(filtf,filtq), _ : select2(byp) : m2s;

reverbb =  _ : distt(drivee) * gainRE <: dm.freeverb_demo :> _ ;
freeREVERB = hgroup("5.ReverB", _ <: _, reverbb : select2(bypp)) ;
//process = freeREVERB ;
stereo = _ <: _, _;
//process = freeREVERB ;
process = mixer : MODFilter : DISTORTION : ADSR : freeREVERB : stereo ;
