//
//  MyDocument.h
//  cfxr
//
//  Created by Joachim Bengtsson on 2008-05-17.
//  Copyright Third Cog Software 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Sound;
@interface CfxrDocument : NSPersistentDocument {
	IBOutlet NSArrayController *soundsController;
	IBOutlet NSTableView *soundsTable;
}

-(IBAction)generateSound:(id)sender;

-(Sound*)generateSoundFromCategory:(NSString*)category;

-(IBAction)play:(id)sender;
@end
