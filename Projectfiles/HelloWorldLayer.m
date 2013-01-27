// =============================================================================
// File      : HelloWorldLayer.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the implementation file for the "HelloWorldLayer" class.
// =============================================================================

#import "HelloWorldLayer.h"
#import "CAudio.h"


@implementation HelloWorldLayer

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@ init", NSStringFromClass([self class]));
		
        // background color of the screen
		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);

		//CCDirector* director = [CCDirector sharedDirector];
		//CGPoint screenCenter = director.screenCenter;
    
        // create our world entity
        // this is simply used right now to invoke our audio management system
        self._myWorld = [[CWorld alloc] initLevelContentsFromFile:@""
                               characterContentsFromFile:@""
                                 graphicContentsFromFile:@""
                                   audioContentsFromFile:@"audio.plist"
                                resourceContentsFromFile:@""];
    
    [[CAudio alloc ]playBackgroundMusic:@"seasonal_background.mp3" withVolumeAt:1.0f isBackgroundMusicOn:NO];
    
    
    
    /*
		particleFX = [CCParticleMeteor node];
		particleFX.position = screenCenter;
		[self addChild:particleFX z:-2];

		[self addLabels];

		ship = [CCSprite spriteWithFile:@"ship.png"];
		ship.position = screenCenter;
		[self addChild:ship];
    */
    /*
		CCSprite* touchSprite = [CCSprite spriteWithFile:@"touchsprite.png"];
		touchSprite.position = screenCenter;
		touchSprite.scale = 0.1f;
		[self addChild:touchSprite z:-1 tag:99];
		{
			id rotate = [CCRotateBy actionWithDuration:60 angle:360];
			id repeat = [CCRepeatForever actionWithAction:rotate];
			[touchSprite runAction:repeat];
		}
		{
			id scaleUp = [CCScaleTo actionWithDuration:20 scale:3];
			id scaleDn = [CCScaleTo actionWithDuration:20 scale:0.1f];
			id sequence = [CCSequence actions:scaleUp, scaleDn, nil];
			id repeat = [CCRepeatForever actionWithAction:sequence];
			[touchSprite runAction:repeat];
		}
     */
		//[self scheduleUpdate];
    /*
		[self schedule:@selector(changeInputType:) interval:8.0f];
		[self schedule:@selector(postUpdateInputTests:)];
		
		// initialize KKInput
		KKInput* input = [KKInput sharedInput];
		input.accelerometerActive = input.accelerometerAvailable;
		input.gyroActive = input.gyroAvailable;
		input.multipleTouchEnabled = YES;
		input.gestureTapEnabled = input.gesturesAvailable;
		input.gestureDoubleTapEnabled = input.gesturesAvailable;
		input.gestureSwipeEnabled = input.gesturesAvailable;
		input.gestureLongPressEnabled = input.gesturesAvailable;
		input.gesturePanEnabled = input.gesturesAvailable;
		input.gestureRotationEnabled = input.gesturesAvailable;
		input.gesturePinchEnabled = input.gesturesAvailable;
     */
	}

	return self;
}



@end
