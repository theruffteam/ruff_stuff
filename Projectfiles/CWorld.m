// =============================================================================
// File      : CWorld.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/29/2013
// =============================================================================
// This is the implementation file for the "CWorld" class.
// =============================================================================

#import <objc/runtime.h>

#import "CWorld.h"
#import "CYoungRuff.h"
#import "CActor.h"

@interface CWorld (PrivateMethods)
- (BOOL) initActors: (NSString*)actorsPList;
- (BOOL) initAssets: (NSString*)assetsPList;
- (BOOL) initAudio: (NSString*)audioPList;
- (BOOL) initCutscenes: (NSString*)cutscenesPList;
- (BOOL) isObjectEmpty: (id)thing;


@end


@implementation CWorld
// Check if the "thing" pass'd is empty
- (BOOL) isObjectEmpty: (id) thing
{
    return thing == nil
    || [thing isKindOfClass:[NSNull class]]
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}


- (id) initWorldContentsFromPlist: (NSString*)worldPList;
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    
    if (self = [super init])
        {
        NSDictionary* dictionaryOfTheWorld = [NSDictionary dictionaryWithContentsOfFile: worldPList];
        BOOL isWorldInitSuccess = YES;
        NSString* horizontalLineForDebugOutput = @"//===========================================================";
        
        
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([CActor class], &outCount);
        NSMutableArray* propertyNames = [[NSMutableArray alloc] init];

        
        for (i = 0; i < outCount; i++)
            {
            // add all property names to an nsarray
            [propertyNames addObject: [NSString stringWithCString: property_getName(properties[i]) encoding:NSUTF8StringEncoding]];
            }
        
        free(properties);
        
        
        
        CCLOG(@"%u", [propertyNames containsObject: @"hitPoints"]);
        
        
        
        CCLOG(@" ");
        CCLOG(@"%@", horizontalLineForDebugOutput);
        CCLOG(@"// Initializing Actors...");
        CCLOG(@"%@", horizontalLineForDebugOutput);
        
        if ((_worldActors = [NSMutableDictionary dictionaryWithContentsOfFile: [dictionaryOfTheWorld valueForKey:@"actors"]]))
            {
            CCLOG(@"%u/%u entries are valid actor classes", [self countEntryKeysAsClassesInDictionary: _worldActors], [_worldActors count]);
            }
        else
            {
            CCLOG(@"Failed to create the world actors dictionary.");
            isWorldInitSuccess = NO;
            }
        
        
        CCLOG(@" ");
        CCLOG(@"%@", horizontalLineForDebugOutput);
        CCLOG(@"// Initializing Assets...");
        CCLOG(@"%@", horizontalLineForDebugOutput);
        
        if ((_worldAssets = [NSMutableDictionary dictionaryWithContentsOfFile: [dictionaryOfTheWorld valueForKey:@"assets"]]))
            {
            CCLOG(@"%u/%u entries are valid asset classes", [self countEntryKeysAsClassesInDictionary: _worldAssets], [_worldAssets count]);
            }
        else
            {
            CCLOG(@"Failed to create the world assets dictionary.");
            isWorldInitSuccess = NO;
            }
        
        
        CCLOG(@" ");
        CCLOG(@"%@", horizontalLineForDebugOutput);
        CCLOG(@"// Initializing Audio...");
        CCLOG(@"%@", horizontalLineForDebugOutput);
        
        if ((_worldAudio = [NSMutableDictionary dictionaryWithContentsOfFile: [dictionaryOfTheWorld valueForKey:@"audio"]]))
            {
            CCLOG(@"%u/%u entries are valid audio filenames", [self countEntryValuesAsFilesInDictionary: _worldAudio usingCurrentStringIndentation: @""], [_worldAudio count]);
            }
        else
            {
            CCLOG(@"Failed to create the world audio dictionary.");
            isWorldInitSuccess = NO;
            }
        
        
        CCLOG(@" ");
        CCLOG(@"%@", horizontalLineForDebugOutput);
        CCLOG(@"// Initializing Graphics...");
        CCLOG(@"%@", horizontalLineForDebugOutput);
        
        if ((_worldGraphics = [NSMutableDictionary dictionaryWithContentsOfFile: [dictionaryOfTheWorld valueForKey:@"graphics"]]))
            {
            CCLOG(@"%u/%u entries are valid graphic filenames", [self countEntryValuesAsFilesInDictionary: _worldGraphics usingCurrentStringIndentation: @""], [_worldGraphics count]);
            }
        else
            {
            CCLOG(@"Failed to create the world graphics dictionary.");
            isWorldInitSuccess = NO;
            }
        
        
        CCLOG(@" ");
        CCLOG(@"%@", horizontalLineForDebugOutput);
        CCLOG(@"// Initializing Levels...");
        CCLOG(@"%@", horizontalLineForDebugOutput);
        
        if ((_worldLevels = [NSMutableDictionary dictionaryWithContentsOfFile: [dictionaryOfTheWorld valueForKey:@"levels"]]))
            {
            CCLOG(@"%u/%u entries are valid levels filenames", [self countEntryValuesAsFilesInDictionary: _worldLevels usingCurrentStringIndentation: @""], [_worldLevels count]);
            }
        else
            {
            CCLOG(@"Failed to create the world levels dictionary.");
            isWorldInitSuccess = NO;
            }

        if (! isWorldInitSuccess)
            {
            CCLOG(@"Failed to initialize all world dictionaries.");
            exit(EXIT_FAILURE);
            }
        
        CCLOG(@" ");
        CCLOG(@"Successfully initialized all world dictionaries.");
        }

    return self;
}


- (void) playNextLevel
{
    ++_currentLevel;
    
}

- (unsigned int) countEntryKeysAsClassesInDictionary: (NSMutableDictionary*)aDictionary;
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    
    unsigned int __block    numberOfValidEntryKeys = 0;
    
    
    [aDictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
        
        if (NSClassFromString(key))
            {
            CCLOG(@"%@ => %@", key, obj);
            ++numberOfValidEntryKeys;
            }
        else
            {
            CCLOG(@"%@ => Invalid class name", key);
            }
    }];
    
    return numberOfValidEntryKeys;
}


- (unsigned int) countEntryValuesAsFilesInDictionary: (NSMutableDictionary*)aDictionary usingCurrentStringIndentation:(NSString*) indentation
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    
    
    unsigned int __block    numberOfValidEntryValues = 0;
    
    if ([aDictionary count])
        {
        // start iterating over the keys of the dictionary
        [aDictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop)
            {
            CCLOG(@"%@%@:", indentation, key);
            
            // if the current key is the name of an actual class we have made
            if (NSClassFromString(key))
                {
                // then spin off into a new call that handles class integrity checks
                [self checkIntegrityOfClassFromDictionary: obj withClassName:key usingCurrentStringIndentation: indentation];
                }
            // if the current key's value is a dictionary,
            // recursively iterate through it
            else if ([obj isKindOfClass: [NSDictionary class]])
                {
                if ([(NSMutableDictionary*)obj count])
                    {
                    [self countEntryValuesAsFilesInDictionary: obj usingCurrentStringIndentation: [indentation stringByAppendingString: @"\t"]];
                    }
                else
                    {
                    CCLOG(@"%@\t** NO KEYS FOUND **", indentation);
                    }
                }
            // if the current key has no value
            else if ([self isObjectEmpty: obj])
                {
                CCLOG(@"%@\t** NO VALUE FOUND **", indentation);
                }
            // if the current key's value is a string and has a file extension
            else if (([obj isKindOfClass: [NSString class]])  &&  (! [[obj pathExtension] isEqualToString:@""]))
                {
                // then see if the file exists in the app bundle
                if ([[NSFileManager defaultManager] fileExistsAtPath: obj])
                    {
                    CCLOG(@"%@\t%@ => file exists!", indentation, obj);
                    ++numberOfValidEntryValues;
                    }
                // otherwise, display an error message
                else
                    {
                    CCLOG(@"%@\t%@: => file doesn't exist.", indentation, obj);
                    }
                }
            // otherwise, just display the current key's value
            else
                {
                CCLOG(@"%@\t%@", indentation, obj);
                ++numberOfValidEntryValues;
                }
            }];
        }
    else
        {
        CCLOG(@"%@** NO KEYS FOUND **", indentation);
        }
    
    return numberOfValidEntryValues;
}



- (void) checkIntegrityOfClassFromDictionary: (NSMutableDictionary*)aDictionary withClassName:(NSString*)className usingCurrentStringIndentation:(NSString*)indentation
{
    //
    unsigned int        numberOfProperties;
    objc_property_t*    properties = class_copyPropertyList(NSClassFromString(className), &numberOfProperties);
    NSMutableArray*     propertyNames = [[NSMutableArray alloc] init];
    
    
    if ([aDictionary count])
        {
        for (unsigned int currentPropertyIndex = 0; currentPropertyIndex < numberOfProperties; ++currentPropertyIndex)
            {
            // add all property names to an nsarray
            [propertyNames addObject: [NSString stringWithCString: property_getName(properties[currentPropertyIndex]) encoding:NSUTF8StringEncoding]];
            }
        
        free(properties);
        
        // start iterating over the keys of the dictionary:
        // if a key cannot be tranformed into a class, it is considered to be a
        // property within the current class
        [aDictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop)
            {
            // do we have another class to check the integrity of?
            if (NSClassFromString(key))
                {
                CCLOG(@"%@\t%@:", indentation, key);
                
                [self checkIntegrityOfClassFromDictionary:obj withClassName:key usingCurrentStringIndentation:[indentation stringByAppendingString:@"\t"]];

                return;
                }
            
            if ([propertyNames containsObject: (NSString*)key])
                {
                CCLOG(@"%@\t%@ => VALID PROPERTY", indentation, key );
                }
            else
                {
                CCLOG(@"%@\t%@ => INVALID PROPERTY", indentation, key);
                }
            }];
        }
    else
        {
        CCLOG(@"\t%@** NO CLASS PROPERTIES FOUND **", indentation);
        }

}
/*
    if (NSClassFromString(key))
        {
        CCLOG(@"%@ => %@", key, obj);
        ++numberOfValidEntryKeys;
        }
    else
        {
        CCLOG(@"%@ => Invalid class name", key);
        }
}
*/

@end
