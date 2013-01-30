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
#import "CActorManagement.h"
#import "CGraphicManagement.h"
#import "CAudioManagement.h"
#import "CResourceManagement.h"
#import "kobold2d.h"

@interface CWorld : CCLayer
    // levels
    @property    CLevelManagement*        _levelManager;
    
    // resources
    @property    CResourceManagement*     _resourceManager;
    
    // actors
    @property    CActorManagement*        _actorManager;
    
    // graphics
    @property    CGraphicManagement*      _graphicManager;
    
    // audio
    @property    CAudioManagement*        _audioManager;


- (id) initLevelContentsFromFile: (NSString*)levelsPList  actorContentsFromFile: (NSString*)actorsPList  graphicContentsFromFile: (NSString*)graphicsPList  audioContentsFromFile: (NSString*)audioPList  resourceContentsFromFile: (NSString*)resourcesPList;

@end