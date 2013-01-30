// =============================================================================
// File      : CAudio.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/29/2013
// =============================================================================
// This is the implementation file for the "CAudio" class.
// =============================================================================
#import "CDXPropertyModifierAction.h"
#import "CAudio.h"


@implementation CAudio

- (SimpleAudioEngine*) engine
{
    if (! _audioEngine)
        {
        _audioEngine = [SimpleAudioEngine sharedEngine];
        }
    
    return _audioEngine;
}


- (NSDictionary*) loadAudioFromDictionary:(NSDictionary*)audioDictionary;
{
/*
    // create a dictionary which will hold all music elements
    
    NSDictionary*    music = [audioDictionary objectForKey:@"music"];
    NSDictionary*    music2 = [audioDictionary objectForKey:@"music"];
    
    // if we don't have music as a root, the audio dictionary is incorrectly
    // formatted, so display an error message and leave
    if (nil == music)
        {
        CCLOG(@"CAudioManagement: No music found in the working audio dictionary.");
        
        return;
        }
    
    
    // we're going to need all the level names
    NSArray*    levelNames = [music allKeys];
    
    // for every level, there are two catagories of music - background and boss
    for (NSString* nextLevelName in levelNames)
        {
        NSDictionary*    levelDictionary = [music objectForKey:nextLevelName];
        
        NSDictionary*         frameNames = [levelDictionary objectForKey:@"frames"];
        NSNumber*        delay = [levelDictionary objectForKey:@"delay"];
        
        CCAnimation* animation = nil;
        
        if ( frameNames == nil )
            {
            CCLOG(@"ISCCAnimationCacheExtensions: Animation '%@' found in dictionary without any frames - cannot add to animation cache.", nextLevelName);
            continue;
            }
        }
*/
/*
     // create a dictionary which will hold all music elements
     NSDictionary*    music = [audioDictionary objectForKey:@"music"];
     
     // if we don't have music as a root, the audio dictionary is incorrectly
     // formatted, so display an error message and leave
     if (nil == music)
     {
     CCLOG(@"CAudioManagement: No music found in the working audio dictionary.");
     
     return;
     }    
     */
    
    CCLOG(@"CAudioManagement: No music found in the working audio dictionary.");
    return nil;
}


- (void) playBackgroundMusic: (NSString*)musicFilename withVolumeAt: (float)volume isBackgroundMusicOn: (BOOL)isMusicAlreadyPlaying
{
    // preload and play
    // if no current music is playing, preload incoming music
    if (!isMusicAlreadyPlaying)
        {
        // fade in
        [[self engine] playBackgroundMusic:musicFilename];
        
        [_audioEngine setBackgroundMusicVolume: 0.5];
        
        [CDXPropertyModifierAction fadeBackgroundMusic:0.0f finalVolume:0.5f curveType:kIT_Exponential shouldStop:NO];
        }
    else
        {
        // fade out
        [CDXPropertyModifierAction fadeBackgroundMusic:0.8f finalVolume:0.0f curveType:kIT_Exponential shouldStop:NO];
        
        [self playBackgroundMusic:musicFilename withVolumeAt:volume isBackgroundMusicOn:!isMusicAlreadyPlaying];
        }
}

@end