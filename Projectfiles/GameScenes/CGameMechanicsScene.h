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
#import "CHudLayer.h"


@interface CGameMechanicsScene : CCLayer

    @property    CYoungRuff*                    ruffSprite;
    @property    KKPixelMaskSprite*             blackPlatform;
    @property    KKPixelMaskSprite*             greenPlatform;
    @property    KKMutablePixelMaskSprite*      platform3;
    @property    CGFloat                        initialJumpSpeed;
    @property    CGPoint                        leftCirclePosition;
    @property    CGPoint                        rightCirclePosition;
    @property    CGPoint                        healthBarOrigin;
    @property    CGPoint                        healthBarDestination;
    @property    BOOL                           isJumping;
    @property    BOOL                           isMoving;
    @property    BOOL                           isRunning;
    @property    ccTime                         jumpTime;
    @property    int                            ruffBaseY;
    @property    unsigned int                   placeRuffOnScreen;
    @property    ccTime                         gameTime;
    @property    ccTime                         gameTimeDelta;
    @property    ccTime                         lastJumpTime;
    @property    ccTime                         initialJumpTime;
    @property    ccTime                         landingTime;
    @property    CGPoint                        backgroundPosition;
    @property    NSMutableArray*                grounds;
    @property    NSMutableArray*                platforms;
    @property    int                            defaultGround;
    @property    CGPoint                        lastSelfMovementPosition;
    @property    int                            levelWidth;
    @property    int                            levelHeight;
    @property    float                          changeOfY;

    // level layers
    @property    CCLayer*                       backgroundLayer;
    @property    CCLayer*                       foregroundLayer;
    @property    CCLayer*                       enemiesLayer;
    @property    CCLayer*                       levelObjectsLayer;
    @property    CCLayer*                       stageAssistorsLayer;
    @property    CHudLayer*                     hudLayer;
    @property    CCLayer*                       ruffsLayer;




    // ruff's jump animation
    @property    CCAnimation*       ruffLandingAnimation;
    @property    id                 ruffLandingAction;

@end