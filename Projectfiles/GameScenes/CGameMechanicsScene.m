
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
#import "CCAnimationExtensions.h"
#import "CGameMechanicsScene.h"
#import "CWorld.h"
#import "CCSpriteFrameExtended.h"

#define RUFF_JUMP_SPEED 1493.598f
#define RUFF_FALL_SPEED 0.0f
#define GRAVITY -1991.465f
#define RUFF_SPEED 480.0f

@interface CGameMechanicsScene (PrivateMethods)

-(void) keepRuffBetweenScreenBorders;

@end


@implementation CGameMechanicsScene

-(void) addPixelMaskSpriteFramesToSpriteCacheWithSpritesheet: (NSString*)spriteSheetName
{
}


-(void) setupExtendedSprite: (KKMutablePixelMaskSprite*)sprite withSpritesheet: (NSString*)spriteSheetName andInitialFrameName: (NSString*)initialFrameName
{
    // add sprite sheet to the sprite cache
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: spriteSheetName];
    
    // now let's look at the plist which loaded the spritesheet, and grab all the sprite frame names
    // so that we can extend them with the pixel mask, and re-add them to the frame cache
    NSDictionary* dictionaryOfSpriteSheet = [NSDictionary dictionaryWithContentsOfFile: [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:spriteSheetName]];
    
    NSDictionary* dictionaryOfSpriteFrameNames = [NSDictionary dictionaryWithDictionary:[dictionaryOfSpriteSheet objectForKey:@"frames"]];
    
    for (NSString* frameName in dictionaryOfSpriteFrameNames)
        {
        if ([frameName isEqualToString: @"platform-02.png"])
            {
            CCLOG(@"");
            }
        [sprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
        
        CCSpriteFrameExtended* pixelMaskFrame = [sprite createPixelMaskWithCurrentFrame];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:pixelMaskFrame name:frameName];
        }
    
    [self setupExtendedSprite:sprite withInitialFrame:initialFrameName];
}


-(void) setupExtendedSprite: (KKMutablePixelMaskSprite*)sprite withInitialFrame: (NSString*)initialFrameName
{
    CCSpriteFrameExtended* initialFrame = (CCSpriteFrameExtended*)[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:initialFrameName];
    
    [sprite setDisplayFrame:initialFrame];
    
    // update pixel mask to match his updated frame
    [sprite updatePixelMaskWithSpriteFrame: initialFrame];
}


-(id) init
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    
	if ((self = [super init]))
        {
        // must use this when click premultiplied alpha in texture packer
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
        
        // get ruff sprite on the screen
        _ruffSprite = [[CYoungRuff alloc] initRuff:0];
		_ruffSprite.anchorPoint = ccp(0,0);
        _ruffSprite.position = ccp(100, 400);
        
        [self setupExtendedSprite:_ruffSprite withSpritesheet:@"ruff-sprite-sheet.plist" andInitialFrameName:@"ruff-ready-01.png"];
        [self addChild: _ruffSprite z:1];
        
        CCDirector* director = [CCDirector sharedDirector];
            
        _defaultGround = 0;
        _grounds = [[NSMutableArray alloc] init];
        _platforms = [[NSMutableArray alloc] init];
            
        // get blue ground platform on the screen
            for ( int plat_x = 0; plat_x <= director.winSize.width; )
            {
                _platform3 = [[KKMutablePixelMaskSprite alloc] init];
                _platform3.anchorPoint = ccp(0,0);
                _platform3.position = ccp(plat_x, 150);
        
                [self setupExtendedSprite:_platform3 withSpritesheet:@"platforms-sprite-sheet.plist" andInitialFrameName:@"ground.png"];
                [self addChild: _platform3 z: 3];
                
                plat_x += _platform3.contentSize.width;
                _platform3.tag = 3;
                [_grounds addObject:_platform3];
            }
        
        
        //CWorld* ruffsWorld = [[CWorld alloc] initWorldContentsFromPlist:
        
        
        KKInput* input = [KKInput sharedInput];
        
        // explicitly set the background color of the screen to black
		glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        
                
        // get background on the screen
		CCSprite* floor = [CCSprite spriteWithFile:@"titleFixed.png"];
        floor.position = ccp(0.5f * director.screenSize.width, 0.5f * director.screenSize.height);
		[self addChild: floor z:-5];
        
            for (int i = 0; i < 3; i++)
            {
                // get black platform on the screen
                _blackPlatform = [[KKPixelMaskSprite alloc] initWithFile:@"blackPlatform.png" alphaThreshold:0];
                _blackPlatform.position = ccp(800, 402.5 + ( i * 1.5 *  140)) ; //(_ruffSprite.position.y + 0.5f / CC_CONTENT_SCALE_FACTOR() * (_ruffSprite.pixelMaskHeight + _blackPlatform.pixelMaskHeight)));
                [self addChild: _blackPlatform z:2 tag:1];
           
                // get green platform on the screen
                _greenPlatform = [[KKPixelMaskSprite alloc] initWithFile:@"greenPlatform.png" alphaThreshold:0];
                _greenPlatform.position = ccp(_blackPlatform.position.x, _blackPlatform.position.y + 0.5f /CC_CONTENT_SCALE_FACTOR() * (_blackPlatform.pixelMaskHeight + _greenPlatform.pixelMaskHeight));
                [self addChild: _greenPlatform z:0 tag:2];
                
                _greenPlatform.tag = 2;
                [_platforms addObject:_greenPlatform];
            }
        
        // get health on the screen
        CCLabelTTF* health = [CCLabelTTF labelWithString:@"Health" fontName:@"Arial" fontSize:20];
        health.position = ccp(0.5 * health.contentSize.width, director.screenSize.height - (0.5f * health.contentSize.height));
        health.color = ccBLACK;
        [self addChild: health];
        
        // position of health bar
        _healthBarOrigin = ccp(2.0f , director.screenSize.height - health.contentSize.height);
        _healthBarDestination = ccp(300.0f , director.screenSize.height - health.contentSize.height - 40.0f);
        
        // position of gesture control circles on left and right of screen
        _leftCirclePosition = ccp(101.0f , 101.0f);
        _rightCirclePosition = ccp(director.screenSize.width - 101.0f , 101.0f);
        
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
        _ruffBaseY = _ruffSprite.position.y;
        _ruffSprite.hitPoints = 10;
        _ruffSprite.previousPosition = _ruffSprite.position;
        _gameTime = 0;
        _gameTimeDelta = 0;
        _isJumping = NO;
        _isMoving = NO;
        _lastJumpTime = 0;
        _initialJumpSpeed = 0;
        _initialJumpTime = 0;
        _isRunning = NO;
        _landingTime = 0;

    
    
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
            if (!_isJumping  &&  touch.location.y >= 0.65f * (_rightCirclePosition.y + 100)  &&  (_gameTime - _landingTime) > 3.0f * 0.04167f)
                {
                _isJumping = YES;
                _initialJumpSpeed = RUFF_JUMP_SPEED;
                //_initialJumpTime = _lastJumpTime;
                _initialJumpTime = _gameTime;
                
                //_ruffBaseY = _ruffSprite.position.y; // commented out now. that we're working with collision detection we should have a function that calculates our base Y
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


- (float) makeRuffJump: (float)currentYOfRuff withVelocity: (CGFloat)velocity
{
    float projectedY = currentYOfRuff;
    
    if ((_jumpTime - _initialJumpTime) >= (2.0f * 0.04167f))
        {
        _jumpTime -= 2.0 * 0.04167f;
        _lastJumpTime -= 2.0 * 0.04167f;
        
        // here b/c we probably need a function to detect if ground below has changed our baseY
        // from where we first started our jump
        // otherwise, we could fall through part of the ground when we land
        int baseY = _ruffBaseY;

        // here is how we're calculating the change of y: (At^2 + vt) - (At0^2 + vt0)
        float changeOfY = ((GRAVITY * (_jumpTime-_initialJumpTime) * (_jumpTime-_initialJumpTime)) + (velocity * (_jumpTime-_initialJumpTime)))  -
                          ((GRAVITY * (_lastJumpTime-_initialJumpTime) * (_lastJumpTime-_initialJumpTime)) + (velocity * (_lastJumpTime-_initialJumpTime)));
        projectedY = currentYOfRuff + changeOfY;

        // turns the jump flag on for falling to prevent mid-fall jump
        _isJumping = (projectedY > baseY);

        if (projectedY <= baseY)
            {
            projectedY = baseY;
                
            _isJumping = NO;
            
            // play ruff's landing animation
            [_ruffSprite stopAllActions];
            
            NSMutableArray* animationFrames = [[NSMutableArray alloc] initWithCapacity: 2];
            
            for(int i = 17; i < 19; ++i)
                {
                [animationFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"ruff-jump-%02d.png", i]]];
                }

            _ruffLandingAnimation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.04167f];
            
            _ruffLandingAction = [CCAnimate actionWithAnimation: _ruffLandingAnimation];
                        
            CCSequence *seq = [CCSequence actions:
                               _ruffLandingAction,
                               //[CCCallFunc actionWithTarget:self selector:@selector(resetRuffsReadyFrame)],
                               nil];
          
            // take note of the time of landing
            _landingTime = _gameTime;
            
            [_ruffSprite runAction: seq];
            }
        }
    else
        {
        if ( _jumpTime == _initialJumpTime)
            {
            [_ruffSprite stopAllActions];
            
            // play ruff's takeoff animation
            NSMutableArray* animationTakeoffFrames = [[NSMutableArray alloc] initWithCapacity:2];
            
            for(int i = 1; i < 3; ++i)
                {
                [animationTakeoffFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"ruff-jump-%02d.png", i]]];
                }
            
            CCAnimation* ruffTakeoffAnimation = [CCAnimation animationWithSpriteFrames:animationTakeoffFrames delay:0.04167f];
            
            id ruffTakeoffAction = [CCAnimate actionWithAnimation: ruffTakeoffAnimation];

            
            NSMutableArray* animationJumpFrames = [[NSMutableArray alloc] initWithCapacity:14];
            
            for(int i = 3; i < 17; ++i)
                {
                [animationJumpFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"ruff-jump-%02d.png", i]]];
                }
            
            CCAnimation* ruffJumpAnimation = [CCAnimation animationWithSpriteFrames:animationJumpFrames delay:0.04167f];
            
            id ruffJumpAction = [CCAnimate actionWithAnimation: ruffJumpAnimation];
            
            
            
            CCSequence* sequence = [CCSequence actions:
                               ruffTakeoffAction,
                               ruffJumpAction,
                               nil];
            
            [_ruffSprite runAction: sequence];
            }
        }
    
    return projectedY;
}


-(void) run
{
    
    if (!_isRunning)
        {
        [_ruffSprite stopAllActions];
        // play ruff's running animation
        NSMutableArray* animationFrames = [[NSMutableArray alloc] initWithCapacity: 2];
    
    for(int i = 1; i < 9; ++i)
        {
        [animationFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"ruff-run-%02d.png", i]]];
        }
    
        CCAnimation* ruffRunAnimation = [[CCAnimation alloc] initWithSpriteFrames:animationFrames delay:1.0f/12.0f];
    
        id ruffRunAction = [[CCAnimate alloc] initWithAnimation:ruffRunAnimation];
        
        CCSequence *seq = [CCSequence actions:
                       ruffRunAction,
                       nil];
    
        [_ruffSprite runAction: [CCRepeatForever actionWithAction:seq]];
        }
}



-(CGPoint) keepRuffBetweenScreenBorders: (CGPoint) positionOfRuff
{
	CCDirector*    director = [CCDirector sharedDirector];
	CGSize         screenSize = director.screenSize;
    CGFloat        ruffsWidth = [_ruffSprite boundingBox].size.width;
        
	if (positionOfRuff.x <= 0)
        {
		positionOfRuff = ccp( 0, positionOfRuff.y);
        }
	else if (positionOfRuff.x >= screenSize.width - ruffsWidth)
        {
		positionOfRuff = ccp(screenSize.width - ruffsWidth, positionOfRuff.y);
        }

    return positionOfRuff;
}


-(void) resetRuffsReadyFrame
{
    // pull from the cache the frame we want ruff to reset back to
    CCSpriteFrameExtended* frame = (CCSpriteFrameExtended*)([[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ruff-ready-01.png"]);
    
    // update his frame visually
    [_ruffSprite setDisplayFrame: frame];    

    [self setRuffsPixelMaskWithFrame:frame];
}

-(void)setPlatform3PixelMaskWithFrame: (CCSpriteFrameExtended*)frame
{
    // update his frame visually
    [_platform3 setDisplayFrame: frame];
    
    // update his pixel mask to match his updated frame
    [_platform3 updatePixelMaskWithSpriteFrame: frame];
}

-(void)setRuffsPixelMaskWithFrame: (CCSpriteFrameExtended*)frame
{
    // update his frame visually
    [_ruffSprite setDisplayFrame: frame];
    
    // update his pixel mask to match his updated frame
    [_ruffSprite updatePixelMaskWithSpriteFrame: frame];
}

-(float) getRuffsBaseY
{
    for (CCSprite *ground in _grounds)
    {
        if (_ruffSprite.position.x >= ground.position.x && ground.position.x <= (_ruffSprite.position.x + _ruffSprite.contentSize.width) )
        {
            _defaultGround = ground.position.y + ground.contentSize.height;

            return _defaultGround;
        }
        
    }
    
    return _ruffBaseY;
}

-(BOOL) didRuffCollideWithAPlatform: (CGPoint) lastRuffMovementPosition
{
    for (KKPixelMaskSprite* platform in _platforms)
    {
        if ((lastRuffMovementPosition.y >= (int)(platform.position.y - 0.5f / CC_CONTENT_SCALE_FACTOR() * platform.contentSize.height)))
        {
            if ([ _ruffSprite pixelMaskIntersectsNode: platform])
            {
                _ruffBaseY =  platform.position.y - 0.5f / CC_CONTENT_SCALE_FACTOR() * platform.contentSize.height;
                _defaultGround = _ruffBaseY;
                return YES;
            }
            
        }
    }
    
    return NO;
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
        _isRunning = NO;
        
        lastRuffMovementPosition.y = [self makeRuffJump: lastRuffMovementPosition.y withVelocity: _initialJumpSpeed];
        }
    
    // not jumping and not moving
    if (!_isJumping  &&  !_isMoving)
        {
        // if we have exceeded the time it takes to finish the landing animation
        if ((_gameTime - _landingTime) > 3.0f * 0.04167f)
            {
            [_ruffSprite stopAllActions];
            
            if (!_isRunning)
                {
                [self resetRuffsReadyFrame];
                }
            
            _isRunning = NO;
            }
        }
    
    if (!_isJumping  &&  _isMoving)
        {
        [self run];
    
        _isRunning = YES;
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

    if ([ _ruffSprite pixelMaskIntersectsNode: _platform3])
        {
            CCLOG(@"blue platform");
        }

    
    if ( [self didRuffCollideWithAPlatform:lastRuffMovementPosition] ) /*[ _ruffSprite pixelMaskIntersectsNode: _greenPlatform]  &&
        (lastRuffMovementPosition.y >= _blackPlatform.position.y + (0.5f / CC_CONTENT_SCALE_FACTOR() * _blackPlatform.size.height))) */
        {
        CCLOG(@"green platform");
        //_ruffBaseY = _blackPlatform.position.y + 0.5f / CC_CONTENT_SCALE_FACTOR() * (_blackPlatform.pixelMaskHeight);
        }
    else if (_ruffBaseY != [self getRuffsBaseY] )
        {

            _ruffBaseY = [self getRuffsBaseY] ;
        
        if (!_isJumping)
            {
            _isJumping = YES;
            _initialJumpSpeed = RUFF_FALL_SPEED;
            _initialJumpTime = _lastJumpTime;

            [_ruffSprite stopAllActions];
            
            // hold the extended leg frame until he lands on something
            CCSpriteFrameExtended* frame = (CCSpriteFrameExtended*)([[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ruff-jump-16.png"]);
            
            [_ruffSprite setDisplayFrame: frame];
            
            [self setRuffsPixelMaskWithFrame: frame];
            }
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