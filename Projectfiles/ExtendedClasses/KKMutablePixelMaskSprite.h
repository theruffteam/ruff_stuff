/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKPixelMaskSprite.h"
#import "CCSpriteFrameExtended.h"

@interface KKMutablePixelMaskSprite : KKPixelMaskSprite

-(void) updatePixelMaskWithSpriteFrame: (CCSpriteFrameExtended*) spriteFrame;
-(CCSpriteFrameExtended*) createPixelMaskWithCurrentFrame;
@end
