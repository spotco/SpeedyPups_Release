#import "GameObject.h"
#import "SpikeVine.h"

@interface CannonMoveTrack : SpikeVine {
	CGPoint pt1, pt2;
}
+(CannonMoveTrack*)cons_pt1:(CGPoint)pt1 pt2:(CGPoint)pt2;
-(CGPoint)get_pt1;
-(CGPoint)get_pt2;
@end

@interface CannonRotationPoint : CannonMoveTrack
+(CannonRotationPoint*)cons_pt1:(CGPoint)pt1 pt2:(CGPoint)pt2;
@end

@interface Cannon : GameObject {
	BOOL player_loaded;
	BOOL player_head_out;
	float deactivate_ct;
	float head_out_ct;
	
	BOOL has_param_checked;
	BOOL has_rotation_all;
	BOOL has_rotation_twopt;
	BOOL has_move;
	float rotation_angle1, rotation_angle2;
	CGPoint move_pt1, move_pt2;
	float rotate_theta;
	float move_theta;
}

@property(readwrite,assign) CGPoint dir;

+(Cannon*)cons_pt:(CGPoint)pos dir:(CGPoint)dir;

-(BOOL)cannon_show_head:(Player*)p;
-(void)detach_player;
-(CGPoint)get_nozzel_position:(Player*)p;
-(void)deactivate_for:(int)time;

@end
