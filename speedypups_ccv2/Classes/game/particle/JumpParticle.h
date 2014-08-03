#import "Particle.h"

@interface JumpParticle : Particle {
	int ct;
	float scale;
	float scx;
	
	CGPoint rel_pos;
	BOOL is_relpos;
	BOOL set_relpos;
}
+(JumpParticle*)cons_pt:(CGPoint)pt vel:(CGPoint)vel up:(CGPoint)up;
+(JumpParticle*)cons_pt:(CGPoint)pt vel:(CGPoint)vel up:(CGPoint)up tex:(CCTexture2D *)tex rect:(CGRect)rect relpos:(BOOL)relpos;
-(id)set_scale:(float)s;
-(id)set_scx:(float)_scx;
@end
