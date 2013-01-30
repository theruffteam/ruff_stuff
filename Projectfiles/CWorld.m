// =============================================================================
// File      : CWorld.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/29/2013
// =============================================================================
// This is the implementation file for the "CWorld" class.
// =============================================================================

#import "CWorld.h"

@implementation CWorld

- (id) initLevelContentsFromFile: (NSString*)levelsPList  actorContentsFromFile: (NSString*)actorsPList  graphicContentsFromFile: (NSString*)graphicsPList  audioContentsFromFile: (NSString*)audioPList  resourceContentsFromFile: (NSString*)resourcesPList
{
    if (self = [super init])
        {
        // levels
        self._levelManager = [[CLevelManagement alloc] initFromLevelsFile: levelsPList];

        // actors
        self._actorManager = [[CActorManagement alloc] initFromActorsFile: actorsPList];

        // graphics
        self._graphicManager = [[CGraphicManagement alloc] initFromGraphicsFile: graphicsPList];

        // audio
        self._audioManager = [[CAudioManagement alloc] initFromAudioFile: audioPList];

        // resources
        self._resourceManager = [[CResourceManagement alloc] initFromResourcesFile: resourcesPList];
        }

    return self;
}


@end
