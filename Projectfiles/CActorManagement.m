// =============================================================================
// File      : CActorManagement.m
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/29/2013
// =============================================================================
// This is the implementation file for the "CCharacter" class.
// =============================================================================

#import "CActorManagement.h"
#import "CActor.h"

@interface CActorManagement (PrivateMethods)
- (NSDictionary*) createDictionaryForActor: (NSString *) actorName withPListFile: (NSString *) actorPList;
@end

@implementation CActorManagement

- (id) initActorsFromDirectory:(NSString *)actorsDirectory;
{
    if (self = [super init])
        {
        CCLOG(@"%s", __PRETTY_FUNCTION__);
        
        _actors = [[NSMutableDictionary alloc] init];
        
        NSArray* actors = [[NSBundle mainBundle] pathsForResourcesOfType:@".h" inDirectory:@"ActorClasses"];
        
        for (NSString* actor in actors)
            {
            CCLOG(@"Loading Actor: %@", [[actor lastPathComponent] stringByDeletingPathExtension]);
            
            [_actors setObject:[self createDictionaryForActor:[[actor lastPathComponent] stringByDeletingPathExtension] withPListFile:@"actors.plist"] forKey: @"CYoungRuff"];
            }
        }

    return self;
}


- (bool) createCharacter
{


    return true;
}


- (bool) deleteCharacter
{

    return true;
}


- (bool) modifyCharacter
{

    return true;
}


- (NSDictionary*) createDictionaryForActor: (NSString *) actorName withPListFile: (NSString *) actorPList
{
    NSDictionary* actorDictionary = [[[NSDictionary alloc] initWithContentsOfFile:actorPList] objectForKey:actorName];
    
    return actorDictionary;
}


@end