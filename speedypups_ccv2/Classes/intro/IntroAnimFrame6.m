#import "IntroAnimFrame6.h"
#import "Resource.h"
#import "FileCache.h"
#import "RepeatFillSprite.h"
#import "BackgroundObject.h"
#import "CloudGenerator.h"
#import "AudioManager.h"

@interface CCSprite_SetChildOpacity : CCSprite
@end
@implementation CCSprite_SetChildOpacity
-(void)setOpacity:(GLubyte)opacity {
	[super setOpacity:opacity];
	for(CCSprite *sprite in [self children]) {
		sprite.opacity = opacity;
	}
}
@end

@interface DogSprite : CSF_CCSprite {
	CCAction __unsafe_unretained *run;
	CCAction __unsafe_unretained *jump;
	CCAction __unsafe_unretained *current;
	float vy;
}
@property(readwrite,assign) float ct;
@property(readwrite,strong) CCSprite *shadow, *shadowbody;
@property(readwrite,strong) CCSprite *body;
@end
@implementation DogSprite
@synthesize shadow,body,shadowbody;
@synthesize ct;
-(id)init {
	self = [super init];
	vy = 0;
	shadow = [CCSprite node];
	shadowbody = [CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
														  rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame6_shadow"]];
	[shadowbody setScale:0.5];
	[shadowbody setOpacity:180];
	[shadow addChild:shadowbody];
	
	body = [CCSprite node];
	[body setAnchorPoint:ccp(0.5,0)];
	[self addChild:shadow];
	[self addChild:body];
	return self;
}
-(void)set_runanim:(CCAction *)_run jumpanim:(CCAction *)_jump {
	run = _run;
	jump = _jump;
	[body runAction:run];
	current = run;
}
-(void)anim_run {
	if (current != run) {
		[body stopAllActions];
		[body runAction:run];
	}
	current = run;
}
-(void)anim_jump {
	if (current != jump) {
		[body stopAllActions];
		[body runAction:jump];
	}
	current = jump;
}
-(void)go_to_pos:(CGPoint)pos div:(float)div {
	[self setPosition:ccp(self.position.x+(pos.x-self.position.x)/div,self.position.y)];
}
-(void)update {
	[body setPosition:ccp(body.position.x,body.position.y+vy*[Common get_dt_Scale])];
	vy -= 0.5 * [Common get_dt_Scale];
	if (body.position.y < 0) {
		[body setPosition:ccp(body.position.x,0)];
	}
	
	if (![self on_ground]) {
		[self anim_jump];
		
		Vec3D vdir_vec = [VecLib cons_x:30 y:vy z:0];
		[body setRotation:[VecLib get_rotation:vdir_vec offset:0]+180];
		float unconstr_sc = (150-body.position.y)/150;
		[shadow setScale:unconstr_sc >= 0 ? unconstr_sc : 0];
		
	} else {
		[self anim_run];
		[body setRotation:body.rotation/5];
		[shadow setScale:1];
	}
	

}
-(void)update_random_jump:(int)dog {
	if ([self on_ground]) {
		self.ct--;
		if (self.ct <= 0) {
			self.ct = int_random(0, 20);
			[self jump];
			if (dog == 1) {
				[AudioManager playsfx:SFX_BARK_LOW];
			} else if (dog == 2) {
				[AudioManager playsfx:SFX_BARK_HIGH];
			} else if (dog == 3) {
				[AudioManager playsfx:SFX_BARK_MID];
			}
		}
	}
}
-(void)jump {
	vy = 7;
	[AudioManager playsfx:SFX_JUMP];
}
-(BOOL)on_ground {
	return body.position.y <= 0;
}
@end

@implementation IntroAnimFrame6

+(IntroAnimFrame6*)cons {
	return [IntroAnimFrame6 node];
}

static float GROUNDHEI;

#define PHASE_RUNIN 0
#define PHASE_JUMPING_FLYOUT 1
#define PHASE_SCROLLUP 2
#define PHASE_LOGOIN 3

-(id)init {
	self = [super init];
	phase = PHASE_RUNIN;
	flags = [NSMutableDictionary dictionary];
    sky = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_SKY] scrollspd_x:0 scrollspd_y:0];
	[Common scale_to_fit_screen_y:sky];
	clouds = [CloudGenerator cons];
	backhills = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_LAYER_3] scrollspd_x:0.025 scrollspd_y:0.1];
	[Common scale_to_fit_screen_y:backhills];
	fronthills = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_LAYER_1] scrollspd_x:0.1 scrollspd_y:0.15];
    [Common scale_to_fit_screen_y:fronthills];
	
    [self addChild:sky];
	[self addChild:clouds];
    [self addChild:backhills];
    [self addChild:fronthills];
	
	scroll_pos = CGPointZero;
	
	GROUNDHEI = 50;
	
	ground = [RepeatFillSprite cons_tex:[Resource get_tex:TEX_INTRO_ANIM_SS]
								   rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame6_groundtex"]
									rep:6*CC_CONTENT_SCALE_FACTOR()];
	[ground setScale:1/(3-CC_CONTENT_SCALE_FACTOR())];
	[ground setPosition:ccp(0,GROUNDHEI+10)];
	[self addChild:ground];
	
	[self cons_anims];
	
	dog1 = [DogSprite node];
	[dog1 set_runanim:dog1_run jumpanim:dog1_jump];
	[dog1 setPosition:ccp(-100 * CC_CONTENT_SCALE_FACTOR(),GROUNDHEI)];
	[dog1.body setScale:0.7];
	[dog1.shadow setScale:1.1];
	[self addChild:dog1];
	
	
	dog2 = [DogSprite node];
	[dog2 set_runanim:dog2_run jumpanim:dog2_jump];
	[dog2 setPosition:ccp(-100 * CC_CONTENT_SCALE_FACTOR(),GROUNDHEI)];
	[dog2.body setScale:0.7];
	[dog2.shadow setScale:0.875];
	[self addChild:dog2];
	
	
	dog3 = [DogSprite node];
	[dog3 set_runanim:dog3_run jumpanim:dog3_jump];
	[dog3 setPosition:ccp(-100 * CC_CONTENT_SCALE_FACTOR(),GROUNDHEI)];
	[dog3.body setScale:0.7];
	[dog3.shadow setScale:0.925];
	[self addChild:dog3];
	 
	
	copter = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
									rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame4_cage"]];
	[copter setPosition:[Common screen_pctwid:0.6 pcthei:1.4]];
	[copter csf_setScale:0.8];
	[self addChild:copter];
	
	copter_shadow = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
										   rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame6_shadow"]];
	[copter_shadow setOpacity:180];
	[self update_copter_shadow];
	[self addChild:copter_shadow];
	
	dog1_tar_pos = dog1.position;
	dog2_tar_pos = dog2.position;
	dog3_tar_pos = dog3.position;
	copter_tar_pos = copter.position;
	
	ct = 0;
	
	logo_flyin = [CCSprite_SetChildOpacity node];
	[logo_flyin setPosition:[Common screen_pctwid:0.5 pcthei:0.7]];
	[self addChild:logo_flyin];
	
	logo_flyin_base = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
											  rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"logo_flyin_base"]];
	[logo_flyin addChild:logo_flyin_base];
	
	logo_flyin_circle = [CSF_CCSprite node];
	[logo_flyin_circle runAction:logoempty];
	[logo_flyin addChild:logo_flyin_circle];
	
	logo_flyin_pups = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
											 rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"logo_flyin_pups"]];
	[logo_flyin addChild:logo_flyin_pups];
	
	logo_flyin_speedy = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
											   rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"logo_flyin_speedy"]];
	[logo_flyin addChild:logo_flyin_speedy];
	
	[logo_flyin_circle setPosition:ccp(0,300)];
	[logo_flyin_pups setPosition:ccp(-500,0)];
	[logo_flyin_speedy setPosition:ccp(500,0)];
	
	[logo_flyin setOpacity:0];
	[logo_flyin setVisible:NO];
	
	ok_to_exit = NO;
	
	return self;
}

-(void)update_copter_shadow {
	[copter_shadow setPosition:ccp(copter.position.x-13,GROUNDHEI)];
	float unconstr_sc = (300-(copter.position.y-GROUNDHEI))/300;
	[copter_shadow csf_setScale:(unconstr_sc >= 0 ? unconstr_sc : 0)*2.2];
}

static int END_AT = 600;
#define DOG3_POS1 @1
#define DOG2_POS1 @2
#define DOG1_POS1 @3
#define COPTER_POS1 @4

#define COPTER_POS2 @5
#define DOG3_POS2 @6
#define DOG2_POS2 @7
#define DOG1_POS2 @8

#define SWAPPED_TO_ANIMATED_LOGO @9

#define SET_FLAG(x) [flags setObject:@1 forKey:x]
#define HAS_FLAG(x) [flags objectForKey:x]


-(void)update {
	ct+=[Common get_dt_Scale];
	[ground setPosition:ccp(((int)ground.position.x-5)%254,ground.position.y)];
	
	scroll_pos.x += 4 * [Common get_dt_Scale];
	[clouds update_posx:scroll_pos.x posy:scroll_pos.y];
	[backhills update_posx:scroll_pos.x posy:scroll_pos.y];
	[fronthills update_posx:scroll_pos.x posy:scroll_pos.y];
	
	[self update_copter_shadow];
	
	if (phase == PHASE_RUNIN) {
		[self update_phase_runin];
		
	} else if (phase == PHASE_JUMPING_FLYOUT) {
		[self update_phase_jumping_flyout];
		
	} else if (phase == PHASE_SCROLLUP) {
		[self update_phase_scrollup];
		
	} else if (phase == PHASE_LOGOIN) {
		[self update_phase_logo_in];
			
	}
	
	[dog1.shadowbody setOpacity:180];
	[dog2.shadowbody setOpacity:180];
	[dog3.shadowbody setOpacity:180];
	[copter_shadow setOpacity:180];
}

-(void)update_phase_logo_in {
	[logo_flyin setVisible:YES];
	if (logo_flyin.opacity < 255) {
		[logo_flyin setOpacity:logo_flyin.opacity < 255 ? logo_flyin.opacity + 15 : 255];
		
	} else if (![Common fuzzyeq_a:logo_flyin_speedy.position.x b:0 delta:0.1]) {
		[logo_flyin_circle setPosition:ccp(logo_flyin_circle.position.x+(25-logo_flyin_circle.position.x)/10,
										   logo_flyin_circle.position.y+(25-logo_flyin_circle.position.y)/10
		)];
		[logo_flyin_pups setPosition:ccp(logo_flyin_pups.position.x-logo_flyin_pups.position.x/10,
										 logo_flyin_pups.position.y-logo_flyin_pups.position.y/10
		)];
		[logo_flyin_speedy setPosition:ccp(
			logo_flyin_speedy.position.x-logo_flyin_speedy.position.x/10,
			logo_flyin_speedy.position.y-logo_flyin_speedy.position.y/10
		)];
	
	} else if (!HAS_FLAG(SWAPPED_TO_ANIMATED_LOGO)) {
		SET_FLAG(SWAPPED_TO_ANIMATED_LOGO);
		[AudioManager playsfx:SFX_BARK_MID];
		id reptrig = [CCCallFunc actionWithTarget:self selector:@selector(to_logo_jump)];
		[logo_flyin_circle stopAllActions];
		[logo_flyin_circle runAction:[CCSequence actions:logojump,reptrig, nil]];
		
	}
}

-(void)to_logo_jump {
	[logo_flyin_circle stopAllActions];
	[logo_flyin_circle runAction:logobounce];
	ok_to_exit = YES;
}

-(void)update_phase_scrollup {
	CGPoint mvdown = ccp(0,-5);
	for (CCSprite *s in @[dog1,dog2,dog3,ground]) {
		[s setPosition:CGPointAdd(s.position, mvdown)];
	}
	[dog1 on_ground] ? [dog1 go_to_pos:dog1_tar_pos div:65.0] : [dog1 update];
	[dog2 on_ground] ? [dog2 go_to_pos:dog2_tar_pos div:65.0] : [dog2 update];
	[dog3 on_ground] ? [dog3 go_to_pos:dog3_tar_pos div:65.0] : [dog3 update];

	scroll_pos.y += 50;
	[clouds setPosition:ccp(clouds.position.x,clouds.position.y-1)];
	
	if (ct > 400) {
		phase = PHASE_LOGOIN;
		logo_flyin.opacity = 0;
	}
}

-(void)update_phase_jumping_flyout {
	if (ct < 220) {
		[dog1 update_random_jump:1];
		[dog2 update_random_jump:2];
		[dog3 update_random_jump:3];
		
		[dog1 update];
		[dog2 update];
		[dog3 update];
		
	} else {
		[dog1 on_ground] ? [dog1 go_to_pos:dog1_tar_pos div:65.0] : [dog1 update];
		[dog2 on_ground] ? [dog2 go_to_pos:dog2_tar_pos div:65.0] : [dog2 update];
		[dog3 on_ground] ? [dog3 go_to_pos:dog3_tar_pos div:65.0] : [dog3 update];
	}
		
	if (ct >= 200 && !HAS_FLAG(COPTER_POS2)) {
		SET_FLAG(COPTER_POS2);
		copter_tar_pos = [Common screen_pctwid:1.5 pcthei:1.5];
		[AudioManager playsfx:SFX_COPTER_FLYBY];
		
	} else if (ct >= 220 && !HAS_FLAG(DOG3_POS2)) {
		SET_FLAG(DOG3_POS2);
		dog3_tar_pos = ccp([Common SCREEN].width*1.4,GROUNDHEI);
		
	} else if (ct >= 240 && !HAS_FLAG(DOG2_POS2)) {
		SET_FLAG(DOG2_POS2);
		dog2_tar_pos = ccp([Common SCREEN].width*1.4,GROUNDHEI);
		
	} else if (ct >= 260 && !HAS_FLAG(DOG1_POS2)) {
		SET_FLAG(DOG1_POS2);
		dog1_tar_pos = ccp([Common SCREEN].width*1.4,GROUNDHEI);
	}
	
	[copter setPosition:ccp(copter.position.x+(copter_tar_pos.x-copter.position.x)/15.0,copter.position.y+(copter_tar_pos.y-copter.position.y)/15.0)];
	
	if (ct >= 300) {
		phase = PHASE_SCROLLUP;
	}
}

-(void)update_phase_runin {
	if (ct >= 20 && !HAS_FLAG(DOG3_POS1)) {
		SET_FLAG(DOG3_POS1);
		dog3_tar_pos = ccp(190,GROUNDHEI);
		
	} else if (ct >= 40 && !HAS_FLAG(DOG2_POS1)) {
		SET_FLAG(DOG2_POS1);
		dog2_tar_pos = ccp(115,GROUNDHEI);
		
	} else if (ct > 60 && !HAS_FLAG(DOG1_POS1)) {
		SET_FLAG(DOG1_POS1);
		dog1_tar_pos = ccp(50,GROUNDHEI);
		
	} else if (ct > 80 && !HAS_FLAG(COPTER_POS1)) {
		SET_FLAG(COPTER_POS1);
		copter_tar_pos = [Common screen_pctwid:0.8 pcthei:0.7];
		[AudioManager playsfx:SFX_BOSS_ENTER];
		
	}
	
	[dog1 go_to_pos:dog1_tar_pos div:25.0];
	[dog2 go_to_pos:dog2_tar_pos div:25.0];
	[dog3 go_to_pos:dog3_tar_pos div:25.0];
	[copter setPosition:ccp(copter.position.x+(copter_tar_pos.x-copter.position.x)/15.0,copter.position.y+(copter_tar_pos.y-copter.position.y)/15.0)];
	if (ct > 100) {
		phase = PHASE_JUMPING_FLYOUT;
		dog1.ct = int_random(7, 20);
		dog2.ct = int_random(17, 30);
		dog3.ct = int_random(0, 15);
	}
}

-(BOOL)should_continue {
	return ct >= END_AT && ok_to_exit;
}

-(void)force_continue {
	ct = END_AT;
	ok_to_exit = YES;
}

-(void)cons_anims {
	dog3_run = [Common cons_anim:@[@"dog1_run_angry0",@"dog1_run_angry1",@"dog1_run_angry2",@"dog1_run_angry3"]
						   speed:0.11
						 tex_key:TEX_INTRO_ANIM_SS];
	dog2_run = [Common cons_anim:@[@"dog5_run_angry0",@"dog5_run_angry1",@"dog5_run_angry2",@"dog5_run_angry3"]
						   speed:0.09
						 tex_key:TEX_INTRO_ANIM_SS];
	
	dog1_run = [Common cons_anim:@[@"dog6_run_angry0",@"dog6_run_angry1",@"dog6_run_angry2",@"dog6_run_angry3"]
						   speed:0.1
						 tex_key:TEX_INTRO_ANIM_SS];
	
	dog3_jump = [Common cons_anim:@[@"dog1_run_angry0"] speed:0.1 tex_key:TEX_INTRO_ANIM_SS];
	dog2_jump = [Common cons_anim:@[@"dog5_run_angry0"] speed:0.1 tex_key:TEX_INTRO_ANIM_SS];
	dog1_jump = [Common cons_anim:@[@"dog6_run_angry0"] speed:0.1 tex_key:TEX_INTRO_ANIM_SS];
	
	logojump = [self cons_logojump_anim];
	logobounce = [self cons_logobounce_anim];
	logoempty = [self cons_logo_empty];
}

-(CCAnimate*)cons_logo_empty {
	NSString *tar = TEX_INTRO_ANIM_SS;
    CCTexture2D *texture = [Resource get_tex:tar];
    NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"logo_headcircle_0"]]];
	return [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:animFrames delay:0.1] restoreOriginalFrame:NO];
}

-(CCAnimate*)cons_logojump_anim {
	NSString *tar = TEX_INTRO_ANIM_SS;
    CCTexture2D *texture = [Resource get_tex:tar];
    NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"logo_headcircle_0"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"logo_headcircle_1"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"logo_headcircle_2"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"logo_headcircle_3"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"logo_headcircle_4"]]];
    return [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:animFrames delay:0.1] restoreOriginalFrame:NO];
}

-(CCAnimate*)cons_logobounce_anim {
    NSString *tar = TEX_INTRO_ANIM_SS;
    CCTexture2D *texture = [Resource get_tex:tar];
    NSMutableArray *animFrames = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"logo_headcircle_5"]]];
        [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"logo_headcircle_6"]]];
        [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"logo_headcircle_7"]]];
    }
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"logo_headcircle_8"]]];
    return [Common make_anim_frames:animFrames speed:0.15];
}
@end