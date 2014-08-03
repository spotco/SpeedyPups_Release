#import "MagnetItemEffect.h"
#import "FileCache.h"
#import "Resource.h"
#import "GEventDispatcher.h"
#import "GameEngineLayer.h"
#import "GameItemCommon.h"

@interface MagnetItemEffectParticle : CSF_CCSprite {
    CGPoint center;
    float radius,ctheta;
}
@end
@implementation MagnetItemEffectParticle

+(MagnetItemEffectParticle*)cons_center:(CGPoint)center radius:(float)radius phase:(float)phase {
    return [[MagnetItemEffectParticle spriteWithTexture:[Resource get_tex:TEX_ITEM_SS] rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"magnet"]] cons_center:center radius:radius phase:phase];
}

-(id)cons_center:(CGPoint)tcenter radius:(float)tradius phase:(float)tphase {
    [self csf_setScale:0.5];
    center = tcenter;
    radius = tradius;
    ctheta = tphase;
    [self update];
    return self;
}

-(void)update {
    ctheta+=0.1;
    [self setPosition:CGPointAdd(center, ccp(radius*cosf(ctheta), radius*sinf(ctheta)))];
}

@end

@implementation MagnetItemEffect

+(MagnetItemEffect*)cons {
    return [MagnetItemEffect node];
}

-(id)init {
    self = [super init];
	[self setScale:1];
    [GEventDispatcher add_listener:self];
    NSMutableArray* tparticles = [NSMutableArray array];
    for(float i = 0; i < M_PI*2; i+=M_PI/2) {
        //[tparticles addObject:[MagnetItemEffectParticle cons_center:CGPointZero radius:60 phase:i]];
        [tparticles addObject:[self conspt_center:CGPointZero radius:60 phase:i]];
        particles = tparticles;
    }
    
    for (MagnetItemEffectParticle *i in particles) {
        [self addChild:i];
    }
    active = YES;
    return self;
}

-(MagnetItemEffectParticle*)conspt_center:(CGPoint)center radius:(float)radius phase:(float)phase {
    return [MagnetItemEffectParticle cons_center:center radius:radius phase:phase];
}

-(void)check_should_render:(GameEngineLayer *)g {
    do_render = YES;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (kill) {
        [GEventDispatcher remove_listener:self];
        [g remove_gameobject:self];
        return;
    }
    
    [self setPosition:[player get_center]];
    for (MagnetItemEffectParticle *i in particles) {
        [i update];
    }
}

-(void)dispatch_event:(GEvent *)e {    
    if (e.type == GEventType_ITEM_DURATION_PCT && e.f1 == 0 && e.i1 == Item_Magnet) {
        kill = YES;
    }
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ABOVE_FG_ORD];
}

@end

@interface HeartItemEffectParticle : MagnetItemEffectParticle
+(HeartItemEffectParticle*)cons_center:(CGPoint)center radius:(float)radius phase:(float)phase;
@end

@implementation HeartItemEffectParticle : MagnetItemEffectParticle
+(HeartItemEffectParticle*)cons_center:(CGPoint)center radius:(float)radius phase:(float)phase {
    return [[MagnetItemEffectParticle spriteWithTexture:[Resource get_tex:TEX_ITEM_SS] rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"heart"]] cons_center:center radius:radius phase:phase];
}
@end


@implementation HeartItemEffect
+(HeartItemEffect*)cons {
    return [HeartItemEffect node];
}

-(MagnetItemEffectParticle*)conspt_center:(CGPoint)center radius:(float)radius phase:(float)phase {
    return [HeartItemEffectParticle cons_center:center radius:radius phase:phase];
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_ITEM_DURATION_PCT && e.f1 == 0 && e.i1 == Item_Heart) {
        kill = YES;
    }
}
@end



@interface ClockItemEffectParticle: MagnetItemEffectParticle
+(ClockItemEffectParticle*)cons_center:(CGPoint)center radius:(float)radius phase:(float)phase;
@end

@implementation ClockItemEffectParticle : MagnetItemEffectParticle
+(ClockItemEffectParticle*)cons_center:(CGPoint)center radius:(float)radius phase:(float)phase {
    return [[ClockItemEffectParticle spriteWithTexture:[Resource get_tex:TEX_ITEM_SS] rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"item_clock"]] cons_center:center radius:radius phase:phase];
}
@end

@implementation ClockItemEffect
+(ClockItemEffect*)cons {
    return [ClockItemEffect node];
}
-(MagnetItemEffectParticle*)conspt_center:(CGPoint)center radius:(float)radius phase:(float)phase {
    return [ClockItemEffectParticle cons_center:center radius:radius phase:phase];
}
-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_ITEM_DURATION_PCT && e.f1 == 0 && e.i1 == Item_Clock) {
        kill = YES;
    }
}
-(void)update:(Player *)player g:(GameEngineLayer *)g {
	[super update:player g:g];
	[self setVisible:[GameControlImplementation get_clockbutton_hold]];
}
@end