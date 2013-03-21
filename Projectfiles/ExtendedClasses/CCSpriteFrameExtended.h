/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "CCSpriteFrame.h"


@interface CCSpriteFrameExtended : CCSpriteFrame

    #if KK_PIXELMASKSPRITE_USE_BITARRAY
    @property (readwrite, copy) bit_array_t* pixelMask;
    #else
    @property (nonatomic, readwrite) BOOL* pixelMask;
    #endif

    @property (nonatomic, readwrite) NSUInteger pixelMaskWidth;
    @property (nonatomic, readwrite) NSUInteger pixelMaskHeight;
    @property (nonatomic, readwrite) NSUInteger pixelMaskSize;
@end

-(void) updatePixelMaskOfKKMutablePixelMaskSprite: (KKMutablePixelMaskSprite*) spriteFrame

@end