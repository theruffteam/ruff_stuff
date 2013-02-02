// =============================================================================
// File      : CTitleScreenScene.h
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/29/2013
// =============================================================================
// This is the header file for the "CTitleScreenScene" class.
// =============================================================================

#import <Foundation/Foundation.h>
#import "kobold2d.h"
#import "CWorld.h"

typedef enum
{
    kAccelerometerValuesRaw,
    kAccelerometerValuesSmoothed,
    kAccelerometerValuesInstantaneous,
    kGyroscopeRotationRate,
    kDeviceMotion,
    
    kInputTypes_End,
} InputTypes;

@interface CTitleScreenScene : CCLayer
    // the world of Ruff
    @property    CWorld*        ruffWorld;

    // testing properties (these are only here as we experiment with kobold2d)
    @property CCLayer* menuLayer;

    @property CCSprite* menuStaticRuff;
    @property CCSprite* villageBackground;
    @property CCSprite* ruffLeaningOnTreeForeground;
    @property CCParticleSystem* particleFX;
    @property InputTypes inputType;
@property CCMenu* menu;

@end