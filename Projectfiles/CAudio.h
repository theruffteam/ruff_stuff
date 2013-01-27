// =============================================================================
// File      : CAudio.h
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the header file for the "CAudio" class.
// =============================================================================
#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"


@interface CAudio: NSObject
{
    @private
        SimpleAudioEngine*      _audioEngine;
}


// prototypes
- (NSDictionary*) loadAudioFromDictionary:(NSDictionary*)audioDictionary;
- (void) playBackgroundMusic:(NSString*)musicFilename withVolumeAt:(float)volume isBackgroundMusicOn:(BOOL)isMusicAlreadyPlaying;

@end
