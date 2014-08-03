#import <Foundation/Foundation.h>
@class GameEngineLayer;

@interface GameMap : NSObject
    @property(readwrite,strong) NSMutableArray *n_islands, *game_objects;
    @property(readwrite,assign) CGPoint player_start_pt;
    @property(readwrite,assign) int assert_links;
    @property(readwrite,assign) float connect_pts_x1,connect_pts_x2,connect_pts_y1,connect_pts_y2;
@end

typedef enum {
	MapLoaderMode_AUTO,
	MapLoaderMode_CHALLENGE
} MapLoaderMode;

@interface MapLoader : NSObject
+(void)set_maploader_mode:(MapLoaderMode)m;
+(GameMap*) load_map:(NSString *)map_file_name g:(GameEngineLayer*)g;
+(void) precache_map:(NSString *)map_file_name;
+(GameMap*) load_capegame_map:(NSString*)map_file_name;
@end
