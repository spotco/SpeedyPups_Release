#import "GameObject.h"
#import "Common.h"

@interface PhysicsEnabledObject : GameObject <PhysicsObject> {
    BOOL refresh_hitrect;
    HitRect cached_rect;
}

-(void)reset_physics_params;
-(void)fall_out;
-(HitRect) get_hit_rect_rescale:(float)rsc;

@property(readwrite,strong) PlayerEffectParams* params;
@property(readwrite,assign) CGPoint starting_position;
@property(readwrite,assign) float IMGWID,IMGHEI,movex;

@end
