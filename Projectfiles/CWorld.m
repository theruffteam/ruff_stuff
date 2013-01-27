// =============================================================================
// File      : CWorld.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the implementation file for the "CWorld" class.
// =============================================================================

#import "CWorld.h"


@implementation CWorld


- (id) initLevelContentsFromFile: (NSString*)levelsPList  characterContentsFromFile: (NSString*)charactersPList  graphicContentsFromFile: (NSString*)graphicsPList  audioContentsFromFile: (NSString*)audioPList  resourceContentsFromFile: (NSString*)resourcesPList
{
    if(self = [super init])
        {
        // levels
        _levelManager = [[CLevelManagement alloc] initFromLevelsFile: levelsPList];

        // characters
        _characterManager = [[CCharacterManagement alloc] initFromCharactersFile: charactersPList];

        // graphics
        _graphicManager = [[CGraphicManagement alloc] initFromGraphicsFile: graphicsPList];

        // audio
        _audioManager = [[CAudioManagement alloc] initFromAudioFile: audioPList];

        // resources
        _resourceManager = [[CResourceManagement alloc] initFromResourcesFile: resourcesPList];
        }

    return self;
}


@end
