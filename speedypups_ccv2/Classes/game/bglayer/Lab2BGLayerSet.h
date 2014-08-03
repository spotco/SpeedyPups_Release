#import "BGLayer.h"

typedef enum Lab2BGLayerSetState {
	Lab2BGLayerSetState_Normal,
	Lab2BGLayerSetState_Sinking,
	Lab2BGLayerSetState_Sunk
} Lab2BGLayerSetState;

@interface SubBossBGObject : BackgroundObject {
	CCNode *anchor;
	CGPoint actual_position;
	CGPoint recoil_delta;
	
	CCAction* _anim_body_normal;
	CCAction* _anim_body_broken;
	CCAction* _anim_hatch_closed;
	CCAction* _anim_hatch_closed_to_cannon;
	CCAction* _anim_hatch_cannon_to_closed;
	CCAction* _anim_hatch_closed_to_open;
	
	BOOL broken;
}
+(SubBossBGObject*)cons_anchor:(CCNode*)anchor;
-(void)set_recoil_delta:(CGPoint)delta;
-(CGPoint)get_nozzle:(GameEngineLayer*)g;

-(void)anim_hatch_closed;
-(void)anim_hatch_closed_to_cannon;
-(void)anim_hatch_closed_to_open;
-(void)anim_hatch_cannon_to_closed;

-(void)set_broken;

-(void)explosion_at_nozzle;
-(void)launch_rocket;
-(void)splash_tick:(CGPoint)dir offset:(CGPoint)offset;
-(void)reset;

@property(readwrite,strong) CCSprite *body;
@property(readwrite,strong) CCSprite *hatch;
@end

@interface Lab2BGLayerSet : BGLayerSet {
	NSMutableArray *bg_objects;
	BackgroundObject *tankers;
	BackgroundObject *tankersfront;
	BackgroundObject *docks;
	float tankers_theta;
	
	BackgroundObject *sky;
	BackgroundObject *clouds;
	
	NSMutableArray *particles;
	NSMutableArray *particles_tba;
	NSMutableArray *tankersfront_particles_tba;
	NSMutableArray *behindwater_particles_tba;
	CCSprite *tankersfront_particleholder;
	CCSprite *behindwater_particleholder;
	CCSprite *particleholder;
	Lab2BGLayerSetState current_state;
	
	SubBossBGObject *subboss;
}

+(Lab2BGLayerSet*)cons;
-(SubBossBGObject*)get_subboss_bgobject;
-(void)do_sink_anim;
-(void)reset;
@end
