//
//  Sound.h
//  cfxr
//
//  Created by Joachim Bengtsson on 2008-05-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Sound : NSManagedObject {
	bool filter_on;// = false
}

-(void)generateParamsFromCategory:(NSString*)templateName;

@end

#import "Sound+legacyAccessors.h"
