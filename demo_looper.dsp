
import("stdfaust.lib");

length = hslider("duration", 1, .5, 3, 0.1);
tableSize = 48000;
recIndex = (+(1) : %(tableSize)) ~ *(enve > 0);
readIndex = readSpeed/float(ma.SR) : (+ : ma.frac) ~ _ : *(float(tableSize)) : int;
readIndexReverse = readSpeed/float(ma.SR) : (- : ma.frac) ~ _ : *(float(tableSize)) : int;
readSpeed = hslider("[0]Read Speed",1,0.1,10,0.01);
record = button("[1]Sample") : int;

// os.lf_sawpos_phase_reset//
trigger = ba.pulsen(tableSize*.99, tableSize) : si.smoo;
enve = en.asr (0.1, 1, 0.9, record);
looper = rwtable(tableSize,0.0,recIndex,_,readIndex) ;
looperrev = rwtable(tableSize,0.0,recIndex,_,readIndexReverse) ;
rev = checkbox("[2]Reverse");
// rev_trig = ba.pulsen(tableSize, tableSize*2);// : si.smoo;//

// process = *(enve) : looper <: _,_;

process = *(enve) <: ba.selectmulti(ma.SR/10,(looper, looperrev),rev) : *(trigger) <: _,_;


