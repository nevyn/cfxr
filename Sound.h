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
+(int)countInContext:(NSManagedObjectContext*)ctx;
+(int)highestIndexInContext:(NSManagedObjectContext*)ctx;

-(void)generateParamsFromCategory:(NSString*)templateName;

+(NSArray *) keysToBeCopied;
-(NSDictionary *) dictionaryRepresentation;
@end

#import "Sound+legacyAccessors.h"
