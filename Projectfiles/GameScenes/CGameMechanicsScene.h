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
    @property    CGPoint            leftCirclePosition;
    @property    CGPoint            rightCirclePosition;
    @property    CGPoint            healthBarOrigin;
    @property    CGPoint            healthBarDestination;
    @property    BOOL               isJumping;
    @property    float              jumpSpeed;
    @property    float              ruffBaseY;
    @property    CGPoint            projectedRuffPosition;
@end