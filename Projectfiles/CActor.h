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


@interface CActor : CCSprite
{
    @private
        NSMutableArray*      _abilities;
        NSMutableArray*      _animations;
}

@end
