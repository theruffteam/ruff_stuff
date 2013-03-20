/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKMutablePixelMaskSprite.h"

// caching the class for faster access
//static Class PixelMaskSpriteClass = nil;

@interface KKPixelMaskSprite ()

#if KK_PIXELMASKSPRITE_USE_BITARRAY
@property (readwrite, copy) bit_array_t* pixelMask;
#else
@property (nonatomic, readwrite) BOOL* pixelMask;
#endif

@property (nonatomic, readwrite) NSUInteger pixelMaskWidth;
@property (nonatomic, readwrite) NSUInteger pixelMaskHeight;
@property (nonatomic, readwrite) NSUInteger pixelMaskSize;
@end



@implementation KKMutablePixelMaskSprite


-(void) updatePixelMask
{
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
    
    // get all the image information we need
    pixelMaskWidth = image.size.width;
    pixelMaskHeight = image.size.height;
    pixelMaskSize = pixelMaskWidth * pixelMaskHeight;
    
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
    pixelMask = malloc(pixelMaskSize * sizeof(BOOL));
    memset(pixelMask, 0, pixelMaskSize * sizeof(BOOL));
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
    UInt32 alphaValue = 0, x = 0, y = (UInt32)(pixelMaskHeight - 1);
    UInt8 alpha = 0;
    
    for (NSUInteger i = 0; i < pixelMaskSize; i++)
    {
        // ensure that the pixelMask is created in the normal orientation (default would be upside down)
        NSUInteger index = y * pixelMaskWidth + x;
        x++;
        if (x == pixelMaskWidth)
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
                pixelMask[index] = YES;
#endif
            }
        }
    }
    
    CFRelease(imageData);
    imageData = nil;
    //[image release];
    image = nil;
    
}

@end
