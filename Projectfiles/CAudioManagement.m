// =============================================================================
// File      : CAudioManagement.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/29/2013
// =============================================================================
// This is the implementation file for the "CAudioManagement" class.
// =============================================================================
#import "CAudioManagement.h"


@implementation CAudioManagement

// === initFromAudioFile =======================================================
// This function simply loads the world audio property list into memory.
// =============================================================================
// Input:
//         audioPList -- filename of the audio plist, including the extension 
//
// Output:
//         nothing
// =============================================================================
- (id) initFromAudioFile: (NSString*)audioPList
{
    NSString*    directory = [audioPList stringByDeletingLastPathComponent];
    NSString*    file = [audioPList lastPathComponent];
    NSString*    path = [[NSBundle mainBundle] pathForResource:file ofType:nil inDirectory:directory];
    
    
    _audioDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    if (nil == _audioDictionary)
        {
        NSLog(@"CAudioManagement: Failed to load audio contents from file: %@", file);
        }
    else
        {
        NSLog(@"CAudioManagement: Succesfully loaded audio contents from file: %@", file);
        }
    
    return self;
}


// === initializeAudioCategory =================================================
// This function will create a dictionary of audio elements.
// =============================================================================
// Input:
//         category   -- name of category of desired audio (eg music or effects)
//         entityName -- name of entity under desired audio category
//
// Output:
//         if successful, returns a dictionary of the desired audio elements.
//         Otherwise, returns nil
// =============================================================================
- (NSDictionary*) initializeAudioCategory:(NSString*)category forEntity:(NSString*)entityName
{
    // get the desired sub-audio-dictionary from our world audio dictionary
    NSDictionary*    resultDictionary = [(NSDictionary*)[_audioDictionary objectForKey:category] objectForKey:entityName];


    // if we have found what we are looking for, go ahead and populate a new
    // dictionary of audio elements, with respect to the sub-audio-dictionary
    if (nil != resultDictionary)
        {
        // this function call should return an NSDictionary of audio objects
        //resultDictionary = [CAudio loadAudioFromDictionary: resultDictionary];
        }
    else
        {
        NSLog(@"CAudioManagement: Failed to find audio dictionary with category: %@ and entity: %@", category, entityName);
        }

    return resultDictionary;
}

@end