#import <Foundation/Foundation.h>
@class TexRect;

//possible locations that can be started at
typedef enum {
	FreeRunStartAt_ERRVAL = -1,
	FreeRunStartAt_TUTORIAL = 0,
	FreeRunStartAt_WORLD1 = 1,
	FreeRunStartAt_LAB1 = 2,
	FreeRunStartAt_WORLD2 = 3,
	FreeRunStartAt_LAB2 = 4,
	FreeRunStartAt_WORLD3 = 5,
	FreeRunStartAt_LAB3 = 6
} FreeRunStartAt;

//current mode outside or in lab
typedef enum {
	BGMode_NORMAL,
	BGMode_LAB
} BGMode;

//world number
typedef enum { //worlds are incremented by labentrances, only further created lineislands will be affected
	WorldNum_1 = 1,
	WorldNum_2 = 2,
	WorldNum_3 = 3
} WorldNum;

//info about where to start at (for autolevelstate)
typedef struct _WorldStartAt {
	WorldNum world_num;
	BGMode bg_start;
	BOOL tutorial;
} WorldStartAt;
 
@interface FreeRunStartAtManager : NSObject
+(BOOL)get_can_start_at:(FreeRunStartAt)loc;
+(void)set_can_start_at:(FreeRunStartAt)loc;
+(TexRect*)get_icon_for_loc:(FreeRunStartAt)loc;
+(NSString*)name_for_loc:(FreeRunStartAt)loc;
+(FreeRunStartAt)get_starting_loc;
+(void)set_starting_loc:(FreeRunStartAt)loc;
+(WorldStartAt)get_startingat;
@end

//representation of current world position inside gameengine
@interface GameWorldMode : NSObject
@property(readwrite,assign) WorldNum cur_world;
@property(readwrite,assign) BGMode cur_mode;
+(GameWorldMode*)cons_worldnum:(WorldNum)world;
-(FreeRunStartAt)get_next_world_startat;
-(FreeRunStartAt)get_freerun_progress;
@end
