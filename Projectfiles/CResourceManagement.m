// =============================================================================
// File      : CResourceManagement.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the implementation file for the "CResourceManagement" class.
// =============================================================================

#import "CResourceManagement.h"


@implementation CResourceManagement


- (id)      initFromResourcesFile: (NSString*)resourcesPList
{
    self = [super init];

    if (self)
        {
        _resources = [[NSMutableDictionary alloc] init];
        }

    return self;
}
@end
