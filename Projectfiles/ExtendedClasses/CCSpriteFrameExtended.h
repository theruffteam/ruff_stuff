/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "CCSpriteFrameExtended.h"

@interface CCSpriteFrameExtended : CCSpriteFrame

#if KK_PIXELMASKSPRITE_USE_BITARRAY
@property bit_array_t* pixelMask;
#else
// holds BOOL* pixelMasks for:
// x, flip x, y, flip y, flip x flip y
@property (nonatomic, strong) NSDictionary* dictionaryOfPixelMasks;
#endif

@property NSUInteger pixelMaskWidth;
@property NSUInteger pixelMaskHeight;
@property NSUInteger pixelMaskSize;

@end
