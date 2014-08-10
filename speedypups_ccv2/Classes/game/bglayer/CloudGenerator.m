#import "CloudGenerator.h"
#import "Resource.h"
#import "Common.h"
#import "FileCache.h"
#import "ObjectPool.h"


@implementation Cloud
@synthesize scaley;

-(BOOL)is_batched_sprite {
	return YES;
}
-(NSString*)get_batch_sprite_tex_key {
	return TEX_BG2_CLOUDS_SS;
}
-(int)get_render_ord {
	return 0;
}

+(Cloud*)cons_pt:(CGPoint)pt sc:(float)sc scaley:(float)sy {
	int rnd = int_random(0, 5);
	NSString *tarcld;
	if (rnd == 0) {
		tarcld = @"cloud0";
	} else if (rnd == 1) {
		tarcld = @"cloud1";
	} else if (rnd == 2) {
		tarcld = @"cloud2";
	} else if (rnd == 3) {
		tarcld = @"cloud3";
	} else if (rnd == 4) {
		tarcld = @"cloud4";
	} else {
		tarcld = @"cloud5";
	}
	
	//TEX_CLOUD_SS
	//Cloud* b = [Cloud spriteWithTexture:[Resource get_tex:texkey] rect:[FileCache get_cgrect_from_plist:texkey idname:tarcld]];
	Cloud *b = [ObjectPool depool:[Cloud class]];
	//[b setTexture:[Resource get_tex:TEX_BG2_CLOUDS_SS]];
	//[b setTextureRect:[FileCache get_cgrect_from_plist:texkey idname:tarcld]];
	[b setDisplayFrame:[CCSpriteFrame frameWithTexture:[Resource get_tex:TEX_BG2_CLOUDS_SS] rect:[FileCache get_cgrect_from_plist:TEX_BG2_CLOUDS_SS idname:tarcld]]];
	
	b.scaley = sy;
	b.speedmult = 1;
	[b setPosition:ccp(pt.x*CC_CONTENT_SCALE_FACTOR(),pt.y*CC_CONTENT_SCALE_FACTOR())];
    [b setAnchorPoint:CGPointZero];
    [b csf_setScale:sc];
    [b calc_movspd:sc];
    return b;
}
-(void)calc_movspd:(float)sc {
    movspd = -((powf(sc, 1.3))*1.7 + 0.1) * 0.7;
}
-(void)update_dv:(CGPoint)dv {
    [self setPosition:CGPointAdd(self.position, ccp(movspd*self.speedmult,-dv.y*scaley))];
}
-(void)repool {
	if ([self class] == [Cloud class]) {
		[ObjectPool repool:self class:[Cloud class]];
	}
}
@end

@implementation CloudGenerator {
	BatchSpriteManager *cloud_holder;
}

+(CloudGenerator*)cons {
    CloudGenerator* c = [CloudGenerator node];
    [c cons];
    [c random_seed_clouds];
    return c;
}

-(void)setColor:(ccColor3B)color {
	[cloud_holder setColor:color];
}

-(void)cons {
    clouds = [[NSMutableArray alloc] init];
	[self setScale:1];
    nextct = 0;
	scaley = 0.003;
	speedmult = 1;
	generatespeed = 140;
	cloud_holder = [BatchSpriteManager cons:self];
}

-(void)set_scaley:(float)sy {
	scaley = sy;
}

-(CloudGenerator*)set_generate_speed:(int)spd {
	//generatespeed = spd; //trololol
	return self;
}

-(CloudGenerator*)set_speedmult:(float)spd {
	speedmult = spd;
	for (Cloud *c in clouds) {
		c.speedmult = speedmult;
	}
	return self;
}

-(void)update_posx:(float)posx posy:(float)posy {
    CGPoint dv = ccp(posx - prevx,posy - prevy);
    prevx = posx;
    prevy = posy;
    
    if (nextct <= 0) {
        [self generate_cloud];
		generatespeed = float_random(220, 400);
        nextct = generatespeed;
    }
    nextct-=[Common get_dt_Scale];
    
    
    NSMutableArray* toremove = [[NSMutableArray alloc] init];
    for (Cloud* c in clouds) {
        [c update_dv:dv];
        if (c.position.x < -150) {
            [toremove addObject:c];
        }
    }
    [clouds removeObjectsInArray:toremove];
    for (Cloud* tar in toremove) {
		[cloud_holder removeChild:tar cleanup:YES];
		[tar repool];
	}
}

-(void)random_seed_clouds {
	
	float x = 0;
	while (x < [Common screen_pctwid:2 pcthei:0].x) {
		Cloud* n = [self generate_cloud];
		[n setPosition:ccp(x,n.position.y)];
		x += float_random(20 * CC_CONTENT_SCALE_FACTOR(), 80 * CC_CONTENT_SCALE_FACTOR());
	}
}

-(Cloud*)generate_cloud {
    CGPoint pos = [Common screen_pctwid:1.2 pcthei:0.65];
    float scale = 0;
    if (alternator==0) {
        pos.y += float_random(20*CC_CONTENT_SCALE_FACTOR(), 65*CC_CONTENT_SCALE_FACTOR());
        scale = float_random(0.3, 0.7);
        alternator = 1;
    } else {
        pos.y += float_random(-20*CC_CONTENT_SCALE_FACTOR(), 30*CC_CONTENT_SCALE_FACTOR());
        scale = float_random(0.9, 1.2);
        alternator = 0;
    }
	pos.y /= CC_CONTENT_SCALE_FACTOR();
    
    Cloud* n = [Cloud cons_pt:pos sc:scale scaley:scaley];
    [n setColor:[self color]];
	n.speedmult = speedmult;
    [clouds addObject:n];
	[cloud_holder addChild:n];
	return n;
}

-(void)dealloc {
    for (Cloud* n in clouds) {
        [cloud_holder removeChild:n cleanup:YES];
		[n repool];
    }
    [clouds removeAllObjects];
}

@end
