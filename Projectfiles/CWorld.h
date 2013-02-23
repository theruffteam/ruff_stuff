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
#import "CLevelManagement.h"
#import "CGraphicManagement.h"
#import "CAudioManagement.h"
#import "CResourceManagement.h"
#import "CGameMechanicsScene.h"
#import "kobold2d.h"

@interface CWorld : CCLayer

    @property unsigned int                currentLevel;

    // actors (any living entity)
    @property    NSMutableDictionary*     dictionaryOfWorldActors;

    // assests (any non-living entity - e.g. platform, rock, etc.)
    @property    NSMutableDictionary*     dictionaryOfWorldAssests;

















    // levels (where everything is going to be placed)
    @property    CLevelManagement*        levelManager;








    // resources (replaced by assests dictionary)
    @property    CResourceManagement*     resourceManager;
    

    
    // graphics
    @property    CGraphicManagement*      graphicManager;
    
    // audio
    @property    CAudioManagement*        audioManager;


- (id) initWorldWithActorsFromPlist: (NSString*)actorsPList;

@end