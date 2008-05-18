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

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self play:nil];
}


@end
