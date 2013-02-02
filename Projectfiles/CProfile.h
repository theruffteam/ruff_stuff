// =============================================================================
// File      : CProfile.h
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the header file for the "CProfile" class.
// =============================================================================

#import <Foundation/Foundation.h>
#import "kobold2d.h"

@interface CProfile : CCNode
{
    @private
    unsigned int    _type;
    unsigned int    _maxHitPoints;
    unsigned int    _hitPoints;
    bool            _isAlive;
}

- (id)      init:(unsigned int) typeOfProfile:(unsigned int) maxHitPoints:(unsigned int) hitPoints:(bool) isAlive;
- (bool)    updateMaxHitPoints;
- (bool)    updateHitPoints;
- (bool)    updateType;

@end
