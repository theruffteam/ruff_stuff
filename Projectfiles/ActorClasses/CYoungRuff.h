// =============================================================================
// File      : CYoungRuff.h
// Project   : Ruff
// Author(s) : theruffteam
// Version   : 0
// Updated   : 01/26/2013
// =============================================================================
// This is the header file for the "CActor" class.
// =============================================================================

#import <Foundation/Foundation.h>
#import "kobold2d.h"
#import "CActor.h"

typedef enum
{
    NormalMode = 0,
	DemoMode,
	ShowcaseMode,
} PlayingMode;


@interface CYoungRuff : CActor


- (id) initRuff: (PlayingMode) playMode;

@end
