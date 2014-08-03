#import "MainMenuBGLayer.h"
#import "BackgroundObject.h"
#import "Common.h"
#import "CloudGenerator.h"

#import "WaveParticle.h"
#import "StreamParticle.h"

#define ORD_SKY 1
#define ORD_STARS 2
#define ORD_SUNANDMOON 3
#define ORD_CLOUDS 4
#define ORD_HILLS 5
#define ORD_PARTICLES 6
#define ORD_FG 7

@implementation MainMenuBGLayer
+(MainMenuBGLayer*)cons {
    MainMenuBGLayer* l = [MainMenuBGLayer node];
    return l;
}

-(id)init {
    self = [super init];
    
    [GEventDispatcher add_listener:self];
    
    sky = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_SKY] scrollspd_x:0 scrollspd_y:0];
    [Common scale_to_fit_screen_y:sky];
    [self addChild:sky z:ORD_SKY];
    
    starsbg = [StarsBackgroundObject cons];
    [self addChild:starsbg z:ORD_STARS];
    [starsbg setOpacity:0];
    
    clouds = [[[CloudGenerator cons_texkey:TEX_BG2_CLOUDS_SS scaley:0.003] set_speedmult:0.3] set_generate_speed:140];
	//[CloudGenerator cons];
    [self addChild:clouds z:ORD_CLOUDS];
    
    hills = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_LAYER_3] scrollspd_x:0.025 scrollspd_y:0.02];
    [self addChild:hills z:ORD_HILLS];
    
    
	fg = [CCSprite node];
	[fg setAnchorPoint:ccp(0,0)];
	
	[self cons_fg_tex:TEX_NMENU_BGS_0 pctwid:0];
	[self cons_fg_tex:TEX_NMENU_BGS_1 pctwid:1];
	[self cons_fg_tex:TEX_NMENU_BGS_2 pctwid:2];
	[self cons_fg_tex:TEX_NMENU_BGS_3 pctwid:3];
	
    [self addChild:fg z:ORD_FG];
    
    particles = [[NSMutableArray alloc] init];
    particles_tba = [[NSMutableArray alloc] init];
    
    time = [BGTimeManager cons];
    [self addChild:time z:ORD_SUNANDMOON];
    
    return self;
}

-(void)cons_fg_tex:(NSString*)tex_key pctwid:(float)pctwid {
	CCSprite *fg_t = [[CCSprite spriteWithTexture:[Resource get_tex:tex_key]] anchor_pt:ccp(0,0)];
	[fg_t setPosition:[Common screen_pctwid:pctwid pcthei:0]];
	[Common scale_to_fit_screen_x:fg_t];
	[Common scale_to_fit_screen_y:fg_t];
	[fg addChild:fg_t];
}

-(void)update {
    [clouds update_posx:3 posy:0];
    
    [self update_particles];
    [self push_added_particles];
    [time update_posx:0 posy:0];
    
    if (arc4random_uniform(35) == 0) {
        [self add_particle:[WaveParticle cons_x:[Common SCREEN].width y:float_random(200, 350) vx:float_random(-2, -5) vtheta:float_random(0.01, 0.075)]];
    }
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_DAY_NIGHT_UPDATE) {
        [self set_day_night_color:e.i1];
        
    } else if (e.type == GEventType_MENU_MAKERUNPARTICLE) {
        [self add_particle:[StreamParticle cons_x:e.pt.x y:e.pt.y vx:e.f1 vy:e.f2]];
        
    } else if (e.type == GEventType_MENU_SCROLLBGUP_PCT) {
        [self scrollup_bg_pct:e.f1];
        
    }
}

-(void)scrollup_bg_pct:(float)pct {
    [clouds setPosition:ccp(clouds.position.x,-400*pct)];
    [hills setPosition:ccp(hills.position.x,-400*pct)];
    [fg setPosition:ccp(fg.position.x,-400*pct)];
}

//copied code from gamelayer and bglayer lol
-(void)set_day_night_color:(int)val {
    float pctm = ((float)val) / 100;
    [sky setColor:ccc3(pb(20,pctm),pb(20,pctm),pb(60,pctm))];
    [clouds setColor:ccc3(pb(150,pctm),pb(150,pctm),pb(190,pctm))];
    [hills setColor:ccc3(pb(50,pctm),pb(50,pctm),pb(90,pctm))];
    [starsbg setOpacity:255-pctm*255];
}


-(void)add_particle:(Particle*)p { [particles_tba addObject:p];}
-(void)push_added_particles {
    for (Particle *p in particles_tba) {
        [particles addObject:p];
        int ord = [p class]==[WaveParticle class]?ORD_PARTICLES:ORD_FG;
        [self addChild:p z:ord];
    }
    [particles_tba removeAllObjects];
}
-(void)update_particles {
    NSMutableArray *toremove = [NSMutableArray array];
    for (Particle *i in particles) {
        [i update:NULL];
        if ([i should_remove]) {
            [self removeChild:i cleanup:YES];
            [toremove addObject:i];
			[i repool];
        }
    }
    [particles removeObjectsInArray:toremove];
}
-(void)dealloc {
	for (Particle *i in particles) {
		[self removeChild:i cleanup:YES];
		[i repool];
	}
	[particles removeAllObjects];
}

-(void)move_fg:(CGPoint)pt { [fg setPosition:pt]; }
-(CGPoint)get_fg_pos{ return fg.position; }

@end

