#import "Resource.h"
#import "BackgroundObject.h"
#import "Common.h"

@implementation BackgroundObject
@synthesize scrollspd_x, scrollspd_y;

+(BackgroundObject*) backgroundFromTex:(CCTexture2D *)tex scrollspd_x:(float)spdx scrollspd_y:(float)spdy {
	
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_CLAMP_TO_EDGE};
    [tex setTexParameters:&par];
	
    BackgroundObject *bg = [[BackgroundObject spriteWithTexture:tex] cons];
    bg.scrollspd_x = spdx;
    bg.scrollspd_y = spdy;
	
	[bg setPosition:CGPointZero];
	[bg setAnchorPoint:CGPointZero];
	[bg setScaleX:[Common scale_from_default].x];
	[bg setScaleY:[Common scale_from_default].y];
	
    return bg;
}

-(id)cons {
	clamp_y_min = -600;
	clamp_y_max = 0;
	return self;
}

-(BackgroundObject*)set_clamp_y_min:(float)min max:(float)max {
	clamp_y_min = min;
	clamp_y_max = max;
	return self;
}

-(void)update_posx:(float)posx posy:(float)posy {
	float xpos = ((int)(posx*scrollspd_x))%self.texture.pixelsWide + ((posx*scrollspd_x) - ((int)(posx*scrollspd_x)));
	
    [self setTextureRect:CGRectMake(
		xpos,
		0,
		[Common SCREEN].width,
		[self textureRect].size.height
	)];
	
	self.position = ccp(0,clampf(-posy*scrollspd_y, clamp_y_min, clamp_y_max));
}

@end

@implementation StarsBackgroundObject

+(StarsBackgroundObject*)cons {
	return [StarsBackgroundObject node];
}

-(id)init {
	self = [super init];
	[self setTexture:[Resource get_tex:TEX_BG_STARS]];
	[self setTextureRect:CGRectMake(0, 0, [self texture].contentSize.width, [self texture].contentSize.height)];
	[self setScale:[Common scale_from_default].x];
	[self setAnchorPoint:ccp(0,1)];
	[self setPosition:[Common screen_pctwid:0 pcthei:1]];
	return self;
}

-(void)update_posx:(float)posx posy:(float)posy {}

@end
