#import "UIIngameAnimation.h"
#import "Resource.h"
#import "Particle.h"

@interface BoneCollectUIAnimation : UIIngameAnimation {
    CGPoint start,end;
	int CTMAX;
}

+(BoneCollectUIAnimation*)cons_start:(CGPoint)start end:(CGPoint)end;
-(id)set_ctmax:(int)ctm;
@end

@interface TreatCollectUIAnimation : BoneCollectUIAnimation
+(TreatCollectUIAnimation*)cons_start:(CGPoint)start end:(CGPoint)end;
@end

@interface BoneCollectUIAnimation_Particle : Particle
+(BoneCollectUIAnimation_Particle*)cons_start:(CGPoint)start end:(CGPoint)end;
-(BoneCollectUIAnimation_Particle*)set_texture:(CCTexture2D*)tex rect:(CGRect)rect;
@end
