// =============================================================================
// File      : CLevelManagement.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the implementation file for the "CLevelManagement" class.
// =============================================================================

#import "CLevelManagement.h"


@implementation CLevelManagement

- (id) initFromLevelsFile: (NSString*)levelsPList
{
    self = [super init];
    
    if (self)
        {
        _levels = [[NSMutableDictionary alloc] init];
        }
    
    return self;
}

@end
