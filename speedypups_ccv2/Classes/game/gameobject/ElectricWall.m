#import "ElectricWall.h"
#import "AudioManager.h"
#import "GameEngineLayer.h"

@implementation ElectricWall

+(ElectricWall*)cons_x:(float)x y:(float)y x2:(float)x2 y2:(float)y2 {
    ElectricWall *n = [ElectricWall node];
    [n cons_x:x y:y x2:x2 y2:y2];
    return n;
}

-(void)cons_x:(float)x y:(float)y x2:(float)x2 y2:(float)y2 {
    [super cons_x:x y:y x2:x2 y2:y2];
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    [super update:player g:g];
    animct++;
    if (animct%5==0) {
        float r = float_random(-1, 1);
        for(int i = 0; i < 4; i++) {
            center.tex_pts[i].y+=r;
        }
    }
}

-(void)hit:(Player *)player g:(GameEngineLayer *)g {
    if (![player is_armored]) {
        [player reset_params];
        activated = YES;
        [player add_effect:[FlashHitEffect cons_from:[player get_default_params] time:40]];
        [AudioManager playsfx:SFX_ELECTRIC];
		[g shake_for:15 intensity:6];
		[g freeze_frame:6];
    }
}

-(CCTexture2D*)get_base_tex {
    return [Resource get_tex:TEX_ELECTRIC_BASE];
}

-(CCTexture2D*)get_section_tex {
    return [Resource get_tex:TEX_ELECTRIC_BODY];
}

@end
