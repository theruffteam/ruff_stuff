
// =============================================================================
// File      : CTitleScreenScene.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 1.1
// Updated   : 01/29/2013
// =============================================================================
// This is the implementation file for the "CTitleScreenScene" class.
// =============================================================================
#import "CHudLayer.h"

@interface CHudLayer (PrivateMethods)
@end


@implementation CHudLayer


-(id) init
{
    if ((self = [super init]))
        {
        CCDirector* director = [CCDirector sharedDirector];
        CCLabelTTF* health = [CCLabelTTF labelWithString:@"Health" fontName:@"Arial" fontSize:20];
        
        
        // "Health" text
        health.position = ccp(0.5 * health.contentSize.width, director.screenSize.height - (0.5f * health.contentSize.height));
        health.color = ccBLACK;
        
        // position of health bar
        _healthBarOrigin = ccp(2.0f , director.screenSize.height - health.contentSize.height);
        _healthBarDestination = ccp(300.0f , director.screenSize.height - health.contentSize.height - 40.0f);

        // left and right control circles
        _leftCirclePosition = ccp(101.0f , 101.0f);
        _rightCirclePosition = ccp(director.screenSize.width - 101.0f , 101.0f);
        
        
        CCSprite* move = [[CCSprite alloc] initWithFile:@"Control_Move.png"];
        move.position = ccp(101.0f , 101.0f);
        
        CCSprite* action = [[CCSprite alloc] initWithFile:@"Control_Left.png"];
        action.position = ccp(director.screenSize.width - 101.0f , 101.0f);
        
        [self addChild: move z:10];
        [self addChild: action z: 10];
        
        //[self addChild: health];
        }
    
    return self;
}


-(void) draw
{
    KKInput* input = [KKInput sharedInput];
    
    
    // set circle drawing color
    ccDrawColor4F( 0.0f, 0.0f, 0.0f, 1.0);
    
//    //draw mock-up health bar for kicks
//    ccDrawRect(_healthBarOrigin, _healthBarDestination);
    
//    // left circle on screen
//    ccDrawCircle(_leftCirclePosition, 100, 0, 16, NO);
//    
//    // right circle on screen
//    ccDrawCircle(_rightCirclePosition, 100, 0, 16, NO);
    
	if (input.touchesAvailable)
        {
		NSUInteger color = 0;
		KKTouch* touch;
		CCARRAY_FOREACH(input.touches, touch)
            {
            // CGPoint normalizedTouch = [self convertToWorldSpace:touch.location];
            // CGPoint normalizedPreviousTouch = [self convertToWorldSpace:touch.previousLocation];
            
			switch (color)
                {
                case 0:
                ccDrawColor4F(0.2f, 1, 0.2f, 0.5f);
                break;
                case 1:
                ccDrawColor4F(0.2f, 0.2f, 1, 0.5f);
                break;
                case 2:
                ccDrawColor4F(1, 1, 0.2f, 0.5f);
                break;
                case 3:
                ccDrawColor4F(1, 0.2f, 0.2f, 0.5f);
                break;
                case 4:
                ccDrawColor4F(0.2f, 1, 1, 0.5f);
                break;
                
                default:
                break;
                }
            
			color++;
			
			ccDrawCircle(touch.location, 60, 0, 16, NO);
			ccDrawCircle(touch.previousLocation, 30, 0, 16, NO);
			ccDrawColor4F(1, 1, 1, 1);
			ccDrawLine(touch.location, touch.previousLocation);
			
			if (CCRANDOM_0_1() > 0.98f)
                {
				//[input removeTouch:touch];
                }
            }
        }
}
@end