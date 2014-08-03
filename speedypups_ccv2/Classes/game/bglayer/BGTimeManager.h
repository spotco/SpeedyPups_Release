#import "BackgroundObject.h"
#import "GEventDispatcher.h"

typedef enum {
    MODE_DAY = 0,
    MODE_NIGHT = 1,
    MODE_DAY_TO_NIGHT = 2,
    MODE_NIGHT_TO_DAY = 3
} BGTimeManagerMode;


@interface BGTimeManager : BackgroundObject {
    CCSprite *sun,*moon;
}

+(BGTimeManager*)cons;
+(BGTimeManagerMode)get_global_time;

@end
