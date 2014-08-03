#import "GameObject.h"
#import "cocos2d.h"
#import "Resource.h"

@interface DogBone : GameObject {
    BOOL anim_toggle;
    BOOL challenge_mode_respawn;
    int bid;
    
    BOOL refresh_cached_hitbox;
    HitRect cached_hitbox;
    
    float vx,vy;
    BOOL follow;
    CGPoint initial_pos;
    
	GameEngineLayer __unsafe_unretained *gameengine;
}

+(DogBone*)cons_x:(float)x y:(float)y bid:(int)bid;
+(void)play_collect_sound:(GameEngineLayer*)gameengine;
+(void)reset_play_collect_sound;
-(void)hit;

@property(readwrite,assign) int bid;
@property(readwrite,strong) CCSprite* img;
@end
