#import "GameStartAnim.h"
#import "Resource.h"
#import "FileCache.h"
#import "AudioManager.h"
#import "Player.h"

@implementation GameStartAnim

+(GameStartAnim*)cons_with_callback:(CallBack*)cb {
    GameStartAnim *n = [GameStartAnim node];
    n.anim_complete = cb;
    [n cons_anim];
    [GEventDispatcher add_listener:n];
    return n;
}

static float ANIM_LENGTH = 75.0;

-(void)cons_anim {
    readyimg = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"READY"]];
    goimg = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"GO"]];
	
	
    [self addChild:readyimg];
    [self addChild:goimg];
    [self setPosition:ccp([[UIScreen mainScreen] bounds].size.height/2, [[UIScreen mainScreen] bounds].size.width/2)];
    
    [readyimg setOpacity:0];
    [goimg setOpacity:0];
	
	ANIM_LENGTH = 75.0 / [Common get_dt_Scale];
    
    ct = ANIM_LENGTH;
}

-(void)update {
    ct--;
    if (ct <= 0) {
        [self anim_finished];
        return;
    }
    
    if (ct > ANIM_LENGTH/2) {
        float o = ct-ANIM_LENGTH/2;
        o = (o/(ANIM_LENGTH/2))*200+55;
        
        [goimg setOpacity:0];
        [readyimg setOpacity:(int)o];
		
		if (!played_ready) {
			[AudioManager playsfx:SFX_READY];
			played_ready = YES;
		}
		
    } else {
        float o = ct;
        o = (o/(ANIM_LENGTH/2))*200+55;
        
        [readyimg setOpacity:0];
        [goimg setOpacity:(int)o];
		
		if (!played_go) {
			[AudioManager playsfx:SFX_GO];
			[Player character_bark];
			played_go = YES;
		}
    }
}

@end
