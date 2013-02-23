// =============================================================================
// File      : CTitleScreenScene.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/29/2013
// =============================================================================
// This is the implementation file for the "CTitleScreenScene" class.
// =============================================================================
#import "CCVideoPlayer.h"
#import "CGameMechanicsScene.h"

#define JUMP_FORCE 30
#define GRAVITY_FORCE -1.6f
#define RUFF_SPEED 7.0f


@interface CGameMechanicsScene (PrivateMethods)

-(void) keepRuffBetweenScreenBorders;

@end


@implementation CGameMechanicsScene

-(id) init
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    
	if ((self = [super init]))
        {
        CCDirector* director = [CCDirector sharedDirector];
        KKInput* input = [KKInput sharedInput];
        
        // explicitly set the background color of the screen to black
		glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        
        // get ruff on the screen
		_ruffSprite = [CCSprite spriteWithFile:@"RuffSide.png"];
		_ruffSprite.position = CGPointMake(100, 300);
		[self addChild: _ruffSprite];
        
        
        // get health on the screen
        CCLabelTTF* health = [CCLabelTTF labelWithString:@"Health" fontName:@"Arial" fontSize:20];
        health.position = CGPointMake(0.5 * health.contentSize.width, director.screenSize.height - (0.5f * health.contentSize.height));
        health.color = ccWHITE;
        [self addChild: health];
        
        // position of health bar
        _healthBarOrigin = CGPointMake(1.0f , director.screenSize.height - health.contentSize.height);
        _healthBarDestination = CGPointMake(300.0f , director.screenSize.height - health.contentSize.height - 40.0f);
        
        // position of gesture control circles on left and right of screen
        _leftCirclePosition = CGPointMake(101.0f , 101.0f);
        _rightCirclePosition = CGPointMake(director.screenSize.width - 101.0f , 101.0f);
        
        _isJumping = NO;
        
        // update the screen based on fps
        [self scheduleUpdate];
        
		// initialize KKInput
		input.multipleTouchEnabled = YES;
		input.gestureTapEnabled = input.gesturesAvailable;
		//input.gestureDoubleTapEnabled = input.gesturesAvailable;
		input.gestureSwipeEnabled = input.gesturesAvailable;
        //input.gestureLongPressEnabled = input.gesturesAvailable;
        }
    
	return self;
}


-(void) gestureRecognition
{
	KKInput* input = [KKInput sharedInput];
    CGPoint ruffSpritePosition = self.ruffSprite.position;
    CGPoint position = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    
    
    // detect any touches within the left control circle
    if (position.x <= _leftCirclePosition.x + 100  &&
        position.y <= _leftCirclePosition.y + 100  &&
        ! CGPointEqualToPoint(position, CGPointZero))
        {
        if (position.x >= 0.5 * (_leftCirclePosition.x + 100))
            {
            _ruffSprite.flipX = NO;
            ruffSpritePosition.x += RUFF_SPEED;
            }
        else
            {
            _ruffSprite.flipX = YES;
            ruffSpritePosition.x -= RUFF_SPEED;
            }
        
        if (position.y >= 0.65f * (_leftCirclePosition.y + 100))
            {
            _ruffSprite.position = ruffSpritePosition;
            
            [self beginJumping];
            }
        }

    // detect swipes within right control circle
    if (input.gestureSwipeRecognizedThisFrame  &&
        input.gestureSwipeLocation.x >= _rightCirclePosition.x - 100  &&
        input.gestureSwipeLocation.y <= _rightCirclePosition.y + 100)
        {
        switch (input.gestureSwipeDirection)
            {
            case KKSwipeGestureDirectionUp:
                {
                CCLOG(@"Swipe up");

                break;
                }
                case KKSwipeGestureDirectionRight:
                {
                CCLOG(@"ATTACK (swipe right)");
                
                break;
                }
                case KKSwipeGestureDirectionDown:
                {
                CCLOG(@"Swipe down");
                
                break;
                }
                
                default:
                {
                
                break;
                }
            }
        }
    
    
    
	if (input.gestureTapRecognizedThisFrame)
        {
        // don't know
        }
	
	if (input.gestureDoubleTapRecognizedThisFrame)
        {
        // maybe we can use this?
        }
	if (input.gestureLongPressBegan  &&
        input.gestureLongPressLocation.x >= _rightCirclePosition.x - 100  &&
        input.gestureLongPressLocation.y <= _rightCirclePosition.y + 100)
        {
        // start charging focus meter?
        CCLOG(@"CHARGING FOCUS (long press)");
        }
    
    _ruffSprite.position = ruffSpritePosition;
}


- (void) beginJumping
{
	if (! _isJumping)
        {
        _isJumping = YES;
        _jumpSpeed = JUMP_FORCE;
        _ruffBaseY = _ruffSprite.position.y;

        [self schedule:@selector(moveTick)];

        }
}


- (void) moveTick
{
	_projectedRuffPosition = _ruffSprite.position;
    
	// here to b/c we probably need a function to detect if ground below has changed our baseY
    // from where we first started our jump
    // otherwise, we could fall through part of the ground when we land
    int baseY = _ruffBaseY;
    
	float gravity = GRAVITY_FORCE;
	
    if (_projectedRuffPosition.y > baseY )
        {
        _jumpSpeed += gravity;
        }
    
	float projectedY = _projectedRuffPosition.y + _jumpSpeed;
	
    _isJumping = (projectedY > baseY); // turns the jump flag on for falling to prevent mid-fall jump
    
	if (projectedY <= baseY && _jumpSpeed <= 0)
        {
		projectedY = baseY;
		
        _jumpSpeed = 0;
		
        _isJumping = NO;
        
        [self unschedule:@selector(moveTick)];
        }

    _ruffSprite.position = CGPointMake(_ruffSprite.position.x, projectedY);
}

                              
-(void) keepRuffBetweenScreenBorders
{
	CCDirector*    director = [CCDirector sharedDirector];
	CGSize         screenSize = director.screenSize;
    CGFloat        halfOfRuffsWidth = 0.5f * _ruffSprite.contentSize.width;
    
    
	if (_ruffSprite.position.x <= halfOfRuffsWidth)
        {
		_ruffSprite.position = CGPointMake(halfOfRuffsWidth, _ruffSprite.position.y);
        }
	else if (_ruffSprite.position.x >= screenSize.width - halfOfRuffsWidth)
        {
		_ruffSprite.position = CGPointMake(screenSize.width - halfOfRuffsWidth, _ruffSprite.position.y);
        }
}


-(void) update:(ccTime)delta
{    
    [self gestureRecognition];

    if ([KKInput sharedInput].anyTouchEndedThisFrame)
        {
        CCLOG(@"anyTouchEndedThisFrame");
        }

	[self keepRuffBetweenScreenBorders];
}


-(void) draw
{
    //draw mock-up health bar for kicks
    ccDrawRect(_healthBarOrigin, _healthBarDestination);    
    
    // left circle on screen
    ccDrawCircle(_leftCirclePosition, 100, 0, 16, NO);
    
    // right circle on screen
    ccDrawCircle(_rightCirclePosition, 100, 0, 16, NO);

	KKInput* input = [KKInput sharedInput];
	if (input.touchesAvailable)
        {
		NSUInteger color = 0;
		KKTouch* touch;
		CCARRAY_FOREACH(input.touches, touch)
            {
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