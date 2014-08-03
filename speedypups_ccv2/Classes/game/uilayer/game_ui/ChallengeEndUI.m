#import "ChallengeEndUI.h"
#import "cocos2d.h" 
#import "Resource.h"
#import "FileCache.h" 
#import "MenuCommon.h"
#import "UILayer.h"
#import "UserInventory.h" 
#import "GameModeCallback.h"
#import "FireworksParticleA.h"
#import "UICommon.h"

@implementation ChallengeEndUI

+(ChallengeEndUI*)cons {
    return [ChallengeEndUI node];
}

-(id)init {
    self = [super init];
    
    ccColor4B c = {50,50,50,220};
    CGSize s = [[UIScreen mainScreen] bounds].size;
    CCNode *complete_ui = [CCLayerColor layerWithColor:c width:s.height height:s.width];
	
	curtains = [MenuCurtains cons];
	[complete_ui addChild:curtains];
	
	
    complete_ui.anchorPoint = ccp(0,0);
    [complete_ui setPosition:ccp(0,0)];
    
    wlicon = [[CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
                                     rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"challengecomplete"]]
              pos:[Common screen_pctwid:0.5 pcthei:0.8]];
    [complete_ui addChild:wlicon];
    
    CCSprite *infopane = [[CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
                                                 rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"challengeinfo"]]
                          pos:[Common screen_pctwid:0.5 pcthei:0.4]];
    
    CCLabelTTF *l = [[Common cons_label_pos:ccp(220/CC_CONTENT_SCALE_FACTOR(),82/CC_CONTENT_SCALE_FACTOR()) color:ccc3(0,0,0) fontsize:15 str:@"Collected"]  set_scale:1/CC_CONTENT_SCALE_FACTOR()];
    [l setAnchorPoint:ccp(1,0.5)];
    [infopane addChild:l];
    
    bone_disp = [[Common cons_label_pos:ccp(245/CC_CONTENT_SCALE_FACTOR(),85/CC_CONTENT_SCALE_FACTOR()) color:ccc3(220,10,10) fontsize:15 str:@"0"] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
    [bone_disp setAnchorPoint:ccp(0,0.5)];
    [infopane addChild:bone_disp];
    
    l = [[Common cons_label_pos:ccp(220/CC_CONTENT_SCALE_FACTOR(),58/CC_CONTENT_SCALE_FACTOR()) color:ccc3(0,0,0) fontsize:15 str:@"Time"] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
    [l setAnchorPoint:ccp(1,0.5)];
    [infopane addChild:l];
    
    time_disp = [[Common cons_label_pos:ccp(230/CC_CONTENT_SCALE_FACTOR(),60/CC_CONTENT_SCALE_FACTOR()) color:ccc3(220,10,10) fontsize:15 str:@"0:00"] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
    [time_disp setAnchorPoint:ccp(0,0.5)];
    [infopane addChild:time_disp];
    
    l = [[Common cons_label_pos:ccp(220/CC_CONTENT_SCALE_FACTOR(),37/CC_CONTENT_SCALE_FACTOR()) color:ccc3(0,0,0) fontsize:15 str:@"Secrets"] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
    [l setAnchorPoint:ccp(1,0.5)];
    [infopane addChild:l];
    
    secrets_disp = [[Common cons_label_pos:ccp(230/CC_CONTENT_SCALE_FACTOR(),37/CC_CONTENT_SCALE_FACTOR()) color:ccc3(220,10,10) fontsize:15 str:@"0"] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
    [secrets_disp setAnchorPoint:ccp(0,0.5)];
    [infopane addChild:secrets_disp];
    
    NSString* maxstr = @"aaaaaaaaaaaaaaaaaa\naaaaaaaaaaaaaaaaaa\naaaaaaaaaaaaaaaaaa";
    CGSize actualSize = [maxstr sizeWithFont:[UIFont fontWithName:@"Carton Six" size:15]
                           constrainedToSize:CGSizeMake(1000, 1000)
                               lineBreakMode:(NSLineBreakMode)UILineBreakModeWordWrap];
    
    infodesc = [[CCLabelTTF labelWithString:@"Some challenge eh"
                                dimensions:actualSize
                                 alignment:UITextAlignmentLeft
                                  fontName:@"Carton Six"
                                  fontSize:13] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
    [infodesc setColor:ccc3(40,40,40)];
    [infodesc setAnchorPoint:ccp(0,0.5)];
    [infodesc setPosition:ccp(10/CC_CONTENT_SCALE_FACTOR(),67.5/CC_CONTENT_SCALE_FACTOR())];
    [infopane addChild:infodesc];
    
    maxstr = @"aaaaaaaa\naaaaaaaa\naaaaaaaa";
    actualSize = [maxstr sizeWithFont:[UIFont fontWithName:@"Carton Six" size:25]
                           constrainedToSize:CGSizeMake(1000, 1000)
                               lineBreakMode:(NSLineBreakMode)UILineBreakModeWordWrap];
    
    reward_disp = [CCLabelTTF labelWithString:@""
                                dimensions:actualSize
                                 alignment:UITextAlignmentLeft
                                  fontName:@"Carton Six"
                                  fontSize:25];
    [reward_disp setColor:ccc3(220,220,200)];
    [reward_disp setAnchorPoint:ccp(0,1)];
    [reward_disp setPosition:[Common screen_pctwid:0.05 pcthei:0.95]];
    [complete_ui addChild:reward_disp];
    
    
    CCMenuItem *backbutton = [MenuCommon item_from:TEX_UI_INGAMEUI_SS rect:@"homebutton" tar:self sel:@selector(exit_to_menu)
                                               pos:[Common screen_pctwid:0.3 pcthei:0.135]];
    
    CCMenuItem *retrybutton = [MenuCommon item_from:TEX_UI_INGAMEUI_SS rect:@"retrybutton" tar:self sel:@selector(retry)
                                                pos:[Common screen_pctwid:0.5 pcthei:0.135]];
	
	nextbutton = [MenuCommon item_from:TEX_UI_INGAMEUI_SS rect:@"nextbutton" tar:self sel:@selector(next)
                                                pos:[Common screen_pctwid:0.7 pcthei:0.135]];
				
	[UICommon button:backbutton add_desctext:@"to menu" color:ccc3(255,255,255) fntsz:13];
	[UICommon button:retrybutton add_desctext:@"retry" color:ccc3(255,255,255) fntsz:13];
	[UICommon button:nextbutton add_desctext:@"next" color:ccc3(255,255,255) fntsz:13];
				
    [nextbutton setVisible:NO];
    CCMenu *m = [CCMenu menuWithItems:backbutton,retrybutton,nextbutton, nil];
    [m setPosition:CGPointZero];
    [complete_ui addChild:m z:1];
    
    [complete_ui addChild:infopane z:1];
    [self addChild:complete_ui];
	
	particleholder = [[CCSprite node] pos:CGPointZero];
	[complete_ui addChild:particleholder];
	particles = [NSMutableArray array];
    particles_tba = [NSMutableArray array];
	
	[self start_update];
	
    return self;
}



-(void)setVisible:(BOOL)visible {
	if (visible) {
		[curtains set_curtain_animstart_positions];
		[AudioManager bgm_stop];
		if (sto_passed) {
			[Player character_bark];
			[AudioManager playsfx:SFX_FANFARE_WIN after_do:[Common cons_callback:(NSObject*)[AudioManager class] sel:@selector(play_jingle)]];
		} else {
			[AudioManager playsfx:SFX_WHIMPER];
			[AudioManager playsfx:SFX_FANFARE_LOSE after_do:[Common cons_callback:(NSObject*)[AudioManager class] sel:@selector(play_jingle)]];
		}
	}
	[super setVisible:visible];
}

-(void)update_passed:(BOOL)p info:(ChallengeInfo*)ci bones:(NSString*)bones time:(NSString*)time secrets:(NSString*)secrets {
	[wlicon setTextureRect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:p?@"challengecomplete":@"challengefailed"]];
    [infodesc setString:[ci to_string]];
    [bone_disp setString:bones];
    [time_disp setString:time];
    [secrets_disp setString:secrets];
    
    curchallenge = [ChallengeRecord get_number_for_challenge:ci];
    if (p == YES && ![ChallengeRecord get_beaten_challenge:curchallenge]) {
        [ChallengeRecord set_beaten_challenge:curchallenge to:YES];
        [UserInventory add_coins:ci.reward];
        [reward_disp setString:[NSString stringWithFormat:@"Earned %d coin%@!",ci.reward,ci.reward == 1 ?@"":@"s"]];
    }
	
	if ([ChallengeRecord get_beaten_challenge:curchallenge] &&
		curchallenge + 1 < [ChallengeRecord get_num_challenges]
		) {
		[nextbutton setVisible:YES];
	}
	
	sto_passed = p;
}

-(BOOL)get_sto_passed {
	return sto_passed;
}

-(void)start_update {
	if (!has_scheduler) {
		[self schedule:@selector(update_particles)];
		has_scheduler = YES;
	}
}

-(void)end_update {
	if (has_scheduler) {
		[self unschedule:@selector(update_particles)];
		has_scheduler = NO;
	}
}

-(void)next {
	if (curchallenge+1<[ChallengeRecord get_num_challenges]) {
		[self end_update];
		[(UILayer*)[self parent] run_cb:[GameModeCallback cons_mode:GameMode_CHALLENGE n:curchallenge+1]];
	}
}

-(void)retry {
	[self end_update];
    [(UILayer*)[self parent] retry];
}

-(void)exit_to_menu {
	[self end_update];
    [(UILayer*)[self parent] exit_to_menu];
}

static int delayfwct;
-(void)start_fireworks_effect {	
	[self add_firework_at_xpct:0.15];
	[self add_firework_at_xpct:0.85];
	delayfwct = 0;
}
-(void)add_firework_at_xpct:(float)xpct {
	[self add_particle:[FireworksParticleA cons_x:[Common SCREEN].width*xpct + float_random(-50, 50)
												y:0
											   vx:0
											   vy:float_random(9,14)
											   ct:arc4random_uniform(8)+17]];
}
-(void)add_particle:(Particle*)p {
    [particles_tba addObject:p];
}
-(int)get_num_particles {
    return (int)[particles count];
}
-(void)push_added_particles {
    for (Particle *p in particles_tba) {
        [particles addObject:p];
        [particleholder addChild:p z:[p get_render_ord]];
    }
    [particles_tba removeAllObjects];
}
-(void)update_particles {
	delayfwct++;
	
	[curtains update];
	
	if (!sto_passed) return;
	
	if (delayfwct==10) {
		[self add_firework_at_xpct:0.15];
	} else if (delayfwct == 17) {
		[self add_firework_at_xpct:0.85];
	} else if (delayfwct == 23) {
		[self add_firework_at_xpct:0.15];
	} else if (delayfwct == 29) {
		[self add_firework_at_xpct:0.85];
	}
	[self push_added_particles];
    NSMutableArray *toremove = [NSMutableArray array];
    for (Particle *i in particles) {
        [i update:(id)self]; //don't do this at home
        if ([i should_remove]) {
            [particleholder removeChild:i cleanup:YES];
            [toremove addObject:i];
			[i repool];
        }
    }
    [particles removeObjectsInArray:toremove];
}

-(void)dealloc {
	for (Particle *p in particles) {
		[particleholder removeChild:p cleanup:YES];
		[p repool];
	}
	[particles removeAllObjects];
}

@end
