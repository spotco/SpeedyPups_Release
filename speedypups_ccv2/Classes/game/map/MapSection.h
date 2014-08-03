#import "MapLoader.h"
#import "Common.h" 

@interface MapSection : NSObject {
    float offset_x,offset_y;
    int debugid;
}

typedef enum {
    MapSection_Position_PAST,
    MapSection_Position_CURRENT,
    MapSection_Position_AHEAD
} MapSection_Position;

@property(readwrite,strong) GameMap *map;

@property(readwrite,assign) BOOL stop_repool;

+(MapSection*)cons_from_name:(NSString*)name g:(GameEngineLayer*)g;
-(MapSection_Position)get_position_status:(CGPoint)p;
-(CGRange)get_range;
-(void)offset_x:(float)x y:(float)y;
-(CGPoint)get_offset;
//-(int)get_debugid;
@end