#import "ArmorBreakEffect.h"
#import "FileCache.h"
#import "GameEngineLayer.h"

@implementation ArmorBreakEffect


+(void)cons_at:(CGPoint)pos in:(GameEngineLayer *)g {
    for(int i = 0; i < 5; i++ ){
        [g add_particle:[ArmorBreakEffect cons_pos:pos v:ccp(float_random(-10, 10),float_random(0, 14)) piece:i]];
    }
}

+(ArmorBreakEffect*)cons_pos:(CGPoint)pos v:(CGPoint)v piece:(int)i {
    return [[ArmorBreakEffect node] cons_pos:pos v:v piece:i];
}

-(id)cons_pos:(CGPoint)pos v:(CGPoint)v piece:(int)i {
    NSArray *parts = @[@"particle_a",@"particle_b",@"particle_c",@"particle_d",@"particle_e"];
    [self setTexture:[Resource get_tex:TEX_DOG_ARMORED]];
    [self setTextureRect:[FileCache get_cgrect_from_plist:TEX_DOG_ARMORED idname:parts[i]]];
    
    vel = v;
    ct = 100;
    [self setPosition:pos];
    return self;
}

-(void)update:(GameEngineLayer *)g {
    vel.y -= 0.5;
    [self setPosition:CGPointAdd(self.position,vel)];
    ct--;
}

-(BOOL)should_remove {
    return ct <= 0;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ABOVE_FG_ORD];
}

@end
