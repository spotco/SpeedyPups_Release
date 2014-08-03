#import "CheckPoint.h"
#import "GameEngineLayer.h"
#import "ScoreManager.h"

@implementation CheckPoint

+(CheckPoint*)cons_x:(float)x y:(float)y {
    CheckPoint *p = [CheckPoint node];
    p.position = ccp(x,y);

    [p cons_img];
    
    p.active = YES;
    
    return p;
}

+(CCSprite*)makeimg:(CCTexture2D*)tex {
    CCSprite *i = [CCSprite spriteWithTexture:tex];
    i.position = ccp(0,[i boundingBox].size.height / 2.0);
    return i;
}

-(CGPoint)get_center {
    HitRect r = [Common hitrect_cons_x1:[self position].x-texwid/2 y1:[self position].y wid:texwid hei:texhei];
    return ccp((r.x2-r.x1)/2+r.x1,(r.y2-r.y1)/2+r.y1);
}

-(void)cons_img {
    CCTexture2D *tex1 = [Resource get_tex:TEX_CHECKPOINT_1];
    CCTexture2D *tex2 = [Resource get_tex:TEX_CHECKPOINT_2];
    inactive_img = [CheckPoint makeimg:tex1];
    active_img = [CheckPoint makeimg:tex2];
    [self addChild:inactive_img];
    [self addChild:active_img];
    inactive_img.visible = YES;
    active_img.visible = NO;
    texwid = [tex1 contentSizeInPixels].width;
    texhei = [tex1 contentSizeInPixels].height;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-texwid/2 y1:[self position].y wid:texwid hei:texhei+500];
}

-(void)update:(Player*)player g:(GameEngineLayer *)g{	
    [super update:player g:g];
    if (!activated && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
		
		[g.score increment_multiplier:0.05];
		[g.score increment_score:100];
		
        activated = YES;
        inactive_img.visible = NO;
        active_img.visible = YES;
        
        CGPoint center = [self get_center];
        [GEventDispatcher push_event:[[GEvent cons_type:GEventType_CHECKPOINT] add_pt:center]];
        for(int i = 0; i < 5; i++) {
            [g add_particle:[FireworksParticleA cons_x:center.x y:center.y vx:float_random(-3,3) vy:float_random(9,14) ct:arc4random_uniform(20)+10]];
        }
        [AudioManager playsfx:SFX_CHECKPOINT];
    }
}


@end
