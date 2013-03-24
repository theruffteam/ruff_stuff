/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKMutablePixelMaskSprite.h"


@implementation KKMutablePixelMaskSprite

// caching the class for faster access
static Class PixelMaskSpriteClass = nil;

-(void) updatePixelMaskWithSpriteFrame: (CCSpriteFrameExtended*) spriteFrame
{
    pixelMaskHeight = spriteFrame.pixelMaskHeight;
    pixelMaskWidth = spriteFrame.pixelMaskWidth;
    pixelMaskSize = spriteFrame.pixelMaskSize;
    pixelMask = spriteFrame.pixelMask;
    
    //free(pixelMask);
    
    //pixelMask = malloc(spriteFrame.pixelMaskSize * sizeof(BOOL));
    
    //memset(spriteFrame.pixelMask, 0, spriteFrame.pixelMaskSize * sizeof(BOOL));
    
    //memmove(pixelMask, spriteFrame.pixelMask, spriteFrame.pixelMaskSize * sizeof(BOOL));
}


-(CCSpriteFrameExtended*) createPixelMaskWithCurrentFrame
{
    if (PixelMaskSpriteClass == nil)
        {
        PixelMaskSpriteClass = [KKPixelMaskSprite class];
        }
    CCSpriteFrame* spriteFrame = [self displayFrame];
    
    CCSpriteFrameExtended* extendedSpriteFrameWithPixelMask = [[CCSpriteFrameExtended alloc] initWithTexture:spriteFrame.texture rect:spriteFrame.rect];
    
    
    
    
    //extendedSpriteFrameWithPixelMask = [self displayFrame];
    
    UInt8 alphaThreshold = 0;
    
    int tx = _contentSize.width;
    int ty = _contentSize.height;
    
    
    CCRenderTexture* renderer = [CCRenderTexture renderTextureWithWidth:tx height:ty];
    
    _anchorPoint = CGPointZero;
    
    [renderer begin];
    [self draw];
    [renderer end];
    
#if KK_PLATFORM_IOS
    UIImage* image = [renderer getUIImage];
#elif KK_PLATFORM_MAC
    NSImage* image = [[NSImage alloc] init];
#endif
    
    //[extendedSpriteFrameWithPixelMask setPixelMaskWidth: spriteFrame.originalSizeInPixels.width];
    // get all the image information we need
    extendedSpriteFrameWithPixelMask.pixelMaskWidth = spriteFrame.originalSizeInPixels.width;//image.size.width * (float)CC_CONTENT_SCALE_FACTOR();
    extendedSpriteFrameWithPixelMask.pixelMaskHeight = spriteFrame.originalSizeInPixels.height;//image.size.height * (float)CC_CONTENT_SCALE_FACTOR();
    extendedSpriteFrameWithPixelMask.pixelMaskSize = extendedSpriteFrameWithPixelMask.pixelMaskWidth * extendedSpriteFrameWithPixelMask.pixelMaskHeight;
    
#if defined(__arm__) && !defined(__ARM_NEON__)
    NSAssert3(isPowerOfTwo(pixelMaskWidth) && isPowerOfTwo(pixelMaskHeight),
              @"Image '%@' size (%u, %u): pixel mask image must have power of two dimensions on 1st & 2nd gen devices.",
              filename, pixelMaskWidth, pixelMaskHeight);
#endif
    
    // allocate and clear the pixelMask buffer
#if KK_PIXELMASKSPRITE_USE_BITARRAY
    pixelMask = BitArrayCreate(pixelMaskSize);
    BitArrayClearAll(pixelMask);
#else
    extendedSpriteFrameWithPixelMask.pixelMask = malloc(extendedSpriteFrameWithPixelMask.pixelMaskSize * sizeof(BOOL));
    memset(extendedSpriteFrameWithPixelMask.pixelMask, 0, extendedSpriteFrameWithPixelMask.pixelMaskSize * sizeof(BOOL));
#endif
    
    // get the pixel data (more correctly: texels) as 32-Bit unsigned integers
#if KK_PLATFORM_IOS
    CGImageRef cgImage = image.CGImage;
#elif KK_PLATFORM_MAC
    CGImageRef cgImage = [image CGImageForProposedRect:NULL
                                               context:[NSGraphicsContext currentContext]
                                                 hints:[NSDictionary dictionary]];
#endif
    CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    const UInt32* imagePixels = (const UInt32*)CFDataGetBytePtr(imageData);
    UInt32 alphaValue = 0, x = 0, y = (UInt32)(extendedSpriteFrameWithPixelMask.pixelMaskHeight - 1);
    UInt8 alpha = 0;
    
    for (NSUInteger i = 0; i < extendedSpriteFrameWithPixelMask.pixelMaskSize; i++)
        {
        // ensure that the pixelMask is created in the normal orientation (default would be upside down)
        NSUInteger index = y * extendedSpriteFrameWithPixelMask.pixelMaskWidth + x;
        x++;
        if (x == extendedSpriteFrameWithPixelMask.pixelMaskWidth)
            {
            x = 0;
            y--;
            }
        
        // mask out the colors so that only the alpha value remains (upper 8 bits)
        alphaValue = imagePixels[i] & 0xff000000;
        if (alphaValue > 0)
            {
            // get the 8-Bit alpha value, then compare it with the alpha threshold
            alpha = (UInt8)(alphaValue >> 24);
            if (alpha >= alphaThreshold)
                {
#if KK_PIXELMASKSPRITE_USE_BITARRAY
                BitArraySetBit(pixelMask, index);
#else
                extendedSpriteFrameWithPixelMask.pixelMask[index] = YES;
#endif
                }
            }
        }
    
    CFRelease(imageData);
    imageData = nil;
    //[image release];
    image = nil;
    
    _frame = extendedSpriteFrameWithPixelMask;
    
    return (CCSpriteFrameExtended*)extendedSpriteFrameWithPixelMask;
}

//-(void)setDisplayFrame:(CCSpriteFrameExtended *)newFrame
//{
//    pixelMaskHeight = newFrame.pixelMaskHeight;
//    pixelMaskWidth = newFrame.pixelMaskWidth;
//    pixelMaskSize = newFrame.pixelMaskSize;
//    pixelMask = newFrame.pixelMask;
//    
//    [(CCSprite*)self setDisplayFrame:newFrame];
//}

@end
