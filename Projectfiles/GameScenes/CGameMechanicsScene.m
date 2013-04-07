
// =============================================================================
// File      : CTitleScreenScene.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 1.1
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
        _backgroundLayer = [CCLayer node];
        _foregroundLayer = [CCLayer node];
        _enemiesLayer = [CCLayer node];
        _levelObjectsLayer = [CCLayer node];
        _stageAssistorsLayer = [CCLayer node];
        _hudLayer = [CHudLayer node];
        _ruffsLayer = [CCLayer node];
        
        
        
        
        
        // must use this when click premultiplied alpha in texture packer
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
        
        // get ruff sprite on the screen
        _ruffSprite = [[CYoungRuff alloc] initRuff:0];
		_ruffSprite.anchorPoint = ccp(0,0);
        _ruffSprite.position = ccp(1, 400);
        
        [self setupExtendedSprite:_ruffSprite withSpritesheet:@"ruff-sprite-sheet.plist" andInitialFrameName:@"ruff-ready-01.png"];
        
        CCDirector* director = [CCDirector sharedDirector];
            
        _defaultGround = 0;
        _grounds = [[NSMutableArray alloc] init];
        _platforms = [[NSMutableArray alloc] init];
        _springs = [[NSMutableArray alloc] init];
        _walls = [[NSMutableArray alloc] init];
        
        _platform3 = [[KKMutablePixelMaskSprite alloc] init];
        _platform3.anchorPoint = ccp(0,0);
        _platform3.position = ccp(0,0);
        [self setupExtendedSprite:_platform3 withSpritesheet:@"platforms-sprite-sheet.plist" andInitialFrameName:@"ground.png"];
        

        
        
        //CWorld* ruffsWorld = [[CWorld alloc] initWorldContentsFromPlist:
        
        
        KKInput* input = [KKInput sharedInput];
        
        // explicitly set the background color of the screen to black
		glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        
                
        // get background on the screen
		//CCSprite* floor = [CCSprite spriteWithFile:@"level-01-part-01.png"];
        //floor.position = ccp(0.5f * director.screenSize.width, 0.5f * director.screenSize.height);
		
        // get background of entire game on the screen:
        //level 1.1: 5 x 10 images, all the same dimensions
        
        int x = 0;
        int y = 0;
        int xPosition = 0;
        int yPosition = 0;
        int height = 0;
        int width = 0;
        
        for (int nextBackgroundSlice = 1; nextBackgroundSlice < 51; ++nextBackgroundSlice)
            {
            CCSprite* floor = [[CCSprite alloc] initWithFile:[NSString stringWithFormat:@"level-01-part-01_%02d.png", nextBackgroundSlice]];
            
            if (yPosition == 0  &&  x == 0  &&  y == 0)
                {
                y = 1;
                yPosition = 3 * [floor boundingBox].size.height;
                }
            
            floor.anchorPoint = ccp(0, 0);
            floor.position = ccp(xPosition, yPosition);
            
            [_backgroundLayer addChild:floor z:-5];
            
            xPosition += floor.contentSize.width;
            
            ++x;
            
            if (x == 5)
                {
                width += floor.contentSize.width;
                }
                
            if (x == 10)
                {
                x = 0;
                xPosition = 0;
                width += floor.contentSize.width;
                yPosition -= 1 * [floor boundingBox].size.height;
                height += floor.contentSize.height;
                }
            
            if (nextBackgroundSlice == 50)
                {
                xPosition -= floor.contentSize.width;
                    _levelWidth = width;
                    _levelHeight = height;
                }
            }
            
            
        // get blue ground platform on the screen
        // from from x = 0 to 2048 at height 1530
        for ( int plat_x = 0; plat_x < 2048/CC_CONTENT_SCALE_FACTOR(); )
        {
            int platformWidth = 0;
            int platformPlacementY = 170;//1530/CC_CONTENT_SCALE_FACTOR();
            CGPoint pointForPlatform = ccp(0, platformPlacementY);
            
            if ( plat_x + platformWidth < 2048/CC_CONTENT_SCALE_FACTOR())
            {
                pointForPlatform = ccp(plat_x, platformPlacementY);
                platformWidth = [self createGroundWithPoint: pointForPlatform];
                plat_x += platformWidth;
            }
            
            if ( plat_x + platformWidth > 2048/CC_CONTENT_SCALE_FACTOR() )
            {
                plat_x = 2048/CC_CONTENT_SCALE_FACTOR() - platformWidth;
                pointForPlatform = ccp(plat_x, platformPlacementY);
                [self createGroundWithPoint: pointForPlatform];
                break;
            }

            
        }
            
        // get blue ground platform on the screen
        // from from x = 2048 to 3173 at height 3070
        for ( int plat_x = 2048; plat_x < 3173/CC_CONTENT_SCALE_FACTOR(); )
        {
            int platformWidth = 0;
            int platformPlacementY = 150;//3070/CC_CONTENT_SCALE_FACTOR();
            CGPoint pointForPlatform = ccp(0, platformPlacementY);
            
            if ( plat_x + platformWidth < 3173/CC_CONTENT_SCALE_FACTOR())
            {
                pointForPlatform = ccp(plat_x, platformPlacementY);
                platformWidth = [self createGroundWithPoint: pointForPlatform];
                plat_x += platformWidth;
            }
            
            if ( plat_x + platformWidth > 3173/CC_CONTENT_SCALE_FACTOR() )
            {
                plat_x = 3173/CC_CONTENT_SCALE_FACTOR() - platformWidth;
                pointForPlatform = ccp(plat_x, platformPlacementY);
                [self createGroundWithPoint: pointForPlatform];
                break;
            }
            
            
        }
            
        // get blue ground platform on the screen
        // from from x = 3173 to 7038 at height 1530
        for ( int plat_x = 3173; plat_x < 7038/CC_CONTENT_SCALE_FACTOR(); )
        {
            int platformWidth = 0;
            int platformPlacementY = 140;//1530/CC_CONTENT_SCALE_FACTOR();
            CGPoint pointForPlatform = ccp(0, platformPlacementY);
            
            if ( plat_x + platformWidth < 7038/CC_CONTENT_SCALE_FACTOR())
            {
                pointForPlatform = ccp(plat_x, platformPlacementY);
                platformWidth = [self createGroundWithPoint: pointForPlatform];
                plat_x += platformWidth;
            }
            
            if ( plat_x + platformWidth > 7038/CC_CONTENT_SCALE_FACTOR() )
            {
                plat_x = 7038/CC_CONTENT_SCALE_FACTOR() - platformWidth;
                pointForPlatform = ccp(plat_x, platformPlacementY);
                [self createGroundWithPoint: pointForPlatform];
                break;
            }
            
            
        }
        
        // Green blocks placed on top of your platforms.  Creating out collision and ground for platform.
        for (int i = 0; i < 3; i++)
        {
            // get black platform on the screen
            _blackPlatform = [[KKPixelMaskSprite alloc] initWithFile:@"blackPlatform.png" alphaThreshold:0];
            _blackPlatform.anchorPoint = ccp(0,0);
            _blackPlatform.position = ccp(800 + i * 350, 400 + ( i * 1.5 *  140));
            [_levelObjectsLayer addChild: _blackPlatform z:2 tag:1];
       
            // get green platform on the screen
            _greenPlatform = [[KKPixelMaskSprite alloc] initWithFile:@"greenPlatform.png" alphaThreshold:0];
            _greenPlatform.anchorPoint = ccp(0,0);
            _greenPlatform.position = ccp(_blackPlatform.position.x, _blackPlatform.position.y + _blackPlatform.contentSize.height);
            [_levelObjectsLayer addChild: _greenPlatform z:0 tag:2];
            
            _greenPlatform.tag = 2;
            [_springs addObject:_blackPlatform];
            [_platforms addObject:_greenPlatform];
        }
            
        // Walls. This list will create the set of walls for the game.  tag = 1 for left (blocking right movement)
        // and tag = 2 for right (blocking left movement)
        {
            KKMutablePixelMaskSprite* wall1 = [[KKMutablePixelMaskSprite alloc] init];
            
            // Left wall
            wall1.position = ccp( 1800, 100);
            wall1.anchorPoint = ccp(0,0);
            
            [self setupExtendedSprite:wall1  withInitialFrame:@"wall.png"];
            [_levelObjectsLayer addChild:wall1 z:0];
            wall1.tag = 1;
            [_walls addObject:wall1];
            
            KKMutablePixelMaskSprite* wall2 = [[KKMutablePixelMaskSprite alloc] init];
            // Right wall
            wall2.anchorPoint = ccp( 0,0);
            wall2.position = ccp( 250, 100);
            
            [self setupExtendedSprite:wall2  withInitialFrame:@"wall.png"];
            [_levelObjectsLayer addChild:wall2 z:0];
            wall2.tag = 2;
            [_walls addObject:wall2];
        
        }
            
        
        // get health on the screen
        CCLabelTTF* health = [CCLabelTTF labelWithString:@"Health" fontName:@"Arial" fontSize:20];
        health.position = ccp(0.5 * health.contentSize.width, director.screenSize.height - (0.5f * health.contentSize.height));
        health.color = ccBLACK;
        //[_hudLayer addChild: health];
        
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
        
        self.anchorPoint = ccp(0,0);
        self.position = ccp(0,0);
        
        _backgroundLayer.anchorPoint = ccp(0,0);
        _backgroundLayer.position = ccp(0,0);

        _foregroundLayer.anchorPoint = ccp(0,0);
        _foregroundLayer.position = ccp(0,0);

        _enemiesLayer.anchorPoint = ccp(0,0);
        _enemiesLayer.position = ccp(0,0);

        _levelObjectsLayer.anchorPoint = ccp(0,0);
        _levelObjectsLayer.position = ccp(0,0);

        _stageAssistorsLayer.anchorPoint = ccp(0,0);
        _stageAssistorsLayer.position = ccp(0,0);

        _hudLayer.anchorPoint = ccp(0,0);
        _hudLayer.position = ccp(0,0);

        [self addChild: _backgroundLayer z: 1];
        [self addChild: _levelObjectsLayer z: 2];
        [self addChild: _stageAssistorsLayer z: 3];
        [self addChild: _enemiesLayer z: 4];
        [_ruffsLayer addChild: _ruffSprite];
        [self addChild: _ruffsLayer z: 5];
        [self addChild: _foregroundLayer z: 6];
        [self addChild: _hudLayer z: 7];
        }
    
    return self;
}

-(int)createGroundWithPoint:(CGPoint) platformPoint
{
    KKMutablePixelMaskSprite* platform3 = [[KKMutablePixelMaskSprite alloc] init];
    [self setupExtendedSprite:platform3  withInitialFrame:@"ground.png"];
    
    platform3.anchorPoint = ccp(0,0);
    platform3.position = ccp(platformPoint.x, platformPoint.y);
    
    [_levelObjectsLayer addChild: platform3 z: 6];
    platform3.tag = 3;
    [_grounds addObject:platform3];
    return (int)platform3.contentSize.width;
}

-(void)updateLevelLayerPositions
{
    _foregroundLayer.position = _backgroundLayer.position;
    _enemiesLayer.position = _backgroundLayer.position;
    _levelObjectsLayer.position = _backgroundLayer.position;
    _stageAssistorsLayer.position = _backgroundLayer.position;
    _ruffsLayer.position = _backgroundLayer.position;;
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
        CGPoint normalizedTouch = [_hudLayer convertToWorldSpace:touch.location];
        
        leftMovementTap = normalizedTouch.x < leftControlOfLeftCircle;
        rightMovementTap = normalizedTouch.x > rightControlOfLeftCircle  &&  normalizedTouch.x < _leftCirclePosition.x + 100;

        // detect any touches within the left control circle
        if (normalizedTouch.x <= _leftCirclePosition.x + 100  &&
            normalizedTouch.y <= _leftCirclePosition.y + 100  &&
            ! CGPointEqualToPoint(normalizedTouch, CGPointZero))
            {
            if (!_isMoving  &&  (leftMovementTap  || rightMovementTap))
                {
                _isMoving = YES;
                
                _ruffSprite.flipX = rightMovementTap ? NO : YES;
                }
            }

        // detect any touches within the right control circle
        if (normalizedTouch.x >= _rightCirclePosition.x - 100  &&
            normalizedTouch.y <= _leftCirclePosition.y + 100  &&
            ! CGPointEqualToPoint(normalizedTouch, CGPointZero))
            {
            // check if we need to jump
            if (!_isJumping  &&  normalizedTouch.y >= 0.65f * (_rightCirclePosition.y + 100)  &&  (_gameTime - _landingTime) > 3.0f * 0.04167f)
                {
                _isJumping = YES;
                _initialJumpSpeed = RUFF_JUMP_SPEED;
                //_initialJumpTime = _lastJumpTime;
                _initialJumpTime = _gameTime;
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
    
    _changeOfY = 0;
    
    if ((_jumpTime - _initialJumpTime) >= (2.0f * 0.04167f))
        {
        _jumpTime -= 2.0 * 0.04167f;
        _lastJumpTime -= 2.0 * 0.04167f;
        
        // here b/c we probably need a function to detect if ground below has changed our baseY
        // from where we first started our jump
        // otherwise, we could fall through part of the ground when we land
        int baseY = _ruffBaseY;

        // here is how we're calculating the change of y: (At^2 + vt) - (At0^2 + vt0)
        _changeOfY = ((GRAVITY * (_jumpTime-_initialJumpTime) * (_jumpTime-_initialJumpTime)) + (velocity * (_jumpTime-_initialJumpTime)))  -
                          ((GRAVITY * (_lastJumpTime-_initialJumpTime) * (_lastJumpTime-_initialJumpTime)) + (velocity * (_lastJumpTime-_initialJumpTime)));
        projectedY = currentYOfRuff + _changeOfY;

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
        if (_ruffSprite.position.x >= ground.position.x && ground.position.x + ground.contentSize.width >= _ruffSprite.position.x )
        {
            _defaultGround = (ground.position.y + ground.contentSize.height);

            return _defaultGround;
        }
        
    }
    
    return _ruffBaseY;
}

-(BOOL) didRuffCollideWithAPlatform: (CGPoint) lastRuffMovementPosition
{
    
    for (KKPixelMaskSprite* platform in _platforms)
    {
        if ((lastRuffMovementPosition.y >= (int)(platform.position.y )))
        {
            if ([ _ruffSprite pixelMaskIntersectsNode: platform])
            {
                _ruffBaseY =  platform.position.y;
                _defaultGround = _ruffBaseY;
                return YES;
            }
        }
    }
    
    return NO;
}

-(float) didRuffCollideWithAWall: (float) lastRuffMovementPositionX
{
    float ruffsCurrentPositionX = _ruffSprite.position.x;
    
    _ruffSprite.position = ccp(lastRuffMovementPositionX, _ruffSprite.position.y);
    
    for (KKPixelMaskSprite* wall in _walls)
    {
        if ( [_ruffSprite pixelMaskIntersectsNode: wall])
        {
            // going right
            if ( lastRuffMovementPositionX + _ruffSprite.contentSize.width >= wall.position.x && !_ruffSprite.flipX && lastRuffMovementPositionX < wall.position.x )
            {
                lastRuffMovementPositionX = wall.position.x - _ruffSprite.contentSize.width;
                break;
            }
            // going left
            else if ( (lastRuffMovementPositionX <= (wall.position.x + wall.contentSize.width)) && _ruffSprite.flipX && ((lastRuffMovementPositionX + _ruffSprite.contentSize.width) > (wall.position.x + wall.contentSize.width)))
            {
                lastRuffMovementPositionX = wall.position.x + wall.contentSize.width;
                break;
            }
            else
            {
                CCLOG(@"Colission with wall but didn't hit an condition");
            }
        }
        else
        {
            _ruffSprite.position = ccp(ruffsCurrentPositionX, _ruffSprite.position.y);
        }
    }
    
    return lastRuffMovementPositionX;
}

-(BOOL) didRuffCollideWithASpring: (CGPoint) lastRuffMovementPosition
{
    
    for (KKPixelMaskSprite* spring in _springs)
    {
        if ([ _ruffSprite pixelMaskIntersectsNode: spring])
        {
            return YES;
        }
    }
    
    return NO;
}


-(void) update:(ccTime)delta
{
    float ruffContentWidth = !_isJumping && !_ruffSprite.flipX ? _ruffSprite.contentSize.width : 167;
    CGPoint lastRuffMovementPosition = _ruffSprite.position;

    _gameTimeDelta = delta;
    _gameTime += delta;
    _jumpTime = _gameTime;
    
    _isMoving = YES;

    [self gestureRecognitionWithPositionOfRuff: lastRuffMovementPosition];

    // check for jump FIRST, then moving
    if (_isJumping)
        {
        _isRunning = NO;
        
        lastRuffMovementPosition.y = (int)[self makeRuffJump: lastRuffMovementPosition.y withVelocity: _initialJumpSpeed];
        }
    
    if ( [self didRuffCollideWithASpring:lastRuffMovementPosition] )
    {
        _isRunning = NO;
        
        lastRuffMovementPosition.y = (int)[self makeRuffJump: lastRuffMovementPosition.y withVelocity: RUFF_JUMP_SPEED * 8 ];
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
        //lastRuffMovementPosition.x += _ruffSprite.flipX ? -(RUFF_SPEED * delta) : (RUFF_SPEED * delta); //changes the x
        
        if (_ruffSprite.position.x > _levelWidth - 300)
        {
            _ruffSprite.flipX = YES;
            lastRuffMovementPosition.x -= (RUFF_SPEED * delta);
        }
        else if ( _ruffSprite.position.x < 300)
        {
            _ruffSprite.flipX = NO;
            lastRuffMovementPosition.x += (RUFF_SPEED * delta);
        }
        else
        {
            lastRuffMovementPosition.x += _ruffSprite.flipX ? -(RUFF_SPEED * delta) : (RUFF_SPEED * delta);
        }
        
        // Claping the sides to the width of the level.
        if ( 0 < _backgroundLayer.position.x )
            {
            _backgroundLayer.position = ccp(0, _backgroundLayer.position.y);
            }
        else if ( _backgroundLayer.position.x + _levelWidth <  [[CCDirector sharedDirector] screenSize].width)
            {
            _backgroundLayer.position = ccp( -_levelWidth + [[CCDirector sharedDirector] screenSize].width, _backgroundLayer.position.y);
            }
            
        // Moving the left side of the screen when ruff reaches a certain percentage of the screen.
        if ( (lastRuffMovementPosition.x  < 0.35 * [[CCDirector sharedDirector] screenSize].width - _backgroundLayer.position.x ) && _ruffSprite.flipX)
            {
                if ( 0 <= _backgroundLayer.position.x )
                {
                    if ( lastRuffMovementPosition.x <= 0)
                    {
                        lastRuffMovementPosition.x = 0;
                    }
                }
                else
                {
                    _backgroundLayer.position = ccp( _backgroundLayer.position.x + (RUFF_SPEED * delta), _backgroundLayer.position.y);
                    lastRuffMovementPosition.x = 0.35 * [[CCDirector sharedDirector] screenSize].width - _backgroundLayer.position.x ;
                }
            }
        else if (lastRuffMovementPosition.x + ruffContentWidth > 0.65 * [[CCDirector sharedDirector] screenSize].width - _backgroundLayer.position.x  && !_ruffSprite.flipX)
            {
                if ( _backgroundLayer.position.x + _levelWidth <=  [[CCDirector sharedDirector] screenSize].width )
                {
                    if ( lastRuffMovementPosition.x + _ruffSprite.contentSize.width >= _levelWidth )
                    {
                        lastRuffMovementPosition.x = _levelWidth - _ruffSprite.contentSize.width;
                    }
                }
                else
                {
                    _backgroundLayer.position = ccp( _backgroundLayer.position.x - (RUFF_SPEED * delta), _backgroundLayer.position.y);
                    lastRuffMovementPosition.x = 0.65 * [[CCDirector sharedDirector] screenSize].width - ruffContentWidth - _backgroundLayer.position.x ;
                }
            }
        
        
            
        _isMoving = NO;
        
        }

    if ([ _ruffSprite pixelMaskIntersectsNode: _platform3])
        {
            CCLOG(@"blue platform");
        }

    float testY = [self getRuffsBaseY];
    
    if ( [self didRuffCollideWithAPlatform:lastRuffMovementPosition] )
        {
        CCLOG(@"green platform");
        }
    else if (_ruffBaseY != testY )
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
    
    if ( lastRuffMovementPosition.y + _ruffSprite.contentSize.height > 0.8 * [[CCDirector sharedDirector] screenSize].height - _backgroundLayer.position.y )
    {
        _backgroundLayer.position = ccp( (int)_backgroundLayer.position.x, (int)(_backgroundLayer.position.y - _changeOfY) );
    }
    if ( lastRuffMovementPosition.y  < 0.2 * [[CCDirector sharedDirector] screenSize].height - _backgroundLayer.position.y )
    {
        _backgroundLayer.position = ccp( (int)_backgroundLayer.position.x, (int)(_backgroundLayer.position.y - _changeOfY) );
    }

    

    lastRuffMovementPosition.x = [ self didRuffCollideWithAWall: lastRuffMovementPosition.x];

    _ruffSprite.position = ccp((int)lastRuffMovementPosition.x, (int)lastRuffMovementPosition.y);

    // updates all level layers positions with the background layers position
    [self updateLevelLayerPositions];
    
    _ruffSprite.previousPosition = _ruffSprite.position;
    
    _lastJumpTime = _gameTime;

}
@end