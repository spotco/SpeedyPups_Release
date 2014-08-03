#import <Foundation/Foundation.h>

typedef enum {
    GameMode_FREERUN,
    GameMode_CHALLENGE
} GameMode;

@interface GameModeCallback : NSObject

+(GameModeCallback*)cons_mode:(GameMode)m n:(int)n;
-(void)run;

@property(readwrite,assign) GameMode mode;
@property(readwrite,assign) int val;

@end
