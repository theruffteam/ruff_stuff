// =============================================================================
// File      : CWorld.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/29/2013
// =============================================================================
// This is the implementation file for the "CWorld" class.
// =============================================================================

#import "CGame.h"
#import "CTitleScreenScene.h"
#import "ActorClasses/CYoungRuff.h"
@interface CGame (PrivateMethods)
    - (void) switchToTitleScreen: (int) blank;
@end


@implementation CGame

-(id) init
{
	if ((self = [super init]))
        {
		CCLOG(@"%@ init", NSStringFromClass([self class]));
        
        // get the device's screen properties
		CCDirector* director = [CCDirector sharedDirector];
		CGPoint screenCenter = director.screenCenter;
        
        // =====================================================================
        // Company Logo Screen
        // =====================================================================
        
        // explicitly set the background color of the screen to black
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);

        
        // add company logo
        CCLabelTTF* tmfLogo = [CCLabelTTF labelWithString:@"tMf" fontName:@"Verdana" fontSize:80];
        tmfLogo.position = CGPointMake(screenCenter.x, screenCenter.y + 20);
        tmfLogo.color = ccWHITE;
        [self addChild:tmfLogo];
        
        CCLabelTTF* entertainmentLogo = [CCLabelTTF labelWithString:@"Entertainment" fontName:@"Verdana" fontSize:40];
        entertainmentLogo.position = CGPointMake(screenCenter.x, screenCenter.y - 40);
        entertainmentLogo.color = ccWHITE;
        [self addChild:entertainmentLogo];

		[self scheduleUpdate];

        [self scheduleOnce:@selector(switchToTitleScreen:) delay:5.0f];
        }
    
	return self;
}

- (void) switchToTitleScreen: (int) blank
{
    [[CCDirector sharedDirector] replaceScene:[CTitleScreenScene nodeWithScene]];
}

-(void) update:(ccTime)delta
{
    // empty
}

@end