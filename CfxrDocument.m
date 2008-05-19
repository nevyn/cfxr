//
//  MyDocument.m
//  cfxr
//
//  Created by Joachim Bengtsson on 2008-05-17.
//  Copyright Third Cog Software 2008 . All rights reserved.
//

#import "CfxrDocument.h"
#import "Sound.h"
#import "Playback.h"


@implementation CfxrDocument

- (NSString *)windowNibName 
{
    return @"CfxrDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];
	
	if([Sound countInContext:[self managedObjectContext]] == 0)
		[self generateSoundFromCategory:@"Empty"];
	
	// Sort by inverse index by default
	NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey: @"index" ascending: NO
										selector:@selector(compare:)];
	[soundsController setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	soundsTable.delegate = self;
}

-(IBAction)generateSound:(id)sender;
{
	[self generateSoundFromCategory:[[sender selectedCell] title]];
}

-(Sound*)generateSoundFromCategory:(NSString*)category;
{
	Sound *sound = [NSEntityDescription insertNewObjectForEntityForName:@"Sound"
												 inManagedObjectContext:[self managedObjectContext]];
	[sound generateParamsFromCategory:category];
	
	sound.name = category;
	
	[soundsController setSelectedObjects:[NSArray arrayWithObject:sound]];
	[[Playback playback] play:sound];
	[soundsController rearrangeObjects];
	return sound;
}

-(IBAction)play:(id)sender;
{
	Sound *s = [[soundsController selectedObjects] objectAtIndex:0];
	[[Playback playback] play:s];

}

-(IBAction)export:(id)sender;
{
	Sound *s = [[soundsController selectedObjects] objectAtIndex:0];

	NSSavePanel *savePanel = [NSSavePanel savePanel];
	savePanel.title = @"Export WAV as";
	savePanel.prompt = @"Export WAV";
	savePanel.nameFieldLabel = @"Export as:";
	savePanel.requiredFileType = @"wav";
	savePanel.canSelectHiddenExtension = YES;
	
	NSString *filename = [NSString stringWithFormat:@"%@ %03d %@.wav",
						  [self displayName], s.index.intValue,  s.name];
	
	[savePanel beginSheetForDirectory:nil
								 file:filename
					   modalForWindow:[[[self windowControllers] objectAtIndex:0] window]
						modalDelegate:self
					   didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
					      contextInfo:s];
	
}
-(IBAction)exportQuickly:(id)sender;
{
	if([self fileURL] == nil) {
		NSRunAlertPanel(@"You need to save first.", @"When you quick export, you export to the same folder as this document. Thus, you must save this document to somewhere on your computer before you can quick export.", @"Okay then", nil, nil);
		return;
	}
	Sound *s = [[soundsController selectedObjects] objectAtIndex:0];
	NSString *sName = [s.name stringByReplacingOccurrencesOfString:@"/" withString:@" or "];
	NSString *filename = [NSString stringWithFormat:@"%@ %03d %@.wav",
						  [self displayName], s.index.intValue,  sName];
	
	NSString *path = [[[[self fileURL] path] stringByDeletingLastPathComponent] stringByAppendingPathComponent:filename];
	NSLog(@"I'm now exporting %@ to %@", s, path);
	
	NSError *error;
	if(![[Playback playback] export:s to:path error:&error])
		[self presentError:error];

}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;
{
	if(returnCode == NSCancelButton) return;
	
	NSError *error;
	if(![[Playback playback] export:contextInfo to:sheet.filename error:&error])
		NSRunAlertPanel(@"Export failed.", [error localizedDescription], @"Bummer", nil, nil);
}

-(IBAction)takeMasterVolumeFrom:(id)sender;
{
	[Playback playback].masterVolume = [sender floatValue]/100;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self play:nil];
}


@end
