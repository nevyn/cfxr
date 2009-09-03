//
//  Playback.h
//  cfxr
//
//  Created by Joachim Bengtsson on 2008-05-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Sound.h"

@protocol PlaybackDelegate;

@interface Playback : NSObject {
	
		
	bool filter_on;

	bool playing_sample;
	int phase;
	double fperiod;
	double fmaxperiod;
	double fslide;
	double fdslide;
	int period;
	float square_duty;
	float square_slide;
	int env_stage;
	int env_time;
	int env_length[3];
	float env_vol;
	float fphase;
	float fdphase;
	int iphase;
	float phaser_buffer[1024];
	int ipp;
	float noise_buffer[32];
	float fltp;
	float fltdp;
	float fltw;
	float fltw_d;
	float fltdmp;
	float fltphp;
	float flthp;
	float flthp_d;
	float vib_phase;
	float vib_speed;
	float vib_amp;
	int rep_time;
	int rep_limit;
	int arp_time;
	int arp_limit;
	double arp_mod;
	
	float* vselected;
	
	
	int file_sampleswritten;
	float filesample;
	int fileacc;

	bool mute_stream;
	
	float masterVolume;
	
	Sound *ps;
	
	id<NSObject, PlaybackDelegate> delegate;
}
+(Playback*)playback;

-(void)play:(Sound*)sound;
-(BOOL)export:(Sound*)sound to:(NSString*)path error:(NSError**)error;

@property (retain) Sound *playingSound;
@property (assign) id<NSObject, PlaybackDelegate> delegate;

@property (assign) float masterVolume;
@end



@protocol PlaybackDelegate
-(void)playbackStoppedPlaying:(Playback*)playback_;
@end


