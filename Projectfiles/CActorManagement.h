// =============================================================================
// File      : CActorManagement.h
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/29/2013
// =============================================================================
// This is the header file for the "CCharacterManagement" class.
// =============================================================================

#import <Foundation/Foundation.h>
#import "kobold2d.h"

@interface CActorManagement : CCNode
{
    @private
        NSMutableDictionary*    _characters;
}

- (id)      initFromActorsFile: (NSString*)actorsPList;
- (bool)    createCharacter;
- (bool)    deleteCharacter;
- (bool)    modifyCharacter;

@end
