// =============================================================================
// File      : CActor.h
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the header file for the "CActor" class.
// =============================================================================

#import <Foundation/Foundation.h>
#import "kobold2d.h"
#import "CProfile.h"


@interface CActor : CCSprite
{
    @private
        CProfile*            _profile;
        NSMutableArray*      _abilities;
        NSMutableArray*      _animations;
}

- (id) init:  (NSString*) name:  (CProfile*) profile;


@end
