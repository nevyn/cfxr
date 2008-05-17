//
//  SCSortedArrayController.h
//  cfxr
//
//  Created by Joachim Bengtsson on 2008-05-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SCSortedArrayController : NSArrayController {
	IBOutlet id appDelegate;
}
- (void) reindexEntries;

@end
