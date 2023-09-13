import("stdfaust.lib");
freq = hslider("freq", 250, 20, 1000, .1) : si.smoo;
gain = hslider("gain", .1, 0, 1.5, 0.01) : si.smoo; 
m2s = _ <: _,_;
dist1(g) = max(g, 1), _ : * : ma.tanh; 
dist2(g) = max(g, 1) : ma.tanh;
dist(g) = dist1(g), dist2(g) : / : fi.dcblocker;
drive = hslider("drive", 1, 1, 100, 0.01) : si.smoo;
source = _ ;
// source = os.oscsin(freq); 
// source = os.triangle(freq); 
// source = os.sawtooth(freq);
filtf = hslider("filter_freq", 0.01, 0, 1, 0.001) : si.smoo;
filtq = hslider("filter_Q", 0.5, 0.5, 20, 0.1) : si.smoo;
byp = checkbox("bypass");

process = source : dist(drive) * gain <: ve.oberheimLPF(filtf,filtq), _ : select2(byp) : m2s;