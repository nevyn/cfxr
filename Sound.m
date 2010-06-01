//
//  Sound.m
//  cfxr
//
//  Created by Joachim Bengtsson on 2008-05-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "Sound.h"
#import "common.h"

@implementation Sound
+(int)countInContext:(NSManagedObjectContext*)moc;
{
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Sound" inManagedObjectContext:moc];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
		
	NSArray *array = [moc executeFetchRequest:request error:nil];
	if (array == nil)
	{
		return 0;
	}
	return [array count];
}

+(int)highestIndexInContext:(NSManagedObjectContext*)moc;
{
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Sound" inManagedObjectContext:moc];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"index" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];

	[request setFetchLimit:1];
	
	NSArray *array = [moc executeFetchRequest:request error:nil];
	if (array == nil)
	{
		return 1;
	}
	Sound *s = [array objectAtIndex:0];
	return s.index.intValue;
}


- (void)awakeFromInsert
{
	self.index = [NSNumber numberWithInt:[Sound highestIndexInContext:[self managedObjectContext]]+1];
}
-(void)generateParamsFromCategory:(NSString*)templateName;
{
	if([@"Pickup/coin" isEqualToString:templateName]) {
		self.p_base_freq=0.4f+frnd(0.5f);
		self.p_env_attack=0.0f;
		self.p_env_sustain=frnd(0.1f);
		self.p_env_decay=0.1f+frnd(0.4f);
		self.p_env_punch=0.3f+frnd(0.3f);
		if(rnd(1))
		{
			self.p_arp_speed=0.5f+frnd(0.2f);
			self.p_arp_mod=0.2f+frnd(0.4f);
		}
	} else if([@"Laser/shoot" isEqualToString:templateName]) {
		self.wave_type=rnd(2);
		if(self.wave_type==2 && rnd(1))
			self.wave_type=rnd(1);
		self.p_base_freq=0.5f+frnd(0.5f);
		self.p_freq_limit=self.p_base_freq-0.2f-frnd(0.6f);
		if(self.p_freq_limit<0.2f) self.p_freq_limit=0.2f;
		self.p_freq_ramp=-0.15f-frnd(0.2f);
		if(rnd(2)==0)
		{
			self.p_base_freq=0.3f+frnd(0.6f);
			self.p_freq_limit=frnd(0.1f);
			self.p_freq_ramp=-0.35f-frnd(0.3f);
		}
		if(rnd(1))
		{
			self.p_duty=frnd(0.5f);
			self.p_duty_ramp=frnd(0.2f);
		}
		else
		{
			self.p_duty=0.4f+frnd(0.5f);
			self.p_duty_ramp=-frnd(0.7f);
		}
		self.p_env_attack=0.0f;
		self.p_env_sustain=0.1f+frnd(0.2f);
		self.p_env_decay=frnd(0.4f);
		if(rnd(1))
			self.p_env_punch=frnd(0.3f);
		if(rnd(2)==0)
		{
			self.p_pha_offset=frnd(0.2f);
			self.p_pha_ramp=-frnd(0.2f);
		}
		if(rnd(1))
			self.p_hpf_freq=frnd(0.3f);
		
	} else if([@"Explosion" isEqualToString:templateName]) {
		self.wave_type=3;
		if(rnd(1))
		{
			self.p_base_freq=0.1f+frnd(0.4f);
			self.p_freq_ramp=-0.1f+frnd(0.4f);
		}
		else
		{
			self.p_base_freq=0.2f+frnd(0.7f);
			self.p_freq_ramp=-0.2f-frnd(0.2f);
		}
		self.p_base_freq*=self.p_base_freq;
		if(rnd(4)==0)
			self.p_freq_ramp=0.0f;
		if(rnd(2)==0)
			self.p_repeat_speed=0.3f+frnd(0.5f);
		self.p_env_attack=0.0f;
		self.p_env_sustain=0.1f+frnd(0.3f);
		self.p_env_decay=frnd(0.5f);
		if(rnd(1)==0)
		{
			self.p_pha_offset=-0.3f+frnd(0.9f);
			self.p_pha_ramp=-frnd(0.3f);
		}
		self.p_env_punch=0.2f+frnd(0.6f);
		if(rnd(1))
		{
			self.p_vib_strength=frnd(0.7f);
			self.p_vib_speed=frnd(0.6f);
		}
		if(rnd(2)==0)
		{
			self.p_arp_speed=0.6f+frnd(0.3f);
			self.p_arp_mod=0.8f-frnd(1.6f);
		}
	} else if([@"Powerup" isEqualToString:templateName]) {
		if(rnd(1))
			self.wave_type=1;
		else
			self.p_duty=frnd(0.6f);
		if(rnd(1))
		{
			self.p_base_freq=0.2f+frnd(0.3f);
			self.p_freq_ramp=0.1f+frnd(0.4f);
			self.p_repeat_speed=0.4f+frnd(0.4f);
		}
		else
		{
			self.p_base_freq=0.2f+frnd(0.3f);
			self.p_freq_ramp=0.05f+frnd(0.2f);
			if(rnd(1))
			{
				self.p_vib_strength=frnd(0.7f);
				self.p_vib_speed=frnd(0.6f);
			}
		}
		self.p_env_attack=0.0f;
		self.p_env_sustain=frnd(0.4f);
		self.p_env_decay=0.1f+frnd(0.4f);		
	} else if([@"Hit/hurt" isEqualToString:templateName]) {
		self.wave_type=rnd(2);
		if(self.wave_type==2)
			self.wave_type=3;
		if(self.wave_type==0)
			self.p_duty=frnd(0.6f);
		self.p_base_freq=0.2f+frnd(0.6f);
		self.p_freq_ramp=-0.3f-frnd(0.4f);
		self.p_env_attack=0.0f;
		self.p_env_sustain=frnd(0.1f);
		self.p_env_decay=0.1f+frnd(0.2f);
		if(rnd(1))
			self.p_hpf_freq=frnd(0.3f);		
	} else if([@"Jump" isEqualToString:templateName]) {
		self.wave_type=0;
		self.p_duty=frnd(0.6f);
		self.p_base_freq=0.3f+frnd(0.3f);
		self.p_freq_ramp=0.1f+frnd(0.2f);
		self.p_env_attack=0.0f;
		self.p_env_sustain=0.1f+frnd(0.3f);
		self.p_env_decay=0.1f+frnd(0.2f);
		if(rnd(1))
			self.p_hpf_freq=frnd(0.3f);
		if(rnd(1))
			self.p_lpf_freq=1.0f-frnd(0.6f);		
	} else if([@"Blip/select" isEqualToString:templateName]) {
		self.wave_type=rnd(1);
		if(self.wave_type==0)
			self.p_duty=frnd(0.6f);
		self.p_base_freq=0.2f+frnd(0.4f);
		self.p_env_attack=0.0f;
		self.p_env_sustain=0.1f+frnd(0.1f);
		self.p_env_decay=frnd(0.2f);
		self.p_hpf_freq=0.1f;		
	} else if([@"Random" isEqualToString:templateName]) {
		self.p_base_freq=pow(frnd(2.0f)-1.0f, 2.0f);
		if(rnd(1))
			self.p_base_freq=pow(frnd(2.0f)-1.0f, 3.0f)+0.5f;
		self.p_freq_limit=0.0f;
		self.p_freq_ramp=pow(frnd(2.0f)-1.0f, 5.0f);
		if(self.p_base_freq>0.7f && self.p_freq_ramp>0.2f)
			self.p_freq_ramp=-self.p_freq_ramp;
		if(self.p_base_freq<0.2f && self.p_freq_ramp<-0.05f)
			self.p_freq_ramp=-self.p_freq_ramp;
		self.p_freq_dramp=pow(frnd(2.0f)-1.0f, 3.0f);
		self.p_duty=frnd(2.0f)-1.0f;
		self.p_duty_ramp=pow(frnd(2.0f)-1.0f, 3.0f);
		self.p_vib_strength=pow(frnd(2.0f)-1.0f, 3.0f);
		self.p_vib_speed=frnd(2.0f)-1.0f;
		self.p_env_attack=pow(frnd(2.0f)-1.0f, 3.0f);
		self.p_env_sustain=pow(frnd(2.0f)-1.0f, 2.0f);
		self.p_env_decay=frnd(2.0f)-1.0f;
		self.p_env_punch=pow(frnd(0.8f), 2.0f);
		if(self.p_env_attack+self.p_env_sustain+self.p_env_decay<0.2f)
		{
			self.p_env_sustain+=0.2f+frnd(0.3f);
			self.p_env_decay+=0.2f+frnd(0.3f);
		}
		self.p_lpf_resonance=frnd(2.0f)-1.0f;
		self.p_lpf_freq=1.0f-pow(frnd(1.0f), 3.0f);
		self.p_lpf_ramp=pow(frnd(2.0f)-1.0f, 3.0f);
		if(self.p_lpf_freq<0.1f && self.p_lpf_ramp<-0.05f)
			self.p_lpf_ramp=-self.p_lpf_ramp;
		self.p_hpf_freq=pow(frnd(1.0f), 5.0f);
		self.p_hpf_ramp=pow(frnd(2.0f)-1.0f, 5.0f);
		self.p_pha_offset=pow(frnd(2.0f)-1.0f, 3.0f);
		self.p_pha_ramp=pow(frnd(2.0f)-1.0f, 3.0f);
		self.p_repeat_speed=frnd(2.0f)-1.0f;
		self.p_arp_speed=frnd(2.0f)-1.0f;
		self.p_arp_mod=frnd(2.0f)-1.0f;		
	} else if([@"None" isEqualToString:templateName]) {
		return;
	}
}


+(NSArray *) keysToBeCopied;
{
	static NSArray *keysToBeCopied = nil;
	if (keysToBeCopied == nil) {
		keysToBeCopied = [[NSArray alloc] initWithObjects:
			@"attackTime", @"bitDepth", @"changeAmount", @"changeSpeed", @"decayTime",
			@"deltaSlide", @"dutySweep", @"highpassFilterCutoff", @"highpassFilterCutoffSweep",
			@"lowpassFilterCutoff", @"lowpassFilterCutoffSweep", @"lowpassFilterResonance",
			@"minFrequencyCutoff", @"waveType", @"phaserOffset", @"phaserSweep", @"repeatSpeed",
			@"sampleRate", @"slide", @"squareDuty", @"startFrequency", @"sustainPunch", @"sustainTime",
			@"vibratoDepth", @"vibratoSpeed", @"volume", @"name", @"rating", nil
		];
	}
	return keysToBeCopied;
}
-(NSDictionary *) dictionaryRepresentation;
{
	return [self dictionaryWithValuesForKeys:[[self class] keysToBeCopied]];
}

@end
