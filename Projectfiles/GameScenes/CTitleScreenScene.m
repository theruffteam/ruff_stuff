// =============================================================================
// File      : CTitleScreenScene.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/29/2013
// =============================================================================
// This is the implementation file for the "CTitleScreenScene" class.
// =============================================================================
#import "SimpleAudioEngine.h"
#import "CCVideoPlayer.h"
#import "CTitleScreenScene.h"


@interface CTitleScreenScene (PrivateMethods)
-(void) fadeInvillageBackground:(int) blank;
-(void) fadeInruffLeaningOnTreeForeground:(int) blank;
-(void) fadeInTitleAndMenuOptions: (int) blank;
-(void) addMainMenuLabelsToLayer:(id) sender;
-(void) changeInputType:(ccTime)delta;
-(void) postUpdateInputTests:(ccTime)delta;
-(void) startNewGame:(id) sender;
@end

@implementation CTitleScreenScene

-(id) init
{
	if ((self = [super init]))
        {
		CCLOG(@"%@ init", NSStringFromClass([self class]));
        
        // get the device's screen properties
		CCDirector* director = [CCDirector sharedDirector];
		CGPoint screenCenter = director.screenCenter;
        self.menuLayer = [[CCLayer alloc] init];
        
        
        /* create a world for Ruff
        /self.ruffWorld = [[CWorld alloc]
                          initLevelContentsFromFile:@"levels.plist"
                          actorContentsFromFile:@"actors.plis"
                          graphicContentsFromFile:@"graphics.plist"
                          audioContentsFromFile:@"audio.plist"
                          resourceContentsFromFile:@"resources.plist"];
*/
        // =====================================================================
        // Title Screen
        // =====================================================================
        
        // explicitly set the background color of the screen to black
		glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        
        self.menuLayer.touchEnabled = YES;
        
        [self addMainMenuLabelsToLayer: self];
        
        
		self.menuStaticRuff = [CCSprite spriteWithFile:@"RuffSide.png"];
		self.menuStaticRuff.position = CGPointMake(screenCenter.x + 150, screenCenter.y + 25);
        self.menuStaticRuff.scale = 0.80;
		[self.menuLayer addChild:self.menuStaticRuff];
        
        
        //CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCTextureCache* textureCache = [CCTextureCache sharedTextureCache];
        
        // Add the sprite frames. This will load the texture as well
        //[frameCache addSpriteFramesWithFile:@"monkey.plist"];
        //[frameCache addSpriteFramesWithFile:@"player.plist"];
        //[frameCache addSpriteFramesWithFile:@"enemy.plist"];
        
        // Load other textures that are going to be used
        //CCTexture2D* _myBackgroundTexture = [textureCache addImage:@"Login.png"];
        
        //cache images in memory : warning - limited amount of cache size
        [textureCache addImageAsync:@"title_screen_bg_01.png" target:self selector:@selector(self)];
        
        [textureCache addImageAsync:@"title_screen_bg_02.png" target:self selector:@selector(self)];
        
        
        
        self.villageBackground = [CCSprite spriteWithFile:@"title_screen_bg_01.png"];
        [self.villageBackground setPosition:ccp(screenCenter.x, screenCenter.y)];
        self.villageBackground.opacity = 0.0f;
        [self addChild:self.villageBackground z: -2];
        
        self.ruffLeaningOnTreeForeground = [CCSprite spriteWithFile:@"title_screen_bg_02.png"];
        [self.ruffLeaningOnTreeForeground setPosition:ccp(screenCenter.x, screenCenter.y)];
        self.ruffLeaningOnTreeForeground.opacity = 0.0f;
        [self addChild:self.ruffLeaningOnTreeForeground z: -1];
        
        
		[self scheduleUpdate];
		//[self schedule:@selector(changeInputType:) interval:8.0f];
		//[self schedule:@selector(postUpdateInputTests:)];
        [self scheduleOnce:@selector(fadeInvillageBackground:) delay:0.5f];
        
        //HelloWorldLayer *hw = [HelloWorldLayer node]; // This is how we create the handle.
        //[hw Testing]; // This is how we call any method inside.
        
        //[[CCDirector sharedDirector]replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:hw]];
		
        
		// initialize KKInput
//		KKInput* input = [KKInput sharedInput];
//		//input.accelerometerActive = input.accelerometerAvailable;
//		//input.gyroActive = input.gyroAvailable;
//		input.multipleTouchEnabled = YES;
//		input.gestureTapEnabled = input.gesturesAvailable;
//		input.gestureDoubleTapEnabled = input.gesturesAvailable;
//		input.gestureSwipeEnabled = input.gesturesAvailable;
//		input.gestureLongPressEnabled = input.gesturesAvailable;
//		//input.gesturePanEnabled = input.gesturesAvailable;
//		//input.gestureRotationEnabled = input.gesturesAvailable;
//		input.gesturePinchEnabled = input.gesturesAvailable;
        
        // play bgmusic
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"intro_256.caf" loop:YES];
        
        //[self.ruffWorld.audioManager playBackgroundMusic:@"intro_256.caf" withVolumeAt:0.0f isBackgroundMusicOn:NO];

        //preload sound effect for selecting items on the menu
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.07f];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"select_item.wav"];
        }
    
	return self;
}

-(void) fadeInvillageBackground: (int) blank
{
    [self.villageBackground runAction: [CCFadeTo actionWithDuration:4.0f opacity:123]];
    
    [self scheduleOnce:@selector(fadeInruffLeaningOnTreeForeground:) delay:5.95f];
}

-(void) fadeInruffLeaningOnTreeForeground: (int) blank
{
    [self.ruffLeaningOnTreeForeground runAction: [CCFadeTo actionWithDuration:3.45f opacity:255]];
    
    [self scheduleOnce:@selector(fadeInTitleAndMenuOptions:) delay:5.15f];
}

-(void) fadeInTitleAndMenuOptions: (int) blank
{
    [self addChild: self.menuLayer];
}


-(void) addMainMenuLabelsToLayer: (id) sender
{
    
	CCDirector* director = [CCDirector sharedDirector];
	CGPoint screenCenter = director.screenCenter;
    
    
	CCLabelTTF* gameTitle = [CCLabelTTF labelWithString:@"Ruff" fontName:@"Verdana" fontSize:80];
	gameTitle.position = CGPointMake(screenCenter.x, screenCenter.y + 100);
	gameTitle.color = ccBLACK;
	[self.menuLayer addChild:gameTitle];
    
   	CCLabelTTF* newGame = [CCLabelTTF labelWithString:@"New Game" fontName:@"Verdana" fontSize:20];
	//newGame.position = CGPointMake(screenCenter.x, screenCenter.y);
	newGame.color = ccBLACK;
	//[layer addChild:newGame];
    
    CCLabelTTF* options = [CCLabelTTF labelWithString:@"Options" fontName:@"Verdana" fontSize:20];
	//options.position = CGPointMake(screenCenter.x, screenCenter.y - 30);
	options.color = ccBLACK;
	//[layer addChild:options];
    
    CCMenuItemLabel* newGameTouch = [CCMenuItemLabel itemWithLabel:newGame target:sender selector:@selector(startNewGame:)];
    CCMenuItemLabel* optionsTouch = [CCMenuItemLabel itemWithLabel:options target:sender selector:@selector(startNewGame:)];
    
    self.menu = [CCMenu menuWithItems: newGameTouch, optionsTouch, nil];
    
    [self.menu alignItemsVertically];

    [self.menuLayer addChild: self.menu];
}

-(void) startNewGame: (id) sender
{
    // play preloaded sound effect
    [[SimpleAudioEngine sharedEngine] playEffect:@"select_item.wav"];

    [CCVideoPlayer playMovieWithFile:@"young_ruff_dash_attack.mp4"];
    
    CCLOG(@"start new game");
}



-(void) movemenuStaticRuffByPollingKeyboard
{
	const float kmenuStaticRuffSpeed = 3.0f;
    
	KKInput* input = [KKInput sharedInput];
	CGPoint menuStaticRuffPosition = self.menuStaticRuff.position;
	
	if ([input isKeyDown:KKKeyCode_UpArrow] ||
		[input isKeyDown:KKKeyCode_W])
        {
		menuStaticRuffPosition.y += kmenuStaticRuffSpeed;
        }
	if ([input isKeyDown:KKKeyCode_LeftArrow] ||
		[input isKeyDown:KKKeyCode_A])
        {
		menuStaticRuffPosition.x -= kmenuStaticRuffSpeed;
        }
	if ([input isKeyDown:KKKeyCode_DownArrow] ||
		[input isKeyDown:KKKeyCode_S])
        {
		menuStaticRuffPosition.y -= kmenuStaticRuffSpeed;
        }
	if ([input isKeyDown:KKKeyCode_RightArrow] ||
		[input isKeyDown:KKKeyCode_D])
        {
		menuStaticRuffPosition.x += kmenuStaticRuffSpeed;
        }
    
	if (([input isKeyDown:KKKeyCode_Command] ||
		 [input isKeyDown:KKKeyCode_Control]))
        {
		menuStaticRuffPosition = [input mouseLocation];
        }
    
	self.menuStaticRuff.position = menuStaticRuffPosition;
    
	if ([input isKeyDown:KKKeyCode_Slash])
        {
		self.menuStaticRuff.scale += 0.03f;
        }
	else if ([input isKeyDown:KKKeyCode_Semicolon])
        {
		self.menuStaticRuff.scale -= 0.03f;
        }
	
	if ([input isKeyDownThisFrame:KKKeyCode_Quote])
        {
		self.menuStaticRuff.scale = 1.0f;
        }
}

-(void) changeInputType:(ccTime)delta
{
	KKInput* input = [KKInput sharedInput];
    
	self.inputType++;
	if ((self.inputType == kInputTypes_End) || (self.inputType == kGyroscopeRotationRate && input.gyroAvailable == NO))
        {
		self.inputType = 0;
        }
	
	NSString* labelString = nil;
	switch (self.inputType)
	{
		case kAccelerometerValuesRaw:
        // reset back to non-deviceMotion input
        input.accelerometerActive = input.accelerometerAvailable;
        input.gyroActive = input.gyroAvailable;
        labelString = @"Using RAW accelerometer values";
        break;
		case kAccelerometerValuesSmoothed:
        labelString = @"Using SMOOTHED accelerometer values";
        break;
		case kAccelerometerValuesInstantaneous:
        labelString = @"Using INSTANTANEOUS accelerometer values";
        break;
		case kGyroscopeRotationRate:
        labelString = @"Using GYROSCOPE rotation values";
        break;
		case kDeviceMotion:
        // use deviceMotion input for this test
        input.deviceMotionActive = input.deviceMotionAvailable;
        labelString = @"Using DEVICE MOTION values";
        break;
        
		default:
        break;
	}
	
	CCLabelTTF* label = (CCLabelTTF*)[self getChildByTag:2];
	[label setString:labelString];
}

-(void) movemenuStaticRuffWithMotionSensors
{
	const float kmenuStaticRuffSpeed = 25.0f;
	
	KKInput* input = [KKInput sharedInput];
	CGPoint menuStaticRuffPosition = self.menuStaticRuff.position;
	
	switch (self.inputType)
	{
		case kAccelerometerValuesRaw:
        menuStaticRuffPosition.x += input.acceleration.rawX * kmenuStaticRuffSpeed;
        menuStaticRuffPosition.y += input.acceleration.rawY * kmenuStaticRuffSpeed;
        break;
		case kAccelerometerValuesSmoothed:
        menuStaticRuffPosition.x += input.acceleration.smoothedX * kmenuStaticRuffSpeed;
        menuStaticRuffPosition.y += input.acceleration.smoothedY * kmenuStaticRuffSpeed;
        break;
		case kAccelerometerValuesInstantaneous:
        menuStaticRuffPosition.x += input.acceleration.instantaneousX * kmenuStaticRuffSpeed;
        menuStaticRuffPosition.y += input.acceleration.instantaneousY * kmenuStaticRuffSpeed;
        break;
		case kGyroscopeRotationRate:
        menuStaticRuffPosition.x += input.rotationRate.x * kmenuStaticRuffSpeed;
        menuStaticRuffPosition.y += input.rotationRate.y * kmenuStaticRuffSpeed;
        break;
		case kDeviceMotion:
        menuStaticRuffPosition.x += input.deviceMotion.pitch * kmenuStaticRuffSpeed;
        menuStaticRuffPosition.y += input.deviceMotion.roll * kmenuStaticRuffSpeed;
        break;
        
		default:
        break;
	}
    
	self.menuStaticRuff.position = menuStaticRuffPosition;
}

-(void) moveParticleFXToTouch
{
	KKInput* input = [KKInput sharedInput];
	
	if (input.touchesAvailable)
        {
		self.particleFX.position = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
        }
}

-(void) detectSpriteTouched
{
	KKInput* input = [KKInput sharedInput];
    
	CCSprite* touchSprite = (CCSprite*)[self getChildByTag:99];
	if ([input isAnyTouchOnNode:touchSprite touchPhase:KKTouchPhaseAny])
        {
		touchSprite.color = ccGREEN;
        }
	else
        {
		touchSprite.color = ccWHITE;
        }
}

-(void) createSmallExplosionAt:(CGPoint)location
{
	CCParticleExplosion* explosion = [[CCParticleExplosion alloc] initWithTotalParticles:50];
#ifndef KK_ARC_ENABLED
	[explosion autorelease];
#endif
	explosion.autoRemoveOnFinish = YES;
	explosion.blendAdditive = YES;
	explosion.position = location;
	explosion.speed *= 4;
	[self addChild:explosion];
}

-(void) createLargeExplosionAt:(CGPoint)location
{
	CCParticleExplosion* explosion = [[CCParticleExplosion alloc] initWithTotalParticles:100];
#ifndef KK_ARC_ENABLED
	[explosion autorelease];
#endif
	explosion.autoRemoveOnFinish = YES;
	explosion.blendAdditive = NO;
	explosion.position = location;
	explosion.speed *= 8;
	[self addChild:explosion];
}

-(void) gestureRecognition
{
	KKInput* input = [KKInput sharedInput];
	if (input.gestureTapRecognizedThisFrame)
        {
		[self createSmallExplosionAt:input.gestureTapLocation];
        }
	
	if (input.gestureDoubleTapRecognizedThisFrame)
        {
		[self createLargeExplosionAt:input.gestureDoubleTapLocation];
        }
	/* disable the little menuStaticRuffs that are created
     if (input.gestureSwipeRecognizedThisFrame)
     {
     CCSprite* swipeSprite = [CCSprite spriteWithFile:@"menuStaticRuff.png"];
     swipeSprite.position = input.gestureSwipeLocation;
     swipeSprite.scale = 0.5f;
     [self addChild:swipeSprite];
     
     // move faster the faster start and end point are apart
     CGPoint swipeEndPoint = [input locationOfAnyTouchInPhase:KKTouchPhaseCancelled];
     float kMoveDistance = fabsf(ccpLength(ccpSub(swipeEndPoint, input.gestureSwipeLocation))) * 4;
     CGPoint moveDirection = CGPointZero;
     
     switch (input.gestureSwipeDirection)
     {
     case KKSwipeGestureDirectionLeft:
     moveDirection.x = -kMoveDistance;
     break;
     case KKSwipeGestureDirectionRight:
     moveDirection.x = kMoveDistance;
     break;
     case KKSwipeGestureDirectionUp:
     moveDirection.y = kMoveDistance;
     break;
     case KKSwipeGestureDirectionDown:
     moveDirection.y = -kMoveDistance;
     break;
     }
     
     id move = [CCMoveBy actionWithDuration:10 position:moveDirection];
     id remove = [CCRemoveFromParentAction action];
     id sequence = [CCSequence actions: move, remove, nil];
     [swipeSprite runAction:sequence];
     }
     
     // drag & drop menuStaticRuff initiated by long-press gesture
     menuStaticRuff.color = ccWHITE;
     menuStaticRuff.scale = 0.80f;
     */
	if (input.gestureLongPressBegan)
        {
		self.menuStaticRuff.position = input.gestureLongPressLocation;
		//menuStaticRuff.color = ccGREEN;
		//menuStaticRuff.scale = 0.80f;
        }
	
	if (input.gesturePanBegan)
        {
		CCLOG(@"translation: %.0f, %.0f, velocity: %.1f, %.1f", input.gesturePanTranslation.x, input.gesturePanTranslation.y, input.gesturePanVelocity.x, input.gesturePanVelocity.y);
		self.menuStaticRuff.position = input.gesturePanLocation;
		
		// center particle on position where pan started, then move it according to velocity in the direction the menuStaticRuff was dragged
		self.particleFX.position = ccpSub(input.gesturePanLocation, input.gesturePanTranslation);
		self.particleFX.position = ccpAdd(self.particleFX.position, ccpMult(input.gesturePanVelocity, 5));
        }
	
	if (input.gestureRotationBegan)
        {
		self.menuStaticRuff.position = input.gestureRotationLocation;
		self.menuStaticRuff.rotation = input.gestureRotationAngle;
		self.menuStaticRuff.scale = fminf(fabsf(input.gestureRotationVelocity) + 1.0f, 3.0f);
        }
	
	self.scale = 1.0f;
	self.particleFX.scale = 1.0f;
	if (input.gesturePinchBegan)
        {
		self.scale = input.gesturePinchScale;
		self.particleFX.scale = fminf(fabsf(input.gesturePinchVelocity) * 100.0f + 1.0f, 5.0f);
        }
}

-(void) detectMouseOverTouchSprite
{
	KKInput* input = [KKInput sharedInput];
	
	CCSprite* touchSprite = (CCSprite*)[self getChildByTag:99];
	if ([touchSprite containsPoint:input.mouseLocation])
        {
		touchSprite.color = ccGREEN;
        }
	else
        {
		touchSprite.color = ccWHITE;
        }
}

-(void) wrapmenuStaticRuffAtScreenBorders
{
	CCDirector* director = [CCDirector sharedDirector];
	CGSize screenSize = director.screenSize;
	
	CGPoint menuStaticRuffPosition = self.menuStaticRuff.position;
    
	if (menuStaticRuffPosition.x < 0)
        {
		menuStaticRuffPosition.x += screenSize.width;
        }
	else if (menuStaticRuffPosition.x >= screenSize.width)
        {
		menuStaticRuffPosition.x -= screenSize.width;
        }
	
	if (menuStaticRuffPosition.y < 0)
        {
		menuStaticRuffPosition.y += screenSize.height;
        }
	else if (menuStaticRuffPosition.y >= screenSize.height)
        {
		menuStaticRuffPosition.y -= screenSize.height;
        }
	
	self.menuStaticRuff.position = menuStaticRuffPosition;
	//LOG_EXPR(menuStaticRuff.texture);
	//LOG_EXPR([menuStaticRuff boundingBox]);
}

-(void) rotatemenuStaticRuffWithMouseButtons
{
	KKInput* input = [KKInput sharedInput];
    
	if ([input isMouseButtonDown:KKMouseButtonLeft])
        {
		self.menuStaticRuff.rotation -= 2;
        }
	if ([input isMouseButtonDown:KKMouseButtonRight])
        {
		self.menuStaticRuff.rotation += 2;
        }
    
	if ([input isMouseButtonDown:KKMouseButtonLeft modifierFlags:KKModifierCommandKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonLeft modifierFlags:KKModifierControlKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonLeft modifierFlags:KKModifierShiftKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonLeft modifierFlags:KKModifierAlternateKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonLeft modifierFlags:KKModifierAlphaShiftKeyMask])
        {
		self.menuStaticRuff.rotation -= 10;
        }
	if ([input isMouseButtonDown:KKMouseButtonRight modifierFlags:KKModifierCommandKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonRight modifierFlags:KKModifierControlKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonRight modifierFlags:KKModifierShiftKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonRight modifierFlags:KKModifierAlternateKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonRight modifierFlags:KKModifierAlphaShiftKeyMask])
        {
		self.menuStaticRuff.rotation += 10;
        }
	
	if ([input isMouseButtonDownThisFrame:KKMouseButtonDoubleClickLeft])
        {
		[self createSmallExplosionAt:input.mouseLocation];
        }
	if ([input isMouseButtonDownThisFrame:KKMouseButtonDoubleClickRight])
        {
		[self createLargeExplosionAt:input.mouseLocation];
        }
	
	self.menuStaticRuff.scale += (float)[input scrollWheelDelta].y * 0.1f;
}

-(void) particleFXFollowsMouse
{
	KKInput* input = [KKInput sharedInput];
	
	self.particleFX.position = [input mouseLocation];
	self.particleFX.gravity = ccpMult([input mouseLocationDelta], 50.0f);
}

-(void) update:(ccTime)delta
{
//	KKInput* input = [KKInput sharedInput];
//	if ([input isAnyTouchOnNode:self touchPhase:KKTouchPhaseAny])
//        {
//		CCLOG(@"Touch: beg=%d mov=%d sta=%d end=%d can=%d",
//			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseBegan],
//			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseMoved],
//			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseStationary],
//			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseEnded],
//			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseCancelled]);
//        }
//	
//	CCDirector* director = [CCDirector sharedDirector];
//	
//	if (director.currentPlatformIsIOS)
//        {
//		//[self movemenuStaticRuffWithMotionSensors];
//		[self moveParticleFXToTouch];
//		[self detectSpriteTouched];
//		[self gestureRecognition];
//		
//		if ([KKInput sharedInput].anyTouchEndedThisFrame)
//            {
//			CCLOG(@"anyTouchEndedThisFrame");
//            }
//        }
//	else
//        {
//		[self movemenuStaticRuffByPollingKeyboard];
//		[self rotatemenuStaticRuffWithMouseButtons];
//		[self particleFXFollowsMouse];
//		[self detectMouseOverTouchSprite];
//        }
//	
//	[self wrapmenuStaticRuffAtScreenBorders];
}

-(void) postUpdateInputTests:(ccTime)delta
{
	KKInput* input = [KKInput sharedInput];
	if ([input anyTouchEndedThisFrame] || [input isAnyKeyUpThisFrame])
        {
		//CCLOG(@"touch ended / key up this frame");
        }
}

-(void) draw
{
/*
    CCDirector* director = [CCDirector sharedDirector];

    // left circle on screen
    ccDrawCircle(CGPointMake(100.0f , 100.0f), 100, 0, 16, NO);
    
    // right circle on screen
    ccDrawCircle(CGPointMake(director.screenSize.width - 100.0f , 100.0f), 100, 0, 16, NO);
*/
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