#import "LabBGObject.h"
#import "Resource.h"
#import "Common.h"

@implementation LabBGObject

+(LabBGObject*)cons {
    LabBGObject* bg = [LabBGObject spriteWithTexture:[Resource get_tex:TEX_LAB_BG]];
    bg.scrollspd_x = 0.07;
    bg.scrollspd_y = 0.0;
    bg.anchorPoint = CGPointZero;
    bg.position = CGPointZero;
    ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [bg.texture setTexParameters:&par];
    return bg;
}

-(void)update_posx:(float)posx posy:(float)posy {
	float xpos = ((int)(posx*scrollspd_x))%self.texture.pixelsWide + ((posx*scrollspd_x) - ((int)(posx*scrollspd_x)));
	
    [self setTextureRect:CGRectMake(
		xpos,
		0,
		[Common SCREEN].width,
		[Common SCREEN].height
	)];
}

@end
