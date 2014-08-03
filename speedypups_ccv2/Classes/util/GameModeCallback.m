#import "GameModeCallback.h"
#import "GameMain.h"

@implementation GameModeCallback

@synthesize mode;
@synthesize val;

+(GameModeCallback*)cons_mode:(GameMode)m n:(int)n {
    GameModeCallback *o = [[GameModeCallback alloc] init];
    o.mode = m;
    o.val = n;
    return o;
}

-(void)run {
    [GameMain start_from_callback:self];
}

@end
