#import "CCSprite.h"
#import "Common.h"
@class CapeGameEngineLayer;

@interface CapeGamePlayer : CSF_CCSprite {
	CCAction *_anim_cape, *_anim_stand, *_anim_rocket, *_anim_hit;
	CCAction *cur_anim;
	
	float rocket_sound_ct;
}

+(CapeGamePlayer*)cons;
-(void)do_cape_anim;
-(void)do_stand;
-(void)do_hit;
-(void)do_rocket;
-(BOOL)is_rocket;

-(void)update:(CapeGameEngineLayer*)g;

-(void)set_rotation;

-(HitRect)get_hitrect;

@property(readwrite,assign) float vx,vy;

@end
