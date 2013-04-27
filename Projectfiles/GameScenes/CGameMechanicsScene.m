
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
-(void) LoadLevelResources;


@end


@implementation CGameMechanicsScene


// addPixelMaskSpriteFramesToCacheWithFile =====================================
// 
// =============================================================================
-(NSUInteger) addPixelMaskSpriteFramesToCacheWithFile: (NSString*)spriteSheetFilename
{
    //CCTexture2D* texture = [[CCTexture2D alloc] in]
    
    NSUInteger numberOfFrames = 0;
    
    // add the sprite sheet to the sprite cache
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: spriteSheetFilename];
    
    // now let's look at the plist which loaded the spritesheet, and grab all the sprite frame names
    // so that we can extend them with the pixel mask, and re-add them to the frame cache
    NSDictionary* dictionaryOfSpriteSheetContents = [NSDictionary dictionaryWithContentsOfFile: [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:spriteSheetFilename]];
    NSDictionary* dictionaryOfSpriteFrameNames = [NSDictionary dictionaryWithDictionary:[dictionaryOfSpriteSheetContents objectForKey:@"frames"]];
    KKMutablePixelMaskSprite* dummySprite = [[KKMutablePixelMaskSprite alloc] init];
    
    for (NSString* nextFrameName in dictionaryOfSpriteFrameNames)
        {
        [dummySprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:nextFrameName]];
        
        CCSpriteFrameExtended* pixelMaskFrame = [dummySprite createPixelMaskWithCurrentFrame];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:pixelMaskFrame name:nextFrameName];

        ++numberOfFrames;
        }
    
    return numberOfFrames;
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
        _invisibleObjectsLayer = [CCLayer node];
        _skyBackgroundLayer = [CCLayer node];
        _farBackgroundLayer = [CCLayer node];
        _backgroundLayer = [CCLayer node];
        _midGroundLayer = [CCLayer node];
        _levelObjectsLayer = [CCLayer node];
        _stageAssistorsLayer = [CCLayer node];
        _enemiesLayer = [CCLayer node];
        _ruffsLayer = [CCLayer node];
        _foregroundLayer = [CCLayer node];
        _hudLayer = [CHudLayer node];
        
        // must use this when click premultiplied alpha in texture packer
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];

        
        // get ruff sprite on the screen
        _ruffSprite = [[CYoungRuff alloc] initRuff:0];
		_ruffSprite.anchorPoint = ccp(0,0);
        _ruffSprite.position = ccp(500, 2000);
        
        [self setupExtendedSprite:_ruffSprite withSpritesheet:@"ruff-sprite-sheet.plist" andInitialFrameName:@"ruff-ready-01.png"];
        
        // enemy stuff
        [self addPixelMaskSpriteFramesToCacheWithFile: @"flower-sprite-sheet.plist"];
        [self addPixelMaskSpriteFramesToCacheWithFile: @"owl-sprite-sheet.plist"];
        [self addPixelMaskSpriteFramesToCacheWithFile: @"snail-sprite-sheet.plist"];
        
        _owlEnemies = [[NSMutableArray alloc] init];
        _snailEnemies = [[NSMutableArray alloc] init];
        _flowerEnemies = [[NSMutableArray alloc] init];
        
        
        CFlower* flower = [[CFlower alloc] initFlower];
        [self setupExtendedSprite: flower   withInitialFrame:@"flower-attack-01.png"];
        // get flower sprite on the screen
		flower.anchorPoint = ccp(0,0);
        flower.position = ccp(2400, 765);
        
        [_enemiesLayer addChild: flower];
        
        CCDirector* director = [CCDirector sharedDirector];
            
        _defaultGround = 0;
        _grounds = [[NSMutableArray alloc] init];
        _platforms = [[NSMutableArray alloc] init];
        _springs = [[NSMutableArray alloc] init];
        _walls = [[NSMutableArray alloc] init];
        
        _platform3 = [[KKMutablePixelMaskSprite alloc] init];
        _platform3.anchorPoint = ccp(0,0);
        _platform3.position = ccp(0,0);
        [self setupExtendedSprite:_platform3 withSpritesheet:@"platforms-sprite-sheet.plist" andInitialFrameName:@"wall.png"];
        
        
        KKInput* input = [KKInput sharedInput];
        
        // explicitly set the background color of the screen to black
		glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    
        
        CGSize sizeOfLayer;
        
        // 8bit color format w/out transparency
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_A8];
        
        sizeOfLayer = [self loadImageSlicesIntoLayer:_skyBackgroundLayer withImageName:@"act-01-level-01-part-01-skyBackground-" totalNumberOfSlices:1 totalNumberOfRows:1 totalNumberOfColumnsPerRow:1];
        
        _levelWidth = 12384;//sizeOfLayer.width;
        _levelHeight = 2583;//sizeOfLayer.height;
        
        // 16 bit color best quality w/transparency
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];
        sizeOfLayer = [self loadImageSlicesIntoLayer:_farBackgroundLayer withImageName:@"act-01-level-01-part-01-farBackground-" totalNumberOfSlices:1 totalNumberOfRows:1 totalNumberOfColumnsPerRow:1];
        
        _farBackgroundWidth = sizeOfLayer.width;
        _farBackgroundHeight = sizeOfLayer.height;
        
        //32 bit, highest quality w/transparency
        //[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        sizeOfLayer = [self loadImageSlicesIntoLayer:_backgroundLayer withImageName:@"act-01-level-01-part-01-background-" totalNumberOfSlices:2 totalNumberOfRows:1 totalNumberOfColumnsPerRow:2];
        
        _backgroundWidth = sizeOfLayer.width;
        _backgroundHeight = sizeOfLayer.height;
        
        sizeOfLayer = [self loadImageSlicesIntoLayer:_foregroundLayer withImageName:@"act-01-level-01-part-01-foreground-" totalNumberOfSlices:3 totalNumberOfRows:1 totalNumberOfColumnsPerRow:3];
        
        sizeOfLayer = [self loadImageSlicesIntoLayer:_midGroundLayer withImageName:@"act-01-level-01-part-01-midground-" totalNumberOfSlices:3 totalNumberOfRows:1 totalNumberOfColumnsPerRow:3];
            
        

            
            // Level 1
            // Ground
            [self createResourceWithImage:@"greenPlatform.png" atHeight:764 fromXPosition:0 toEndXPosition:1024 intoList:_platforms]; // Up to tree
            [self createResourceWithImage:@"greenPlatform.png" atHeight:1509 fromXPosition:1024 toEndXPosition:1586.5 intoList:_platforms]; // Tree top
            [self createResourceWithImage:@"greenPlatform.png" atHeight:764 fromXPosition:1586.5 toEndXPosition:3519 intoList:_platforms]; // After tree
            [self createResourceWithImage:@"greenPlatform.png" atHeight:205 fromXPosition:3519 toEndXPosition:5194 intoList:_platforms]; // Drop area
            
            // Platforms
            [self createResourceWithImage:@"greenPlatform.png" atHeight:1280 fromXPosition:1950 toEndXPosition: 2098 intoList: _platforms]; // Leaf 1
            [self createResourceWithImage:@"greenPlatform.png" atHeight:1040 fromXPosition:2415 toEndXPosition: 2600 intoList: _platforms]; // Leaf 2
            [self createResourceWithImage:@"greenPlatform.png" atHeight:950 fromXPosition:700 toEndXPosition:1080 intoList: _platforms]; //Mushroom
            [self createResourceWithImage:@"greenPlatform.png" atHeight:975 fromXPosition:3519 toEndXPosition:3894 intoList: _platforms]; // First branch
            [self createResourceWithImage:@"greenPlatform.png" atHeight:1185 fromXPosition:3894 toEndXPosition:4269 intoList: _platforms]; // Second branch
            [self createResourceWithImage:@"greenPlatform.png" atHeight:1395 fromXPosition:4269 toEndXPosition:4744 intoList: _platforms]; // Third branch
            [self createResourceWithImage:@"greenPlatform.png" atHeight:415 fromXPosition:3519 toEndXPosition:3875 intoList: _platforms]; // Cliff ledge
            [self createResourceWithImage:@"greenPlatform.png" atHeight:650 fromXPosition:3519 toEndXPosition:3629 intoList: _platforms]; // Cliff assister
            
            
            
        // Spring
//        [self createResourceWithImage:@"blackPlatform.png" atHeight:1275 fromXPosition:750 toEndXPosition:1124 intoList: _springs];
        for (int i = 0; i < 3; i++)
        {
            // get black platform on the screen
            _blackPlatform = [[KKPixelMaskSprite alloc] initWithFile:@"blackPlatform.png" alphaThreshold:0];
            _blackPlatform.anchorPoint = ccp(0,0);
            _blackPlatform.position = ccp(674 + i * _blackPlatform.contentSize.width, 1275);
            [_levelObjectsLayer addChild: _blackPlatform z:2 tag:1];
       
            _greenPlatform.tag = 2;
            [_springs addObject:_blackPlatform];
        }
        
            // Walls. This list will create the set of walls for the game.
            // Level 1
            [self createResourceWithImage:@"wall.png" atPosition:1024 fromYPosition:745 toEndYPosition:1490 intoList:_walls]; // left of tree
            [self createResourceWithImage:@"wall.png" atPosition:1486 fromYPosition:745 toEndYPosition:1490 intoList:_walls]; // right of tree
            [self createResourceWithImage:@"wall.png" atPosition:3419 fromYPosition:185 toEndYPosition:745 intoList:_walls]; // drop left
            [self createResourceWithImage:@"wall.png" atPosition:5194 fromYPosition:185 toEndYPosition:1395 intoList:_walls]; // drop right
            // Level 2
            [self createResourceWithImage:@"wall.png" atPosition:5706 fromYPosition:765 toEndYPosition:1395 intoList:_walls]; // first drop
            [self createResourceWithImage:@"wall.png" atPosition:7681 fromYPosition:765 toEndYPosition:960 intoList:_walls]; // first step
            [self createResourceWithImage:@"wall.png" atPosition:8056 fromYPosition:975 toEndYPosition:1170 intoList:_walls]; // second step
            [self createResourceWithImage:@"wall.png" atPosition:8706 fromYPosition:-3015 toEndYPosition:1170 intoList:_walls]; // big drop left
            [self createResourceWithImage:@"wall.png" atPosition:9369 fromYPosition:-2805 toEndYPosition:1605 intoList:_walls]; // big drop right
            [self createResourceWithImage:@"wall.png" atPosition:10494 fromYPosition:-3015 toEndYPosition:-2595 intoList:_walls];
            [self createResourceWithImage:@"wall.png" atPosition:11244 fromYPosition:-2595 toEndYPosition:-1825 intoList:_walls];
        
        
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
        
        [_ruffsLayer addChild: _ruffSprite];
        
        self.anchorPoint = ccp(0,0);
        self.position = ccp(0,0);
        
        _invisibleObjectsLayer.anchorPoint = ccp(0,0);
        _invisibleObjectsLayer.position = ccp(0,0);
        
        _skyBackgroundLayer.anchorPoint = ccp(0,0);
        _skyBackgroundLayer.position = ccp(0,0);//-1530);
        
        _farBackgroundLayer.anchorPoint = ccp(0,0);
        _farBackgroundLayer.position = ccp(0,480);
        
        _backgroundLayer.anchorPoint = ccp(0,0);
        _backgroundLayer.position = ccp(0,0); // 40 is how far in the grass do we want ruff to be in
        
        _midGroundLayer.anchorPoint = ccp(0,0);
        _midGroundLayer.position = ccp(0,-1530);
        
        _foregroundLayer.anchorPoint = ccp(0,0);
        _foregroundLayer.position = ccp(0, -1530);
        
        _enemiesLayer.anchorPoint = ccp(0,0);
        _enemiesLayer.position = ccp(0,0);
        
        _levelObjectsLayer.anchorPoint = ccp(0,0);
        _levelObjectsLayer.position = ccp(0,0);
        
        _stageAssistorsLayer.anchorPoint = ccp(0,0);
        _stageAssistorsLayer.position = ccp(0,0);
        
        _hudLayer.anchorPoint = ccp(0,0);
        _hudLayer.position = ccp(0,0);
        
        _ruffsLayer.anchorPoint = ccp(0,0);
        _ruffsLayer.position = ccp(0,0);
        
        [self addChild: _invisibleObjectsLayer z: 0];
        
        [self addChild: _skyBackgroundLayer z: 1];
        [self addChild: _farBackgroundLayer z: 2];
        [self addChild: _backgroundLayer z: 3];
        [self addChild: _midGroundLayer z: 4];
        
        [self addChild: _levelObjectsLayer z: -15];
        [self addChild: _stageAssistorsLayer z: 6];
        
        [self addChild: _enemiesLayer z: 7];
        [self addChild: _ruffsLayer z: 7];
        
        [self addChild: _foregroundLayer z: 8];
        [self addChild: _hudLayer z: 9];
        
        // load resources after init
        [self scheduleOnce: @selector(LoadLevelResources) delay:0];
        }
    
    return self;
}


-(void) LoadLevelResources
{
    self.touchEnabled = NO;
    
    // Loading images for level 2
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];
    // Image L2-1-1 forground then background
    CCSprite* level2_1_1_F = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-foreground-row-01-001.png"];
    level2_1_1_F.anchorPoint = ccp(0, 0);
    level2_1_1_F.position = ccp(5244, 1750);
    [_foregroundLayer addChild:level2_1_1_F z:0];
    
    
    // Image L2-2-1 forground then background
    CCSprite* level2_2_1_F = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-foreground-row-02-001.png"];
    level2_2_1_F.anchorPoint = ccp(0, 0);
    level2_2_1_F.position = ccp(5244, 521);
    [_foregroundLayer addChild:level2_2_1_F z:0];
    CCSprite* level2_2_1_M = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-midground-row-02-001.png"];
    level2_2_1_M.anchorPoint = ccp(0, 0);
    level2_2_1_M.position = ccp(5244, 521);
    [_midGroundLayer addChild:level2_2_1_M z:0];
    
    // Image L2-2-2 forground then background
    CCSprite* level2_2_2_F = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-foreground-row-02-002.png"];
    level2_2_2_F.anchorPoint = ccp(0, 0);
    level2_2_2_F.position = ccp(7292, 521);
    [_foregroundLayer addChild:level2_2_2_F z:0];
    CCSprite* level2_2_2_M = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-midground-row-02-002.png"];
    level2_2_2_M.anchorPoint = ccp(0, 0);
    level2_2_2_M.position = ccp(7292, 521);
    [_midGroundLayer addChild:level2_2_2_M z:0];
    
    // Image L2-2-3 forground then background
    CCSprite* level2_2_3_F = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-foreground-row-02-003.png"];
    level2_2_3_F.anchorPoint = ccp(0, 0);
    level2_2_3_F.position = ccp(8305, -297);
    [_foregroundLayer addChild:level2_2_3_F z:0];
    CCSprite* level2_2_3_M = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-midground-row-02-003.png"];
    level2_2_3_M.anchorPoint = ccp(0, 0);
    level2_2_3_M.position = ccp(8305, -297);
    [_midGroundLayer addChild:level2_2_3_M z:0];
    
    // Image L2-3-1 forground then background
    CCSprite* level2_3_1_F = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-foreground-row-03-001.png"];
    level2_3_1_F.anchorPoint = ccp(0, 0);
    level2_3_1_F.position = ccp(8305, -2345);
    [_foregroundLayer addChild:level2_3_1_F z:0];
    CCSprite* level2_3_1_M = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-midground-row-03-001.png"];
    level2_3_1_M.anchorPoint = ccp(0, 0);
    level2_3_1_M.position = ccp(8305, -2345);
    [_midGroundLayer addChild:level2_3_1_M z:0];
    
    // Image L2-4-1 forground then background
    CCSprite* level2_4_1_F = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-foreground-row-04-001.png"];
    level2_4_1_F.anchorPoint = ccp(0, 0);
    level2_4_1_F.position = ccp(8305, -3231);
    [_foregroundLayer addChild:level2_4_1_F z:0];
    CCSprite* level2_4_1_M = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-midground-row-04-001.png"];
    level2_4_1_M.anchorPoint = ccp(0, 0);
    level2_4_1_M.position = ccp(8305, -3231);
    [_midGroundLayer addChild:level2_4_1_M z:0];
    
    // Image L2-4-2 forground then background
    CCSprite* level2_4_2_F = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-foreground-row-04-002.png"];
    level2_4_2_F.anchorPoint = ccp(0, 0);
    level2_4_2_F.position = ccp(9469, -3231);
    [_foregroundLayer addChild:level2_4_2_F z:0];
    CCSprite* level2_4_2_M = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-midground-row-04-002.png"];
    level2_4_2_M.anchorPoint = ccp(0, 0);
    level2_4_2_M.position = ccp(9469, -3231);
    [_midGroundLayer addChild:level2_4_2_M z:0];
    
    // Image L2-4-3 forground then background
    CCSprite* level2_4_3_F = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-foreground-row-04-003.png"];
    level2_4_3_F.anchorPoint = ccp(0, 0);
    level2_4_3_F.position = ccp(11517, -3231);
    [_foregroundLayer addChild:level2_4_3_F z:0];
    CCSprite* level2_4_3_M = [[CCSprite alloc] initWithFile:@"act-01-level-01-part-02-midground-row-04-003.png"];
    level2_4_3_M.anchorPoint = ccp(0, 0);
    level2_4_3_M.position = ccp(11517, -3231);
    [_midGroundLayer addChild:level2_4_3_M z:0];
    
    // Level 2
    // Ground
    [self createResourceWithImage:@"greenPlatform.png" atHeight:1395 fromXPosition:5144 toEndXPosition:5806 intoList:_platforms]; // start
    [self createResourceWithImage:@"greenPlatform.png" atHeight:755 fromXPosition:5806 toEndXPosition:7681 intoList:_platforms]; // first drop
    [self createResourceWithImage:@"greenPlatform.png" atHeight:965 fromXPosition:7681 toEndXPosition:8056 intoList:_platforms]; // first step
    [self createResourceWithImage:@"greenPlatform.png" atHeight:1175 fromXPosition:8056 toEndXPosition:8806 intoList:_platforms]; // second step
    [self createResourceWithImage:@"greenPlatform.png" atHeight:-3028 fromXPosition:8806 toEndXPosition:10494 intoList:_platforms]; // cave bottom
    [self createResourceWithImage:@"greenPlatform.png" atHeight:-2580 fromXPosition:10494 toEndXPosition:11244 intoList:_platforms]; // cave step
    [self createResourceWithImage:@"greenPlatform.png" atHeight:-1803 fromXPosition:11244 toEndXPosition:12384 intoList:_platforms]; // level exit
    
    // Platforms
    [self createResourceWithImage:@"greenPlatform.png" atHeight:760 fromXPosition:9044 toEndXPosition:9419 intoList:_platforms]; // top platform
    [self createResourceWithImage:@"greenPlatform.png" atHeight:335 fromXPosition:8806 toEndXPosition:9181 intoList:_platforms]; // middle platform
    [self createResourceWithImage:@"greenPlatform.png" atHeight:-85 fromXPosition:9044 toEndXPosition:9410 intoList:_platforms]; // bottom platform
    [self createResourceWithImage:@"greenPlatform.png" atHeight:-2815 fromXPosition:10194 toEndXPosition:10494 intoList:_platforms]; // first step shelf for assister
    [self createResourceWithImage:@"greenPlatform.png" atHeight:-2395 fromXPosition:10944 toEndXPosition:11244 intoList:_platforms]; // second step shelf for assister -1
    [self createResourceWithImage:@"greenPlatform.png" atHeight:-2185 fromXPosition:10944 toEndXPosition:11244 intoList:_platforms]; // second step shelf for assister -2
    [self createResourceWithImage:@"greenPlatform.png" atHeight:-1975 fromXPosition:10944 toEndXPosition:11244 intoList:_platforms]; // second step shelf for assister -3
    
    self.touchEnabled = YES;
    
    // update the screen based on fps
    [self scheduleUpdate];
}


-(CGSize)createGroundWithPoint:(CGPoint) platformPoint andImage: (NSString *) imageName inList: (NSMutableArray*) listName
{
    KKMutablePixelMaskSprite* platform3 = [[KKMutablePixelMaskSprite alloc] init];
    [self setupExtendedSprite:platform3  withInitialFrame:imageName];
    
    platform3.anchorPoint = ccp(0,0);
    platform3.position = ccp(platformPoint.x, platformPoint.y);
    
    [_levelObjectsLayer addChild: platform3 z: 6];
    platform3.tag = 3;
    [listName addObject:platform3];
    return CGSizeMake((int)platform3.contentSize.width, (int)platform3.contentSize.height);
}

-(void) createResourceWithImage:(NSString*) imageName atHeight: (int) placementY fromXPosition: (int) startXposition toEndXPosition: (int) endXPosition intoList: listName
{
    for ( int plat_x = startXposition; plat_x < endXPosition; )
    {
        int platformWidth = 0;
        int platformPlacementY = placementY;
        CGPoint pointForPlatform = ccp(0, platformPlacementY);
        
        if ( plat_x + platformWidth < endXPosition)
        {
            pointForPlatform = ccp(plat_x, platformPlacementY);
            platformWidth = [self createGroundWithPoint:ccp(plat_x, platformPlacementY) andImage:imageName inList:listName].width;
            plat_x += platformWidth;
        }
        
        if ( plat_x + platformWidth > endXPosition )
        {
            plat_x = endXPosition - platformWidth;
            pointForPlatform = ccp(plat_x, platformPlacementY);
            [self createGroundWithPoint:ccp(plat_x, platformPlacementY) andImage:imageName inList:listName];
            break;
        }
    }
    
}

-(void) createResourceWithImage:(NSString*) imageName atPosition: (int) placementX fromYPosition: (int) startYposition toEndYPosition: (int) endYPosition intoList: listName
{
    for ( int plat_y = startYposition; plat_y < endYPosition; )
    {
        int platformHeight = 0;
        int platformPlacementX = placementX;
        CGPoint pointForPlatform = ccp(platformPlacementX, plat_y);
        
        if ( plat_y + platformHeight < endYPosition)
        {
            pointForPlatform = ccp(platformPlacementX, plat_y);
            platformHeight = [self createGroundWithPoint:ccp(platformPlacementX, plat_y) andImage:imageName inList:listName].height;
            plat_y += platformHeight;
        }
        
        if ( plat_y + platformHeight > endYPosition )
        {
            plat_y = endYPosition - platformHeight;
            pointForPlatform = ccp(platformPlacementX, plat_y);
            [self createGroundWithPoint:ccp(platformPlacementX, plat_y) andImage:imageName inList:listName];
            break;
        }
    }
    
}

-(CGSize) loadImageSlicesIntoLayer:(CCLayer*)layer withImageName:(NSString*)nameOfImage totalNumberOfSlices:(int)numberOfSlices totalNumberOfRows:(int)numberOfRows totalNumberOfColumnsPerRow:(int)numberOfColumnsPerRow
{
int yMax = numberOfRows;
int x = 1;
int y = yMax - 1;
int xPosition = 0;
int yPosition = 0;
int height = 0;
int width = 0;

for (int nextBackgroundSlice = 0; nextBackgroundSlice < numberOfSlices; ++nextBackgroundSlice, ++x)
    {
    int index = numberOfSlices - ((numberOfColumnsPerRow - y) * yMax) + x;
        
    CCSprite* furthestBackgroundSlice = [[CCSprite alloc] initWithFile:[NSString stringWithFormat:@"%@%03d.png", nameOfImage, index]];
    
    furthestBackgroundSlice.anchorPoint = ccp(0, 0);
    furthestBackgroundSlice.position = ccp(xPosition, yPosition);
    
    [layer addChild:furthestBackgroundSlice z:0];
    
    xPosition += furthestBackgroundSlice.contentSize.width;
    
    // if we have completed a row of slices, reset to the first cell of the next row to make
    if (numberOfColumnsPerRow == x)
        {
        yPosition += furthestBackgroundSlice.contentSize.height;
        
        if (0 == y)
            {
            width = xPosition;
            height = yPosition;
            }
        
        xPosition = 0;
        x = 0;
        --y;
        }
    }
    
    return CGSizeMake(width, height);
}


-(void)updateLevelLayerPositions
{
    _invisibleObjectsLayer.position = _foregroundLayer.position;
    //_skyBackgroundLayer.position = ccp(_foregroundLayer.position.x, _skyBackgroundLayer.position.y);
    _farBackgroundLayer.position = ccp(0.018f * _foregroundLayer.position.x, _farBackgroundLayer.position.y);
    _backgroundLayer.position = ccp(0.10f * _foregroundLayer.position.x, _backgroundLayer.position.y);
    _midGroundLayer.position = _foregroundLayer.position;
    _enemiesLayer.position = _foregroundLayer.position;
    _levelObjectsLayer.position = _foregroundLayer.position;
    _stageAssistorsLayer.position = _foregroundLayer.position;
    _ruffsLayer.position = _foregroundLayer.position;
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
    
    _defaultGround = -1234567;
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
                
            if ( lastRuffMovementPositionX + _ruffSprite.contentSize.width >= wall.position.x && /* ruffs head is inbetween the walls*/
                lastRuffMovementPositionX + _ruffSprite.contentSize.width <= wall.position.x + wall.contentSize.width &&
                !_ruffSprite.flipX /* facing right */ )
            {
                lastRuffMovementPositionX = wall.position.x - _ruffSprite.contentSize.width;
                break;
            }
            // going left
            else if ( (lastRuffMovementPositionX <= (wall.position.x + wall.contentSize.width)) && /* ruffs head is inbetween the walls */
                     ( lastRuffMovementPositionX >= wall.position.x) &&
                     _ruffSprite.flipX /* facing left */ )
            {
                lastRuffMovementPositionX = wall.position.x + wall.contentSize.width;
                break;
            }
            else
            {
                CCLOG(@"Colission with wall but didn't hit any condition");
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
        if ( _changeOfY > 0 )
            {
            lastRuffMovementPosition.y = (int)[self makeRuffJump: lastRuffMovementPosition.y withVelocity: RUFF_JUMP_SPEED * 20 ];
            }
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
        lastRuffMovementPosition.x += _ruffSprite.flipX ? -(RUFF_SPEED * delta) : (RUFF_SPEED * delta); //changes the x
        
        
        if ( 0 < _foregroundLayer.position.x )
            {
            _foregroundLayer.position = ccp(0, _foregroundLayer.position.y);
            }
        else if ( _foregroundLayer.position.x + _levelWidth <  [[CCDirector sharedDirector] screenSize].width)
            {
            _foregroundLayer.position = ccp( -_levelWidth + [[CCDirector sharedDirector] screenSize].width, _foregroundLayer.position.y);
            }
        
        if ( (lastRuffMovementPosition.x  < 0.35 * [[CCDirector sharedDirector] screenSize].width - _foregroundLayer.position.x ) && _ruffSprite.flipX)
            {
                if ( 0 <= _foregroundLayer.position.x )
                {
                    if ( lastRuffMovementPosition.x <= 0)
                    {
                        lastRuffMovementPosition.x = 0;
                    }
                }
                else
                {
                    _foregroundLayer.position = ccp( _foregroundLayer.position.x + (RUFF_SPEED * delta), _foregroundLayer.position.y);
                    lastRuffMovementPosition.x = 0.35 * [[CCDirector sharedDirector] screenSize].width - _foregroundLayer.position.x ;
                }
            }
        else if (lastRuffMovementPosition.x + ruffContentWidth > 0.65 * [[CCDirector sharedDirector] screenSize].width - _foregroundLayer.position.x  && !_ruffSprite.flipX)
            {
                if ( _foregroundLayer.position.x + _levelWidth <=  [[CCDirector sharedDirector] screenSize].width )
                {
                    if ( lastRuffMovementPosition.x + _ruffSprite.contentSize.width >= _levelWidth )
                    {
                        lastRuffMovementPosition.x = _levelWidth - _ruffSprite.contentSize.width;
                    }
                }
                else
                {
                    _foregroundLayer.position = ccp( _foregroundLayer.position.x - (RUFF_SPEED * delta), _foregroundLayer.position.y);
                    lastRuffMovementPosition.x = 0.65 * [[CCDirector sharedDirector] screenSize].width - ruffContentWidth - _foregroundLayer.position.x ;
                }
            }
        
        
            
        _isMoving = NO;
        
        }

    if ([ _ruffSprite pixelMaskIntersectsNode: _platform3])
        {
            CCLOG(@"blue platform");
        }

//    float testY = [self getRuffsBaseY];
    
    if ( [self didRuffCollideWithAPlatform:lastRuffMovementPosition] )
        {
//        CCLOG(@"green platform");
        }
    else if (_ruffBaseY != _defaultGround )
        {

            _ruffBaseY = _defaultGround;
        
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
    
    if ( lastRuffMovementPosition.y + _ruffSprite.contentSize.height > 0.85 * [[CCDirector sharedDirector] screenSize].height - _foregroundLayer.position.y && _changeOfY > 0)
    {
        _foregroundLayer.position = ccp( (int)_foregroundLayer.position.x, (int)(_foregroundLayer.position.y - _changeOfY) );
    }
    
    else if ( lastRuffMovementPosition.y  <= 205 - _foregroundLayer.position.y && _changeOfY < 0)
    {
        _foregroundLayer.position = ccp( (int)_foregroundLayer.position.x, (int)(_foregroundLayer.position.y - _changeOfY) );
        _changeOfY = 0;
        if ( lastRuffMovementPosition.y >= 205- _foregroundLayer.position.y)
            {
                _foregroundLayer.position = ccp( (int)_foregroundLayer.position.x, (int)(205- lastRuffMovementPosition.y) );
            }
    }
    else if ( lastRuffMovementPosition.y  > 205 - _foregroundLayer.position.y && !_isJumping)
        {
        
        _foregroundLayer.position = ccp( (int)_foregroundLayer.position.x, (int)(_foregroundLayer.position.y - 7) );

        if ( lastRuffMovementPosition.y <= 205- _foregroundLayer.position.y)
            {
            _foregroundLayer.position = ccp( (int)_foregroundLayer.position.x, (int)(205- lastRuffMovementPosition.y ));
            }
        }
    
    
    

    
    
    
    //if ( _ruffBaseY )
    
	//lastRuffMovementPosition = [self keepRuffBetweenScreenBorders: lastRuffMovementPosition];
    

    lastRuffMovementPosition.x = [ self didRuffCollideWithAWall: lastRuffMovementPosition.x];

    _ruffSprite.position = ccp((int)lastRuffMovementPosition.x, (int)lastRuffMovementPosition.y);

    // updates all level layers positions with the background layers position
    [self updateLevelLayerPositions];
    
    _ruffSprite.previousPosition = _ruffSprite.position;
    
    _lastJumpTime = _gameTime;

}












-(void) increaseAssetLoadCount
{
    _assetLoadCount++;
    _loadingAsset = NO;
}

-(void) loadAssetsThenGotoMainMenu:(ccTime)delta
{
    NSLog(@"load assets %i", _assetLoadCount);
    switch (_assetLoadCount)
    {
        case 0:
        if (_loadingAsset == NO)
            {
            _loadingAsset = YES;
            NSLog(@"============= Loading home.png ===============");
            [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];
            [[CCTextureCache sharedTextureCache] addImageAsync:@"home.png"
                                                        target:self
                                                      selector:@selector(increaseAssetLoadCount)];
            }
        break;
        case 1:
        if (_loadingAsset == NO)
            {
            _loadingAsset = YES;
            [self performSelectorInBackground:@selector(loadSpriteFrames:) withObject:nil];
            }
        break;
        
        // extend with more sequentially numbered cases, as needed
        
        // the default case runs last, loads the next scene
        default:
        {
        [self unscheduleAllSelectors];
        //CTitleScreen* mainMenuScene = [MainMenuScene node];
        //[[CCDirector sharedDirector] replaceScene:mainMenuScene];
        }
        break;
    }
}


@end