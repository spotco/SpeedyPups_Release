#import "BirdFlock.h"
#import "AudioManager.h" 

@interface Bird: CCSprite {
    float vx,vy;
    CGPoint initial_pos;
    BOOL flying;
    id _STANDANIM, _FLYANIM;
    id current_anim;
    int fly_ct;
}
@property(readwrite,assign) int fly_ct;
@property(readwrite,assign) float vx,vy;
@property(readwrite,assign) BOOL flying;
-(void)update;
-(void)set_stand:(id)standanim set_fly:(id)flyanim;
-(void)reset;
@end

@implementation Bird
@synthesize vx,vy;
@synthesize flying;
@synthesize fly_ct;
-(void)set_stand:(id)standanim set_fly:(id)flyanim {
    _STANDANIM = standanim;
    _FLYANIM = flyanim;
    current_anim = _STANDANIM;
    [self runAction:_STANDANIM];
    initial_pos = [self position];
}
-(void)update {
    [self anim_update];
    if (flying) {
        [self setPosition:ccp([self position].x + vx, [self position].y + vy)];
        fly_ct--;
        if (fly_ct <= 0) {
            [self reset];
        }
    }
}
-(void)anim_update {
    if (flying && current_anim != _FLYANIM) {
        [self stopAllActions];
        current_anim = _FLYANIM;
        [self runAction:_FLYANIM];
        
    } else if (!flying && current_anim != _STANDANIM) {
        [self stopAllActions];
        current_anim = _STANDANIM;
        [self runAction:_STANDANIM];
    }
}

-(void)reset {
    [self setPosition:initial_pos];
    flying = NO;
    [self stopAllActions];
    [self runAction:_STANDANIM];
    [self setVisible:NO];
}
-(void)dealloc {
    [self stopAllActions];
    //NSLog(@"dealloc bird");
}
@end

@implementation BirdFlock

+(BirdFlock*)cons_x:(float)x y:(float)y {
    BirdFlock* b = [BirdFlock node];
    b.position = ccp(x,y);
    [b cons_birds];
    b.active = YES;
    return b;
}

-(BOOL)get_activated {
    return activated;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-200 y1:[self position].y-30 wid:400 hei:200];
}

-(void)update:(Player*)player g:(GameEngineLayer *)g {
    for (Bird *i in birds) {
        [i update];
    }
    
    if (activated) {
        return;
    }
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        [self activate_birds];
    }
    return;
}

-(void)activate_birds {
    activated = YES;
    [AudioManager playsfx:SFX_BIRD_FLY];
    for (Bird *i in birds) {
        i.flying = YES;
        i.fly_ct = 400;
    }
}

-(void)cons_birds {
    birds = [NSMutableArray array];
    
    for(int i = 0; i < 5; i++) {
        Bird* b = [Bird node];
        b.position = ccp(float_random(-100,100),float_random(-5,5));
        b.vx = float_random(-9, 9) / CC_CONTENT_SCALE_FACTOR();
        b.vy = float_random(5, 15) / CC_CONTENT_SCALE_FACTOR();
        
        id _STAND_ANIM = [self cons_stand_anim:float_random(0.1, 0.3)];
        id _FLY_ANIM = [self cons_fly_anim:float_random(0.1, 0.3)];
        
        [b set_stand:_STAND_ANIM set_fly:_FLY_ANIM];
        if (b.vx > 0) {
            b.scaleX = -1;
        }
        [birds addObject:b];
        [self addChild:b];
    }
}

-(void)set_active:(BOOL)t_active {
    active = t_active;
}

-(void)reset {
    [super reset];
    activated = NO;
    for (Bird *i in birds) {
        [i reset];
        [i setVisible:YES];
    }
}

-(id)cons_stand_anim:(float)speed {
    CCTexture2D *tex = [Resource get_tex:TEX_BIRD_SS];
    NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[BirdFlock bird_ss_rect_tar:@"sit1"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[BirdFlock bird_ss_rect_tar:@"sit2"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[BirdFlock bird_ss_rect_tar:@"sit3"]]];
    return [Common make_anim_frames:animFrames speed:speed];
}

-(id)cons_fly_anim:(float)speed {
    CCTexture2D *tex = [Resource get_tex:TEX_BIRD_SS];
    NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[BirdFlock bird_ss_rect_tar:@"fly1"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[BirdFlock bird_ss_rect_tar:@"fly2"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[BirdFlock bird_ss_rect_tar:@"fly3"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[BirdFlock bird_ss_rect_tar:@"fly4"]]];
    return [Common make_anim_frames:animFrames speed:speed];
}

+(CGRect)bird_ss_rect_tar:(NSString*)tar {
    return [FileCache get_cgrect_from_plist:TEX_BIRD_SS idname:tar];
}

-(void)dealloc {
    [birds removeAllObjects];
    [self removeAllChildrenWithCleanup:YES];
}

@end
