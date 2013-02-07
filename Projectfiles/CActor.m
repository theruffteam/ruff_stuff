// =============================================================================
// File      : CActor.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the implementation file for the "CActor" class.
// =============================================================================

#import "CActor.h"

@interface CActor (PrivateMethods)
- (void) CActorPrivateMethod;
@end

@implementation CActor

- (id) initWithPropertyList: (NSString*) actorPList
{
    if (self = [super init])
        {
        // initialize stuff here
        }
    
    return self;
}


- (BOOL) attack: (NSString*) nameOfAttack
{
  
    return false;
    
}


- (BOOL) jump: (CGPoint) direction;
{
    
    return false;
}


- (BOOL) move: (CGPoint) position withDirection: (CGPoint) direction withGravity: (float) gravity;
{
    
    return false;
}


- (void) CActorPrivateMethod;
{
    
}
@end
