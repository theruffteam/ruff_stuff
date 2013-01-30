// =============================================================================
// File      : CAudioManagement.h
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/29/2013
// =============================================================================
// This is the header file for the "CAudioManagement" class.
// =============================================================================
#import "CAudio.h"

@interface CAudioManagement : CAudio
{
    @private
        NSDictionary*           _audioDictionary;
}


// prototypes
- (id) initFromAudioFile:(NSString*)audioPList;
- (NSDictionary*) initializeAudioCategory:(NSString*)category forEntity:(NSString*)entityName;

@end