// =============================================================================
// File      : HelloWorldLayer.h
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the header file for the "HelloWorldLayer" class.
// =============================================================================

#import "kobold2d.h"
#import "CWorld.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer


@property CWorld*    _myWorld;


// returns a CCScene that contains the HelloWorldLayer as the only child
//+(CCScene *) scene;

@end

/*
 typedef enum
 {
 kAccelerometerValuesRaw,
 kAccelerometerValuesSmoothed,
 kAccelerometerValuesInstantaneous,
 kGyroscopeRotationRate,
 kDeviceMotion,
 
 kInputTypes_End,
 } InputTypes;
 
 @interface HelloWorldLayer : CCLayer
 {
 CCSprite* ship;
 CCParticleSystem* particleFX;
 InputTypes inputType;
 }
 */