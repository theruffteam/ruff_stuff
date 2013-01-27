// =============================================================================
// File      : CResourceManagement.h
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the header file for the "CResourceManagement" class.
// =============================================================================

#import <Foundation/Foundation.h>
#import "kobold2d.h"

@interface CResourceManagement : CCNode
{
    @private
    NSMutableDictionary*    _resources;
}

- (id)      initFromResourcesFile: (NSString*)resourcesPList;

@end
