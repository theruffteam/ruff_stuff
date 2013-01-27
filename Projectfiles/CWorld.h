// =============================================================================
// File      : CWorld.h
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the header file for the "CWorld" class.
// =============================================================================

#import <Foundation/Foundation.h>
#import "CLevelManagement.h"
#import "CCharacterManagement.h"
#import "CGraphicManagement.h"
#import "CAudioManagement.h"
#import "CResourceManagement.h"
#import "kobold2d.h"

@interface CWorld : CCLayer
{
    
    
    // levels
    CLevelManagement*        _levelManager;
    
    // resources
    CResourceManagement*     _resourceManager;
    
    // characters
    CCharacterManagement*    _characterManager;
    
    // graphics
    CGraphicManagement*      _graphicManager;
    
    // audio
    CAudioManagement*        _audioManager;
}

- (id) initLevelContentsFromFile: (NSString*)levelsPList  characterContentsFromFile: (NSString*)charactersPList  graphicContentsFromFile: (NSString*)graphicsPList  audioContentsFromFile: (NSString*)audioPList  resourceContentsFromFile: (NSString*)resourcesPList;

@end
