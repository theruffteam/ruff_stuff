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
#import "CWorld.h"

#define RUFF_JUMP_SPEED 35
#define GRAVITY -1.0f
#define RUFF_SPEED 500.0f
#define RUFF_FREE_FALL_SPEED 150.0f


@interface CGameMechanicsScene (PrivateMethods)

-(void) keepRuffBetweenScreenBorders;

@end


@implementation CGameMechanicsScene

-(id) init
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    
	if ((self = [super init]))
        {
        
        //CWorld* ruffsWorld = [[CWorld alloc] initWorldContentsFromPlist:
        
        CCDirector* director = [CCDirector sharedDirector];
        KKInput* input = [KKInput sharedInput];
        
        // explicitly set the background color of the screen to black
		glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        
        /*
        // get background on the screen
		CCSprite* background = [CCSprite spriteWithFile:@"title_screen_bg_02.png"];
        background.position = CGPointMake(0.5f * director.screenSize.width, 0.5f * director.screenSize.height);
		[self addChild: background];
        */
        
        // get ruff on the screen
        _ruffSprite = [[CYoungRuff alloc] initRuff:0];
        _ruffSprite = [CYoungRuff spriteWithFile:@"ruffReady.png"];
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
		//input.gestureSwipeEnabled = input.gesturesAvailable;
        //input.gestureLongPressEnabled = input.gesturesAvailable;
        }
    
    
        // set to zero, mod to add images
        _placeRuffOnScreen = 2;
    
        _ruffSprite.hitPoints = 10;
        _ruffSprite.previousPosition = _ruffSprite.position;
    
	return self;
}


-(void) gestureRecognitionWithDelta: (ccTime) delta
{
	KKInput* input = [KKInput sharedInput];
    CGPoint ruffSpritePosition = _ruffSprite.position;
    CGPoint position = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    int     directionMultiplier = 1;
    
    
    // detect any touches within the left control circle
    if (position.x <= _leftCirclePosition.x + 100  &&
        position.y <= _leftCirclePosition.y + 100  &&
        ! CGPointEqualToPoint(position, CGPointZero))
        {
        if (position.x >= 0.5 * (_leftCirclePosition.x + 100))
            {
            _ruffSprite.flipX = NO;
            }
        else
            {
            _ruffSprite.flipX = YES;
            directionMultiplier = -1;
            }
        
        ruffSpritePosition.x += directionMultiplier * (RUFF_SPEED * delta);
        
        // check if we need to jump
        if (!_isJumping  &&  position.y >= 0.65f * (_leftCirclePosition.y + 100))
            {
            // if we're within the middle 10% threshold of the jump zone,
            // then we are performing a stationary jump so remove the update
            // to our current x position
            if (position.x > 0.45 * (_leftCirclePosition.x + 100)  &&
                position.x < 0.55 * (_leftCirclePosition.x + 100))
                {
                ruffSpritePosition.x = _ruffSprite.position.x;//+ (-directionMultiplier * (RUFF_FREE_FALL_SPEED * delta));
                }
            
            
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
        _jumpSpeed = RUFF_JUMP_SPEED;
        _ruffBaseY = _ruffSprite.position.y;
        _jumpTime  = 0.0f;
        
        // get ruff on the screen
		
        
        [self schedule:@selector(moveTick)];

        }
}


- (void) moveTick
{
	// here b/c we probably need a function to detect if ground below has changed our baseY
    // from where we first started our jump
    // otherwise, we could fall through part of the ground when we land
    int baseY = _ruffBaseY;

	float changeOfY = 0.0f;
 
    _projectedRuffPosition = _ruffSprite.position;
    _jumpTime++;
    
    changeOfY = (GRAVITY*_jumpTime*_jumpTime + _jumpSpeed*_jumpTime) - ((GRAVITY*(_jumpTime-1.0f)*(_jumpTime-1.0f) + _jumpSpeed*(_jumpTime-1.0f)));
    
	float projectedY = _projectedRuffPosition.y + changeOfY;
	
    _isJumping = (projectedY > baseY); // turns the jump flag on for falling to prevent mid-fall jump
    
	if (projectedY <= baseY)
        {
		projectedY = baseY;
		
        _jumpSpeed = 0.0f;
		
        _isJumping = NO;
        
        _jumpTime = 0.0f;
        
        _placeRuffOnScreen = 2;
        
        [self unschedule:@selector(moveTick)];
        }

    _ruffSprite.position = CGPointMake(_ruffSprite.position.x, projectedY);
    
    if (_placeRuffOnScreen % 2)
        {

        }

    ++_placeRuffOnScreen;
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
    [self gestureRecognitionWithDelta: delta];

    if ([KKInput sharedInput].anyTouchEndedThisFrame)
        {
        CCLOG(@"anyTouchEndedThisFrame");
        }
    
    if (_isJumping  &&  (_ruffSprite.position.x == _ruffSprite.previousPosition.x) && (_ruffSprite.position.y <_ruffSprite.previousPosition.y))
        {
        // facing right
        if(! _ruffSprite.flipX)
            {
            _ruffSprite.position = CGPointMake(_ruffSprite.position.x + (RUFF_FREE_FALL_SPEED * delta), _ruffSprite.position.y);
            }
        // facing left
        else
            {
            _ruffSprite.position = CGPointMake(_ruffSprite.position.x - (RUFF_FREE_FALL_SPEED * delta), _ruffSprite.position.y);
            }
        }

	[self keepRuffBetweenScreenBorders];
    
    if (_ruffSprite.position.x < _ruffSprite.previousPosition.x)
        {
        _ruffSprite.flipX = YES;
        }
    else if (_ruffSprite.position.x > _ruffSprite.previousPosition.x)
        {
        _ruffSprite.flipX = NO;
        }
    
    _ruffSprite.previousPosition = _ruffSprite.position;

}


-(void) draw
{
    // set circle drawing color
    ccDrawColor4F( 0.0f, 0.0f, 0.0f, 1.0);
    
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