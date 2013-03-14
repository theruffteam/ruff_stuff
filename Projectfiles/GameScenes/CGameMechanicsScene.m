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

#define RUFF_JUMP_SPEED 1493.598f
#define GRAVITY -1991.465f
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
        
        // get platform on the screen
        _platform = [[KKPixelMaskSprite alloc] initWithFile:@"blackPlatform.png" alphaThreshold:0];
		_platform.position = CGPointMake(800, 400);
		[self addChild: _platform z:1 tag:1];
        
        // get ruff on the screen
        _ruffSprite = [[[CYoungRuff alloc] initRuff:0] initWithFile:@"ruffReady.png" alphaThreshold:0];
		_ruffSprite.position = CGPointMake(100, 275);
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
        _gameTime = 0;
        _gameTimeDelta = 0;
        _isJumping = NO;
        _isMoving = NO;
        _lastJumpTime = 0;
        _initialJumpTime = 0;

    
	return self;
}


-(void) gestureRecognitionWithPositionOfRuff: (CGPoint) positionOfRuff
{
	KKInput* input = [KKInput sharedInput];
    KKTouch* touch;
    float leftControlOfLeftCircle = 0.4f * (_leftCirclePosition.x + 100);
    float rightControlOfLeftCircle = 0.6f * (_leftCirclePosition.x + 100);
    BOOL leftMovementTap = NO;
    BOOL rightMovementTap = NO;
    

    CCARRAY_FOREACH(input.touches, touch)
        {
        leftMovementTap = touch.location.x < leftControlOfLeftCircle;
        rightMovementTap = touch.location.x > rightControlOfLeftCircle;

        // detect any touches within the left control circle
        if (touch.location.x <= _leftCirclePosition.x + 100  &&
            touch.location.y <= _leftCirclePosition.y + 100  &&
            ! CGPointEqualToPoint(touch.location, CGPointZero))
            {
            if (!_isMoving  &&  (leftMovementTap  || rightMovementTap))
                {
                _isMoving = YES;
                
                _ruffSprite.flipX = rightMovementTap ? NO : YES;
                }
            }

        // detect any touches within the right control circle
        if (touch.location.x >= _rightCirclePosition.x - 100  &&
            touch.location.y <= _leftCirclePosition.y + 100  &&
            ! CGPointEqualToPoint(touch.location, CGPointZero))
            {
            // check if we need to jump
            if (!_isJumping  &&  touch.location.y >= 0.65f * (_rightCirclePosition.y + 100))
                {
                _isJumping = YES;
                //_ruffBaseY = _ruffSprite.position.y; // commented out now. that we're working with collision detection we should have a function that calculates our base Y
                _initialJumpTime = _lastJumpTime;
                }
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
}


- (float) makeRuffJump: (float)currentYOfRuff
{
	// here b/c we probably need a function to detect if ground below has changed our baseY
    // from where we first started our jump
    // otherwise, we could fall through part of the ground when we land
    int baseY = _ruffBaseY;
    
    // here is how we're calculating the change of y: (At^2 + vt) - (At0^2 + vt0)
	float changeOfY = ((GRAVITY * (_jumpTime-_initialJumpTime) * (_jumpTime-_initialJumpTime)) + (RUFF_JUMP_SPEED * (_jumpTime-_initialJumpTime)))  -
                      ((GRAVITY * (_lastJumpTime-_initialJumpTime) * (_lastJumpTime-_initialJumpTime)) + (RUFF_JUMP_SPEED * (_lastJumpTime-_initialJumpTime)));
    float projectedY = currentYOfRuff + changeOfY;

    
    _isJumping = (projectedY > baseY); // turns the jump flag on for falling to prevent mid-fall jump

    if (projectedY <= baseY)
        {
        projectedY = baseY;
            
        _isJumping = NO;
        }

    return projectedY;
}


-(CGPoint) keepRuffBetweenScreenBorders: (CGPoint) positionOfRuff
{
	CCDirector*    director = [CCDirector sharedDirector];
	CGSize         screenSize = director.screenSize;
    CGFloat        halfOfRuffsWidth = 0.5f * _ruffSprite.contentSize.width;
        
	if (positionOfRuff.x <= halfOfRuffsWidth)
        {
		positionOfRuff = CGPointMake(halfOfRuffsWidth, positionOfRuff.y);
        }
	else if (positionOfRuff.x >= screenSize.width - halfOfRuffsWidth)
        {
		positionOfRuff = CGPointMake(screenSize.width - halfOfRuffsWidth, positionOfRuff.y);
        }

    return positionOfRuff;
}


-(void) update:(ccTime)delta
{
    CGPoint lastRuffMovementPosition = _ruffSprite.position;

    _gameTimeDelta = delta;
    _gameTime += delta;
    _jumpTime = _gameTime;
    

    [self gestureRecognitionWithPositionOfRuff: lastRuffMovementPosition];
    
    // check for jump FIRST, then moving
    if (_isJumping)
        {
        lastRuffMovementPosition.y = [self makeRuffJump: lastRuffMovementPosition.y];
        
        }
    
    if (_isMoving)
        {
        lastRuffMovementPosition.x += _ruffSprite.flipX ? -(RUFF_SPEED * delta) : (RUFF_SPEED * delta);

        _isMoving = NO;
        }
    
    if ([KKInput sharedInput].anyTouchEndedThisFrame)
        {
        CCLOG(@"anyTouchEndedThisFrame");
        }


    // collision detection stuff (hacky im sure but wanted to see it working!)
    if([_ruffSprite pixelMaskIntersectsNode:_platform])
        {
        CCLOG(@"WE HIT THE PLATFORM!");
        
        if (lastRuffMovementPosition.y - 0.5*((KKPixelMaskSprite*)_ruffSprite).pixelMaskHeight >= (_platform.position.y + (0.5f * _platform.pixelMaskHeight)))
            {
            _ruffBaseY = _platform.position.y + 0.5*_platform.pixelMaskHeight + 0.5*((KKPixelMaskSprite*)_ruffSprite).pixelMaskHeight - 1; // - 1 to stay intersected 
            }
        }
    else if (![_ruffSprite pixelMaskIntersectsNode:_platform]  &&
             ( lastRuffMovementPosition.x + 0.5*((KKPixelMaskSprite*)_ruffSprite).pixelMaskWidth <= _platform.position.x - 0.5*_platform.pixelMaskWidth  ||
              lastRuffMovementPosition.x - 0.5*((KKPixelMaskSprite*)_ruffSprite).pixelMaskWidth >= _platform.position.x + 0.5*_platform.pixelMaskWidth) )
        {
        _ruffBaseY = 275; // hardcoded value from this scene's init function
        
        }
    
    if (!_isJumping)
        {
        lastRuffMovementPosition.y = _ruffBaseY;
        }
    
    
    
	lastRuffMovementPosition = [self keepRuffBetweenScreenBorders: lastRuffMovementPosition];
    
    _ruffSprite.position = lastRuffMovementPosition;

    _ruffSprite.previousPosition = _ruffSprite.position;

    _lastJumpTime = _gameTime;
    
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