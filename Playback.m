//
//  Playback.m
//  cfxr
//
//  Created by Joachim Bengtsson on 2008-05-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "Playback.h"

#import <SDL/SDL.h>
#import "common.h"

static Playback *playback;

#define ResetSample(restart) [self resetSample:restart]
#define PlaySample() [self playSample]
#define SynthSample(l, b, f) [self synthSample:l:b:f]
#define ExportWAV(f) [self exportWAV:f]

@interface Playback() 
-(void)resetSample:(bool) restart;
-(void)playSample;
-(void) synthSample:(int)length :(float*)buffer :(FILE*)file;
-(bool)exportWAV:(NSString*)path error:(NSError**)error;

@property bool playing_sample;
@end

@implementation Playback

+(void)initialize;
{
	playback = [[Playback alloc] init];

}

+(Playback*)playback;
{
	return playback;
}

static void SDLAudioCallback(Playback* userdata, Uint8 *stream, int len);

-(id)init;
{
	if(![super init]) return nil;
	
	masterVolume = 0.05;
	
	SDL_AudioSpec des;
	des.freq = 44100;
	des.format = AUDIO_S16SYS;
	des.channels = 1;
	des.callback = (void (*)(void *, Uint8 *, int))SDLAudioCallback;
	des.userdata = self;
	des.samples = 2048;
	if(SDL_OpenAudio(&des, NULL)) {
		NSLog(@"Failed opening audio device");
		[self release]; return nil;
	}
	SDL_PauseAudio(0);
	
	return self;
}


-(Sound*)playingSound; { return ps; };
-(void)setPlayingSound:(Sound*)newPs; {
	[newPs retain]; [ps release]; ps = newPs;
	
}

-(void)play:(Sound*)sound;
{
	self.playingSound = sound;
	PlaySample();
}
-(BOOL)export:(Sound*)sound to:(NSString*)path error:(NSError**)error;
{
	self.playingSound = sound;
	return [self exportWAV:path error:error];
}

@synthesize masterVolume;

-(void)resetSample:(bool) restart;
{
	if(!ps) return;
	
	if(!restart)
		phase=0;
	fperiod=100.0/(ps.p_base_freq*ps.p_base_freq+0.001);
	period=(int)fperiod;
	fmaxperiod=100.0/(ps.p_freq_limit*ps.p_freq_limit+0.001);
	fslide=1.0-pow((double)ps.p_freq_ramp, 3.0)*0.01;
	fdslide=-pow((double)ps.p_freq_dramp, 3.0)*0.000001;
	square_duty=0.5f-ps.p_duty*0.5f;
	square_slide=-ps.p_duty_ramp*0.00005f;
	if(ps.p_arp_mod>=0.0f)
		arp_mod=1.0-pow((double)ps.p_arp_mod, 2.0)*0.9;
	else
		arp_mod=1.0+pow((double)ps.p_arp_mod, 2.0)*10.0;
	arp_time=0;
	arp_limit=(int)(pow(1.0f-ps.p_arp_speed, 2.0f)*20000+32);
	if(ps.p_arp_speed==1.0f)
		arp_limit=0;
	if(!restart)
	{
		// reset filter
		fltp=0.0f;
		fltdp=0.0f;
		fltw=pow(ps.p_lpf_freq, 3.0f)*0.1f;
		fltw_d=1.0f+ps.p_lpf_ramp*0.0001f;
		fltdmp=5.0f/(1.0f+pow(ps.p_lpf_resonance, 2.0f)*20.0f)*(0.01f+fltw);
		if(fltdmp>0.8f) fltdmp=0.8f;
		fltphp=0.0f;
		flthp=pow(ps.p_hpf_freq, 2.0f)*0.1f;
		flthp_d=1.0+ps.p_hpf_ramp*0.0003f;
		// reset vibrato
		vib_phase=0.0f;
		vib_speed=pow(ps.p_vib_speed, 2.0f)*0.01f;
		vib_amp=ps.p_vib_strength*0.5f;
		// reset envelope
		env_vol=0.0f;
		env_stage=0;
		env_time=0;
		env_length[0]=(int)(ps.p_env_attack*ps.p_env_attack*100000.0f);
		env_length[1]=(int)(ps.p_env_sustain*ps.p_env_sustain*100000.0f);
		env_length[2]=(int)(ps.p_env_decay*ps.p_env_decay*100000.0f);
		
		fphase=pow(ps.p_pha_offset, 2.0f)*1020.0f;
		if(ps.p_pha_offset<0.0f) fphase=-fphase;
		fdphase=pow(ps.p_pha_ramp, 2.0f)*1.0f;
		if(ps.p_pha_ramp<0.0f) fdphase=-fdphase;
		iphase=abs((int)fphase);
		ipp=0;
		for(int i=0;i<1024;i++)
			phaser_buffer[i]=0.0f;
		
		for(int i=0;i<32;i++)
			noise_buffer[i]=frnd(2.0f)-1.0f;
		
		rep_time=0;
		rep_limit=(int)(pow(1.0f-ps.p_repeat_speed, 2.0f)*20000+32);
		if(ps.p_repeat_speed==0.0f)
			rep_limit=0;
	}
}

-(void)playSample;
{
	ResetSample(false);
	self.playing_sample=true;
}

-(void) synthSample:(int)length :(float*)buffer :(FILE*)file;
{
	if(!ps) return;
	
	for(int i=0;i<length;i++)
	{
		if(!self.playing_sample)
			break;
		
		rep_time++;
		if(rep_limit!=0 && rep_time>=rep_limit)
		{
			rep_time=0;
			ResetSample(true);
		}
		
		// frequency envelopes/arpeggios
		arp_time++;
		if(arp_limit!=0 && arp_time>=arp_limit)
		{
			arp_limit=0;
			fperiod*=arp_mod;
		}
		fslide+=fdslide;
		fperiod*=fslide;
		if(fperiod>fmaxperiod)
		{
			fperiod=fmaxperiod;
			if(ps.p_freq_limit>0.0f)
				self.playing_sample=false;
		}
		float rfperiod=fperiod;
		if(vib_amp>0.0f)
		{
			vib_phase+=vib_speed;
			rfperiod=fperiod*(1.0+sin(vib_phase)*vib_amp);
		}
		period=(int)rfperiod;
		if(period<8) period=8;
		square_duty+=square_slide;
		if(square_duty<0.0f) square_duty=0.0f;
		if(square_duty>0.5f) square_duty=0.5f;		
		// volume envelope
		env_time++;
		if(env_time>env_length[env_stage])
		{
			env_time=0;
			env_stage++;
			if(env_stage==3)
				self.playing_sample=false;
		}
		if(env_stage==0)
			env_vol=(float)env_time/env_length[0];
		if(env_stage==1)
			env_vol=1.0f+pow(1.0f-(float)env_time/env_length[1], 1.0f)*2.0f*ps.p_env_punch;
		if(env_stage==2)
			env_vol=1.0f-(float)env_time/env_length[2];
		
		// phaser step
		fphase+=fdphase;
		iphase=abs((int)fphase);
		if(iphase>1023) iphase=1023;
		
		if(flthp_d!=0.0f)
		{
			flthp*=flthp_d;
			if(flthp<0.00001f) flthp=0.00001f;
			if(flthp>0.1f) flthp=0.1f;
		}
		
		float ssample=0.0f;
		for(int si=0;si<8;si++) // 8x supersampling
		{
			float sample=0.0f;
			phase++;
			if(phase>=period)
			{
				//				phase=0;
				phase%=period;
				if(ps.wave_type==3)
					for(int i=0;i<32;i++)
						noise_buffer[i]=frnd(2.0f)-1.0f;
			}
			// base waveform
			float fp=(float)phase/period;
			switch(ps.wave_type)
			{
				case 0: // square
					if(fp<square_duty)
						sample=0.5f;
					else
						sample=-0.5f;
					break;
				case 1: // sawtooth
					sample=1.0f-fp*2;
					break;
				case 2: // sine
					sample=(float)sin(fp*2*M_PI);
					break;
				case 3: // noise
					sample=noise_buffer[phase*32/period];
					break;
			}
			// lp filter
			float pp=fltp;
			fltw*=fltw_d;
			if(fltw<0.0f) fltw=0.0f;
			if(fltw>0.1f) fltw=0.1f;
			if(ps.p_lpf_freq!=1.0f)
			{
				fltdp+=(sample-fltp)*fltw;
				fltdp-=fltdp*fltdmp;
			}
			else
			{
				fltp=sample;
				fltdp=0.0f;
			}
			fltp+=fltdp;
			// hp filter
			fltphp+=fltp-pp;
			fltphp-=fltphp*flthp;
			sample=fltphp;
			// phaser
			phaser_buffer[ipp&1023]=sample;
			sample+=phaser_buffer[(ipp-iphase+1024)&1023];
			ipp=(ipp+1)&1023;
			// final accumulation and envelope application
			ssample+=sample*env_vol;
		}
		ssample=ssample/8*masterVolume;
		
		ssample*=2.0f*ps.sound_vol;
		
		if(buffer!=NULL)
		{
			if(ssample>1.0f) ssample=1.0f;
			if(ssample<-1.0f) ssample=-1.0f;
			*buffer++=ssample;
		}
		if(file!=NULL)
		{
			// quantize depending on format
			// accumulate/count to accomodate variable sample rate?
			ssample*=4.0f; // arbitrary gain to get reasonable output volume...
			if(ssample>1.0f) ssample=1.0f;
			if(ssample<-1.0f) ssample=-1.0f;
			filesample+=ssample;
			fileacc++;
			if(ps.wav_freq==44100 || fileacc==2)
			{
				filesample/=fileacc;
				fileacc=0;
				if(ps.wav_bits==16)
				{
					short isample=(short)(filesample*32000);
					fwrite(&isample, 1, 2, file);
				}
				else
				{
					unsigned char isample=(unsigned char)(filesample*127+128);
					fwrite(&isample, 1, 1, file);
				}
				filesample=0.0f;
			}
			file_sampleswritten++;
		}
	}
}


-(void)audioCallback:(Uint8 *)stream :(int)len;
{
	if (self.playing_sample && !mute_stream)
	{
		unsigned int l = len/2;
		float fbuf[l];
		memset(fbuf, 0, sizeof(fbuf));
		SynthSample(l, fbuf, NULL);
		while (l--)
		{
			float f = fbuf[l];
			if (f < -1.0) f = -1.0;
			if (f > 1.0) f = 1.0;
			((Sint16*)stream)[l] = (Sint16)(f * 32767);
		}
	}
	else memset(stream, 0, len);		
}
static void SDLAudioCallback(Playback *playback, Uint8 *stream, int len)
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[playback audioCallback:stream:len];
    [pool release];
}


-(bool)exportWAV:(NSString*)path error:(NSError**)error;
{
	if( ! [@"" writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:error]) return NO;
	
	//NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path];
	FILE *foutput = fopen([path UTF8String], "wb");//(FILE*)[fh fileDescriptor];
	if(/*!fh ||*/ !foutput) {
		if(error)
			*error = CfxrMakeError(1, [NSString stringWithFormat:@"Failed to export file because the file %@ couldn't be opened", path], @"Try selecting another file name");
		return false;
	}
	// write wav header
	unsigned int dword=0;
	unsigned short word=0;
	fwrite("RIFF", 4, 1, foutput); // "RIFF"
	dword=0;
	fwrite(&dword, 1, 4, foutput); // remaining file size
	fwrite("WAVE", 4, 1, foutput); // "WAVE"
	
	fwrite("fmt ", 4, 1, foutput); // "fmt "
	dword=16;
	fwrite(&dword, 1, 4, foutput); // chunk size
	word=1;
	fwrite(&word, 1, 2, foutput); // compression code
	word=1;
	fwrite(&word, 1, 2, foutput); // channels
	dword=ps.wav_freq;
	fwrite(&dword, 1, 4, foutput); // sample rate
	dword=ps.wav_freq*ps.wav_bits/8;
	fwrite(&dword, 1, 4, foutput); // bytes/sec
	word=ps.wav_bits/8;
	fwrite(&word, 1, 2, foutput); // block align
	word=ps.wav_bits;
	fwrite(&word, 1, 2, foutput); // bits per sample
	
	fwrite("data", 4, 1, foutput); // "data"
	dword=0;
	int foutstream_datasize=ftell(foutput);
	fwrite(&dword, 1, 4, foutput); // chunk size
	
	// write sample data
	mute_stream=true;
	file_sampleswritten=0;
	filesample=0.0f;
	fileacc=0;
	PlaySample();
	while(self.playing_sample)
		SynthSample(256, NULL, foutput);
	mute_stream=false;
	
	// seek back to header and write size info
	fseek(foutput, 4, SEEK_SET);
	dword=0;
	dword=foutstream_datasize-4+file_sampleswritten*ps.wav_bits/8;
	fwrite(&dword, 1, 4, foutput); // remaining file size
	fseek(foutput, foutstream_datasize, SEEK_SET);
	dword=file_sampleswritten*ps.wav_bits/8;
	fwrite(&dword, 1, 4, foutput); // chunk size (data)
	fclose(foutput);
	
	return true;
}


@synthesize playing_sample, delegate;
-(void)setPlaying_sample:(bool)becomes;
{
	bool was = playing_sample;
	playing_sample = becomes;
	if(was && !becomes)
		[delegate playbackStoppedPlaying:self];
}

@end
