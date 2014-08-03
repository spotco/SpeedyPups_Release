#import <Foundation/Foundation.h>
#import "Player.h"
@class GameEngineLayer;


@interface PlayerEffectParams : NSObject {
    int time_left,cur_airjump_count,cur_dash_count;
    float cur_gravity;
}

/*
 @cur_gravity:
 @noclip: 0 for normal, 0 < for noclip mode (some gameobjs will check noclip number for ragdoll priority, ex spike then fall into water)
 */
@property(readwrite,assign) float cur_gravity;
@property(readwrite,assign) int time_left,cur_airjump_count,cur_dash_count;
@property(readwrite,assign) int noclip;
@property(readwrite,assign) Player* player;

+(PlayerEffectParams*)cons_copy:(PlayerEffectParams*)p;
+(void)copy_params_from:(PlayerEffectParams*)a to:(PlayerEffectParams*)b;
-(player_anim_mode)get_anim;
-(void)update:(Player*)p g:(GameEngineLayer *)g;

-(void)decrement_timer;
-(void)effect_begin:(Player*)p;
-(void)effect_end;
-(void)add_airjump_count;
-(void)decr_airjump_count;
-(void)decr_dash_count;
-(NSString*)info;

-(BOOL)is_also_dashing;

@end
