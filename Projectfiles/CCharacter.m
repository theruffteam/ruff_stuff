// =============================================================================
// File      : CCharacter.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the implementation file for the "CCharacter" class.
// =============================================================================

#import "CCharacter.h"


@implementation CCharacter

- (id) init:  (NSString*) name:  (CProfile*) profile
{
    self = [super init];
    
    if (self)
        {
        [_profile copy: profile];
        }

    return self;  
}

@end
