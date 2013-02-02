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

    @property   CGRect              attackHitBox;
    @property   NSArray*            soundFX;
    @property   NSArray*            attack;
    @property   int                 hitPoints;
    @property   float               gravity;
    @property   CGPoint             direction;
    @property   CGPoint             position;
    @property   NSArray*            ability;
    @property   NSArray*            animation;

@end