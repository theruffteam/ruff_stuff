// =============================================================================
// File      : CProfile.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the implementation file for the "CProfile" class.
// =============================================================================

#import "CProfile.h"


@implementation CProfile


// =============================================================================
// this will be used to populate the profile of a character
// =============================================================================
- (id) init:  (unsigned int) typeOfProfile:  (unsigned int) maxHitPoints:  (unsigned int) hitPoints:  (bool) isAlive
{
    self = [super init];
    
    if (self)
        {
        _type = typeOfProfile;
        
        _maxHitPoints = maxHitPoints;
        
        _hitPoints = hitPoints;
        
        _isAlive = isAlive;
        }
    
    return self;
}

- (bool)    updateMaxHitPoints
{
    return true;
}


- (bool)    updateHitPoints
{
    return true;
}


- (bool)    updateType
{
    return true;
}

@end
