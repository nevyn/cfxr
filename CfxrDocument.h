//
//  MyDocument.h
//  cfxr
//
//  Created by Joachim Bengtsson on 2008-05-17.
//  Copyright Third Cog Software 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Playback.h"

@class Sound;
@interface CfxrDocument : NSPersistentDocument <PlaybackDelegate> {
	IBOutlet NSArrayController *soundsController;
	IBOutlet NSTableView *soundsTable;
}

-(IBAction)generateSound:(id)sender;

-(Sound*)generateSoundFromCategory:(NSString*)category;

-(IBAction)play:(id)sender;
-(IBAction)playOnChange:(id)sender;
-(IBAction)toggleLooping:(id)sender;

-(IBAction)export:(id)sender;
-(IBAction)exportQuickly:(id)sender;

-(IBAction)takeMasterVolumeFrom:(id)sender;

- (IBAction) copy:(id) sender;
- (IBAction) paste:(id) sender;

@end
