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

@interface CActor : KKPixelMaskSprite
    //@property    CCSprite*        boundingBox; // hitBox
    @property    CGRect           attackHitBox;
    @property    int              hitPoints;
    @property    NSString*        baseAttack;
    @property    NSString*        specialAttack;
    @property    CGPoint          position; // (x,y)
    @property    CGPoint          previousPosition; //(x,y)
    @property    CGPoint          direction; // (dx, dy)
    @property    float            gravity;
    @property    NSArray*         listOfAnimations;
    @property    NSArray*         listOfSoundFX;


- (id) initWithPropertyList: (NSString*) actorPList forActor: (NSString*) actorName;
- (BOOL) attack: (NSString*) nameOfAttack;
- (BOOL) jump: (CGPoint) direction;
- (BOOL) move: (CGPoint) position withDirection: (CGPoint) direction withGravity: (float) gravity;

@end