// =============================================================================
// File      : CGraphicManagement.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the implementation file for the "CGraphicManagement" class.
// =============================================================================

#import "CGraphicManagement.h"


@implementation CGraphicManagement


- (id)      initFromGraphicsFile: (NSString*)graphicsPList
{
    self = [super init];
    
    if (self)
        {
        _graphics = [[NSMutableDictionary alloc] init];
        }
    
    return self;
}
@end
