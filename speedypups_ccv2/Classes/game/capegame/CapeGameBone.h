#import "CapeGameEngineLayer.h"

@interface CapeGameBone : CapeGameObject {
	BOOL active;
	BOOL follow;
}
+(CapeGameBone*)cons_pt:(CGPoint)pt;
-(void)on_hit:(CapeGameEngineLayer*)g;
@end

@interface CapeGameOneUpObject : CapeGameBone
+(CapeGameOneUpObject*)cons_pt:(CGPoint)pt;
@end

@interface CapeGameTreatObject : CapeGameBone
+(CapeGameTreatObject*)cons_pt:(CGPoint)pt;
@end