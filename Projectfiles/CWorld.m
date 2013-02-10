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

- (id) initLevelContentsFromFile: (NSString*)levelsPList  actorContentsFromFile: (NSString*)actorsDirectory  graphicContentsFromFile: (NSString*)graphicsPList  audioContentsFromFile: (NSString*)audioPList  resourceContentsFromFile: (NSString*)resourcesPList
{
    if (self = [super init])
        {
        // levels
        _levelManager = [[CLevelManagement alloc] initFromLevelsFile: levelsPList];

        // actors
        _actorManager = [[CActorManagement alloc] initActorsFromDirectory: actorsDirectory];

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
