// =============================================================================
// File      : CWorld.h
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/29/2013
// =============================================================================
// This is the header file for the "CWorld" class.
// =============================================================================

#import <Foundation/Foundation.h>
#import "kobold2d.h"
#import "CGameMechanicsScene.h"
#import "CLevel.h"


@interface CWorld : CCLayer

    @property    unsigned int             currentLevel;
    @property    NSMutableArray*          stateSequenceOfEvents;
    @property    CLevel*                  levelFactory;

    // actors (any living entity)
    @property    NSMutableDictionary*     worldActors;

    // assests (any non-living entity - e.g. platform, rock, etc.)
    @property    NSMutableDictionary*     worldAssets;

    // audio
    @property    NSMutableDictionary*     worldAudio;

    // cutscenes
    @property    NSMutableDictionary*     worldCutScenes;

    // graphics (e.g. backgrounds and foregrounds)
    @property    NSMutableDictionary*     worldGraphics;

    // levels (configurations)
    @property    NSMutableDictionary*     worldLevels;


- (id) initWorldContentsFromPlist: (NSString*)worldPList;

- (void) playNextLevel;

@end