//
//  Sound+legacyAccessors.h
//  cfxr
//
//  Created by Joachim Bengtsson on 2008-05-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Sound.h"

@interface Sound (LegacyAccessors)

@property (retain) NSNumber * attackTime;
@property (retain) NSNumber * bitDepth;
@property (retain) NSNumber * changeAmount;
@property (retain) NSNumber * changeSpeed;
@property (retain) NSNumber * decayTime;
@property (retain) NSNumber * deltaSlide;
@property (retain) NSNumber * dutySweep;
@property (retain) NSNumber * highpassFilterCutoff;
@property (retain) NSNumber * highpassFilterCutoffSweep;
@property (retain) NSNumber * lowpassFilterCutoff;
@property (retain) NSNumber * lowpassFilterCutoffSweep;
@property (retain) NSNumber * lowpassFilterResonance;
@property (retain) NSNumber * minFrequencyCutoff;
@property (retain) NSNumber * waveType;
@property (retain) NSNumber * phaserOffset;
@property (retain) NSNumber * phaserSweep;
@property (retain) NSNumber * repeatSpeed;
@property (retain) NSNumber * sampleRate;
@property (retain) NSNumber * slide;
@property (retain) NSNumber * squareDuty;
@property (retain) NSNumber * startFrequency;
@property (retain) NSNumber * sustainPunch;
@property (retain) NSNumber * sustainTime;
@property (retain) NSNumber * vibratoDepth;
@property (retain) NSNumber * vibratoSpeed;
@property (retain) NSNumber * volume;
@property (retain) NSString * name;
@property (retain) NSNumber * index;
@property (retain) NSNumber * rating;


@property (assign) float sound_vol;

@property (assign) int   wave_type;		   // waveType
@property (assign) int   wav_bits;
@property (assign) int   wav_freq;
@property (assign) float p_base_freq;      // startFrequency
@property (assign) float p_freq_limit;     // minFrequencyCutoff
@property (assign) float p_freq_ramp;      // slide
@property (assign) float p_freq_dramp;     // deltaSlide
@property (assign) float p_duty;           // squareDuty
@property (assign) float p_duty_ramp;      // dutySweep

@property (assign) float p_vib_strength;   // vibratoDepth
@property (assign) float p_vib_speed;      // vibratoSpeed
//@property (assign) float p_vib_delay;    // <not used>

@property (assign) float p_env_attack;     // attackTime
@property (assign) float p_env_sustain;    // sustainTime
@property (assign) float p_env_decay;      // decayTime
@property (assign) float p_env_punch;      // sustainPunch

@property (assign) float p_lpf_resonance;  // lowpassFilterResonance
@property (assign) float p_lpf_freq;       // lowpassFilterCutoff
@property (assign) float p_lpf_ramp;       // lowpassFilterCutoffSweep
@property (assign) float p_hpf_freq;       // highpassFilterCutoff
@property (assign) float p_hpf_ramp;       // highpassFilterCutoffSweep

@property (assign) float p_pha_offset;     // phaserOffset
@property (assign) float p_pha_ramp;       // phaserSweep

@property (assign) float p_repeat_speed;   // repeatSpeed

@property (assign) float p_arp_speed;      // changeSpeed
@property (assign) float p_arp_mod;        // changeAmount

@end
