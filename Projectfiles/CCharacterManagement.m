// =============================================================================
// File      : CCharacterManagement.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the implementation file for the "CCharacter" class.
// =============================================================================

#import "CCharacterManagement.h"


@implementation CCharacterManagement

- (id) initFromCharactersFile: (NSString*)charactersPList;
{
    self = [super init];

    if (self)
        {
        _characters = [[NSMutableDictionary alloc] init];
        }

    return self;
}


- (bool) createCharacter
{


    return true;
}


- (bool) deleteCharacter
{

    return true;
}


- (bool) modifyCharacter
{

    return true;
}
@end