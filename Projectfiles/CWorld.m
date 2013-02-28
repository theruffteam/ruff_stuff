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

@interface CWorld (PrivateMethods)
-(BOOL) initActors: (NSString*)actorsPList;

@end


@implementation CWorld

- (id) initWorldWithActorsFromPlist: (NSString*)actorsPList
{
    if (self = [super init])
        {
        // initialize our dictionary of world assets
        if (! [self initActors: actorsPList])
            {
            CCLOG(@"Failed to initialize the world assests dictionary");
            }
        }

    return self;
}


-(BOOL) initActors: actorsPList
{
    BOOL    isInitialized = NO;

    CCLOG(@"%s", __PRETTY_FUNCTION__);

    _dictionaryOfWorldActors = [[NSMutableDictionary alloc] init];
    
    NSArray* actors = [[NSBundle mainBundle] pathsForResourcesOfType:@".h" inDirectory:@"ActorClasses"];

    for (NSString* actor in actors)
        {
        NSString* actorClassName = [[actor lastPathComponent] stringByDeletingPathExtension];
        CCLOG(@"Loading Actor: %@", actorClassName);
        
        [_dictionaryOfWorldActors setObject:[[[NSDictionary alloc] initWithContentsOfFile:actorsPList] objectForKey:actorClassName] forKey: actorClassName];
        }

    return isInitialized;
}


@end
