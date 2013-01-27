// =============================================================================
// File      : CCharacterManagement.h
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the header file for the "CCharacterManagement" class.
// =============================================================================

#import <Foundation/Foundation.h>
#import "kobold2d.h"

@interface CCharacterManagement : CCNode
{
    @private
        NSMutableDictionary*    _characters;
}

- (id)      initFromCharactersFile: (NSString*)charactersPList;
- (bool)    createCharacter;
- (bool)    deleteCharacter;
- (bool)    modifyCharacter;

@end
