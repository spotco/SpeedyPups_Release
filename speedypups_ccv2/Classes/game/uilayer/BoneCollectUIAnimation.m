#import "FileCache.h"
#import "BoneCollectUIAnimation.h"
#import "ObjectPool.h"

@implementation BoneCollectUIAnimation

+(BoneCollectUIAnimation*)cons_start:(CGPoint)start end:(CGPoint)end {
    BoneCollectUIAnimation *b = [ObjectPool depool:[BoneCollectUIAnimation class]];
	[b cons_start:start end:end];
    return b;
}

-(void)cons_start:(CGPoint)tstart end:(CGPoint)tend {
	[self setTexture:[Resource get_tex:TEX_ITEM_SS]];
	[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"goldenbone"]];
	[self setOpacity:255];
	[self csf_setScale:1];
	
    start = tstart;
    end = tend;
    [self setPosition:start];
	[self set_ctmax:50];
}

-(void)repool {
	if ([self class] == [BoneCollectUIAnimation class]) [ObjectPool repool:self class:[BoneCollectUIAnimation class]];
}

-(id)set_ctmax:(int)ctm {
	CTMAX = ctm;
	ct = CTMAX;
	return self;
}

-(void)update {
    float pct = (CTMAX - ((float)ct))/CTMAX;
    CGPoint tar = ccp((end.x - start.x)*pct + start.x, (end.y-start.y)*pct + start.y);
    [self setPosition:tar];
    [self setOpacity:((int)((1-pct)*255))];
    float tarscale = 2;
    if (ct > 35) {
        tarscale = ((15-(ct-35))/15.0)+1;
    } else {
        tarscale = 2*ct/35.0;
    }
    [self csf_setScale:tarscale];
    ct-=[Common get_dt_Scale];
}
@end

@implementation TreatCollectUIAnimation
#define CTMAX 50
+(TreatCollectUIAnimation*)cons_start:(CGPoint)start end:(CGPoint)end {
    return [[TreatCollectUIAnimation node] init_start:start end:end];
}

-(id)init_start:(CGPoint)tstart end:(CGPoint)tend {
    start = tstart;
    end = tend;
    ct = CTMAX;
    [self setTexture:[Resource get_tex:TEX_ITEM_SS]];
	[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"treat"]];
	[self set_ctmax:CTMAX];
    [self setPosition:tstart];
    return self;
}
@end

@implementation BoneCollectUIAnimation_Particle {
	BoneCollectUIAnimation *inner;
}

+(BoneCollectUIAnimation_Particle*)cons_start:(CGPoint)start end:(CGPoint)end {
	return [[BoneCollectUIAnimation_Particle node] pcons_start:start end:end];
}

-(BoneCollectUIAnimation_Particle*)set_texture:(CCTexture2D*)tex rect:(CGRect)rect {
	[inner setTexture:tex];
	[inner setTextureRect:rect];
	return self;
}

-(id)pcons_start:(CGPoint)start end:(CGPoint)end {
	inner = [TreatCollectUIAnimation cons_start:start end:end];
	[self addChild:inner];
	[self setScale:1/CC_CONTENT_SCALE_FACTOR()];
	return self;
}

-(void)update:(GameEngineLayer *)g {
	[inner update];
}

-(BOOL)should_remove {
	return inner.ct <= 0;
}
@end
