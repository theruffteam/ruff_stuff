// =============================================================================
// File      : CLevelManagement.h
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the header file for the "CLevelManagement" class.
// =============================================================================

#import <Foundation/Foundation.h>
#import "kobold2d.h"

@interface CLevelManagement : CCNode
{
    @private
        NSMutableDictionary*    _levels;
}

- (id)      initFromLevelsFile: (NSString*)levelsPList;

@end
