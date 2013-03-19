/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKPixelMaskSprite.h"


@interface KKMutablePixelMaskSprite : KKPixelMaskSprite

    #if KK_PIXELMASKSPRITE_USE_BITARRAY
    @property (nonatomic) bit_array_t* pixelMask;
    #else
    @property (nonatomic) BOOL* pixelMask;
    #endif

    @property (nonatomic) NSUInteger pixelMaskWidth;
    @property (nonatomic) NSUInteger pixelMaskHeight;
    @property (nonatomic) NSUInteger pixelMaskSize;

@end
