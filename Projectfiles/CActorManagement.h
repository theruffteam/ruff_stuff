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

    @property    NSMutableDictionary*        actors;


- (id)      initActorsFromDirectory: (NSString*)actorsDirectory;
- (bool)    createCharacter;
- (bool)    deleteCharacter;
- (bool)    modifyCharacter;

@end
