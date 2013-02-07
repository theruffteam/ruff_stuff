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
    @property    CGRect           attackHitBox;
    @property    NSArray*         listOfSoundFX;
    @property    NSString*        specialAttack;
    @property    NSString*        baseAttack;
    @property    CCSprite*        boundingBox; // hitBox
    @property    int              hitPoints;
    @property    float            gravity;
    @property    CGPoint          direction; // (dx, dy)
    @property    CGPoint          position; // (x,y)
    @property    NSArray*         listOfAnimations;


- (id) initWithPropertyList: (NSString*) actorPList;
- (BOOL) attack: (NSString*) nameOfAttack;
- (BOOL) jump: (CGPoint) direction;
- (BOOL) move: (CGPoint) position withDirection: (CGPoint) direction withGravity: (float) gravity;

@end