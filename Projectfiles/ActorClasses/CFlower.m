// =============================================================================
// File      : CYoungRuff.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the implementation file for the "CActor" class.
// =============================================================================

#import "CFlower.h"


@interface CFlower (PrivateMethods)
-(void) testFunction;
@end

@implementation CFlower

- (id) initFlower
{
    if (self = [super init])
        {
        
        }
    
    return self;
}





- (void) testFunction
{
    // called from CActor
}

@end
