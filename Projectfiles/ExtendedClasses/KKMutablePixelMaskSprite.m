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
    NSDictionary* dictionaryOfPixelMaskContents;
    
    // facing right
    if (! self.flipX)
        {
        dictionaryOfPixelMaskContents = [[NSDictionary alloc] initWithDictionary: [[spriteFrame dictionaryOfPixelMasks] valueForKey:@"pixelMaskX"]];
        }
    // facing left
    else
        {
        dictionaryOfPixelMaskContents = [[NSDictionary alloc] initWithDictionary: [[spriteFrame dictionaryOfPixelMasks] objectForKey:@"pixelMaskFlipX"]];
        }
    
    pixelMaskHeight = spriteFrame.pixelMaskHeight; //[[dictionaryOfPixelMaskContents valueForKey:@"pixelMaskHeight"] unsignedIntegerValue];
    pixelMaskWidth = spriteFrame.pixelMaskWidth; //[[dictionaryOfPixelMaskContents valueForKey:@"pixelMaskWidth"] unsignedIntegerValue];
    pixelMaskSize = spriteFrame.pixelMaskSize; //[[dictionaryOfPixelMaskContents valueForKey:@"pixelMaskSize"] unsignedIntegerValue];
    pixelMask = (BOOL*)[[dictionaryOfPixelMaskContents valueForKey:@"pixelMask"] bytes];
}


-(CCSpriteFrameExtended*) createPixelMaskWithCurrentFrame
{
    if (PixelMaskSpriteClass == nil)
        {
        PixelMaskSpriteClass = [KKPixelMaskSprite class];
        }
    
    CCSpriteFrame* spriteFrame = [self displayFrame];
    
    CCSpriteFrameExtended* extendedSpriteFrameWithPixelMask = [[CCSpriteFrameExtended alloc] initWithTexture:spriteFrame.texture rect:spriteFrame.rectInPixels];
        
    UInt8 alphaThreshold = 50;
    
    
    CCRenderTexture* renderer = [CCRenderTexture renderTextureWithWidth:[self boundingBox].size.width + 0.5f height:[self boundingBox].size.height + 0.5f];
    
    _anchorPoint = CGPointZero;
    
    [renderer beginWithClear:0 g:0 b:0 a:0];
    [self draw];
    [renderer end];
    
#if KK_PLATFORM_IOS
    UIImage* image = [renderer getUIImage];
#elif KK_PLATFORM_MAC
    NSImage* image = [[NSImage alloc] init];
#endif
    
    // get all the image information we need
    extendedSpriteFrameWithPixelMask.pixelMaskWidth = (NSUInteger)(CGImageGetWidth(image.CGImage) + 0.5f);// image.size.width * image.scale;//spriteFrame.originalSizeInPixels.width;//image.size.width * (float)CC_CONTENT_SCALE_FACTOR();
    extendedSpriteFrameWithPixelMask.pixelMaskHeight = (NSUInteger)(CGImageGetHeight(image.CGImage) + 0.5f);//image.size.height * image.scale;//spriteFrame.originalSizeInPixels.height;//image.size.height * (float)CC_CONTENT_SCALE_FACTOR();
    extendedSpriteFrameWithPixelMask.pixelMaskSize = extendedSpriteFrameWithPixelMask.pixelMaskWidth * extendedSpriteFrameWithPixelMask.pixelMaskHeight;
    
    NSUInteger pixelMaskBOOLSize = extendedSpriteFrameWithPixelMask.pixelMaskSize * sizeof(BOOL);
    
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
    BOOL* pixelMaskX = malloc(pixelMaskBOOLSize);
    BOOL* pixelMaskFlipX = malloc(pixelMaskBOOLSize);
    
    memset(pixelMaskX, 0, pixelMaskBOOLSize);
    memset(pixelMaskFlipX, 0, pixelMaskBOOLSize);
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
    
    UInt32 flipX = (UInt32)extendedSpriteFrameWithPixelMask.pixelMaskWidth;
    
    for (NSUInteger i = 0; i < extendedSpriteFrameWithPixelMask.pixelMaskSize; i++)
        {
        flipX--;
        
        // ensure that the pixelMask is created in the normal orientation (default would be upside down)
        NSUInteger index = y * extendedSpriteFrameWithPixelMask.pixelMaskWidth + x;
        NSUInteger indexFlipX = y * extendedSpriteFrameWithPixelMask.pixelMaskWidth + flipX;

        x++;
        if (x == extendedSpriteFrameWithPixelMask.pixelMaskWidth)
            {
            flipX = x;
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
                pixelMaskX[index] = YES;
                pixelMaskFlipX[indexFlipX] = YES;
#endif
                }
            }
        }
    
    CFRelease(imageData);
    imageData = nil;
    image = nil;
    
    
    NSMutableDictionary* dictionaryForPixelMaskX = [[NSMutableDictionary alloc] init];
    
//    [rightFacing setObject:[NSNumber numberWithUnsignedInteger:extendedSpriteFrameWithPixelMask.pixelMaskHeight] forKey:@"pixelMaskHeight"];
//    [rightFacing setObject:[NSNumber numberWithUnsignedInteger:extendedSpriteFrameWithPixelMask.pixelMaskWidth] forKey:@"pixelMaskWidth"];
//    [rightFacing setObject:[NSNumber numberWithUnsignedInteger:extendedSpriteFrameWithPixelMask.pixelMaskSize] forKey:@"pixelMaskSize"];
    [dictionaryForPixelMaskX setObject:[NSData dataWithBytes:pixelMaskX length:pixelMaskBOOLSize] forKey:@"pixelMask"];
    
    free(pixelMaskX);
    
    
    NSMutableDictionary* dictionaryForPixelMaskFlipX = [[NSMutableDictionary alloc] init];
    
//    [leftFacing setObject:[NSNumber numberWithUnsignedInteger:extendedSpriteFrameWithPixelMask.pixelMaskHeight] forKey:@"pixelMaskHeight"];
//    [leftFacing setObject:[NSNumber numberWithUnsignedInteger:extendedSpriteFrameWithPixelMask.pixelMaskWidth] forKey:@"pixelMaskWidth"];
//    [leftFacing setObject:[NSNumber numberWithUnsignedInteger:extendedSpriteFrameWithPixelMask.pixelMaskSize] forKey:@"pixelMaskSize"];
    [dictionaryForPixelMaskFlipX setObject:[NSData dataWithBytes:pixelMaskFlipX length:pixelMaskBOOLSize] forKey:@"pixelMask"];
    
    free(pixelMaskFlipX);
    
    
    extendedSpriteFrameWithPixelMask.dictionaryOfPixelMasks = [NSDictionary dictionaryWithObjectsAndKeys:dictionaryForPixelMaskX, @"pixelMaskX", dictionaryForPixelMaskFlipX, @"pixelMaskFlipX", nil];
    
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
