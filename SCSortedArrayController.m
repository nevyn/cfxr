//
//  SCSortedArrayController.m
//  cfxr
//
// By http://shanecrawford.org/2008/37/sorting-a-coredata-backed-nsarraycontroller/
//

#import "SCSortedArrayController.h"


@implementation SCSortedArrayController
- (void)awakeFromNib

{
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"index"
							  
														 ascending:YES];
	
	[self setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	[super awakeFromNib];
	
}

- (void)remove:(id)sender

{
	
    [super remove:sender];
	
    [self reindexEntries];
	
}- (void)insertObject:(id)object atArrangedObjectIndex:(NSUInteger)index

{
	
    [object setValue:[NSNumber numberWithInt:index] forKey:@"index"];
	
    [super insertObject:object atArrangedObjectIndex:index];
	
    [self reindexEntries];
	
}

- (void) reindexEntries

{
	
    // Note: use a temporary array since modifying an item in arrangedObjects
	
    //       directly will cause the sort to trigger thus throwing off
	
    //       the re-indexing.
	
    int count = [[self arrangedObjects] count];
	
    NSArray *tmpArray = [NSArray arrayWithArray:[self arrangedObjects]];
	
	for(int ndx = 0; ndx < count ; ndx++){
		
        id entry = [tmpArray objectAtIndex:ndx];
		
        [entry setValue:[NSNumber numberWithInt:ndx] forKey:@"index"];
		
    }
	
}

- (NSArray *)arrangeObjects:(NSArray *)objects

{
	
    // Note: at this point the data objects are CoreData faults and thus contain
	
    //       no real data. So, go ahead and batch fault (load) the data for use
	
    //       in sorting
	
    NSError *error = nil;
	
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
	
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Sound"
											  
                                                         inManagedObjectContext:moc];
	
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	
    [request setReturnsObjectsAsFaults:NO];
	
    [request setEntity:entityDescription];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self IN %@", objects];
	
    [request setPredicate:predicate];
	
    [moc executeFetchRequest:request error:&error];    NSArray *arranged = [super arrangeObjects:objects];
	
	return arranged;
	
}
@end
