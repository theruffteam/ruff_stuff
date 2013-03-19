// =============================================================================
// File      : CTitleScreenScene.h
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 02/10/2013
// =============================================================================
// This is the header file for the "CGameMechanicaScene" class.
// =============================================================================

#import <Foundation/Foundation.h>
#import "kobold2d.h"
#import "CYoungRuff.h"


@interface CGameMechanicsScene : CCLayer

    @property    CYoungRuff*        ruffSprite;
    @property    KKPixelMaskSprite* blackPlatform;
    @property    KKPixelMaskSprite* greenPlatform;
    @property    CGFloat            initialJumpSpeed;
    @property    CGPoint            leftCirclePosition;
    @property    CGPoint            rightCirclePosition;
    @property    CGPoint            healthBarOrigin;
    @property    CGPoint            healthBarDestination;
    @property    BOOL               isJumping;
    @property    BOOL               isMoving;
    @property    ccTime             jumpTime;
    @property    float              ruffBaseY;
    @property    unsigned int       placeRuffOnScreen;
    @property    ccTime             gameTime;
    @property    ccTime             gameTimeDelta;
    @property    ccTime             lastJumpTime;
    @property    ccTime             initialJumpTime;

    // ruff's jump animation
    @property    CCAnimation*       ruffLandingAnimation;
    @property    id                 ruffLandingAction;

@end