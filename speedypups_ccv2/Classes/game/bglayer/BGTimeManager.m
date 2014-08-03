#import "BGTimeManager.h"
#import "Resource.h" 
#import "Common.h"
#import "GEventDispatcher.h" 
#import "AudioManager.h"

@implementation BGTimeManager

+(BGTimeManager*)cons {
    BGTimeManager* b = [BGTimeManager node];
    [b cons];
    return b;
}

#define SUN_X_PCT 0.77
#define SUN_Y_PCT 0.81

//0 night, 100 day
#define DAYNIGHT_LENGTH 10000
#define TRANSITION_LENGTH 600

//#define DAYNIGHT_LENGTH 50
//#define TRANSITION_LENGTH 100

static int bgtime_delayct;
static BGTimeManagerMode bgtime_curmode;

+(BGTimeManagerMode)get_global_time {
	return bgtime_curmode;
}

+(void)initialize {
	bgtime_delayct = DAYNIGHT_LENGTH;
	bgtime_curmode = MODE_DAY;
}

-(void)cons {
    [self setPosition:CGPointZero];
    [self setAnchorPoint:CGPointZero];
	[self setScale:1];
    
    sun = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_SUN]];
    [sun setPosition:[Common screen_pctwid:SUN_X_PCT pcthei:SUN_Y_PCT]];
    
    moon = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_MOON]];
    [moon setPosition:[Common screen_pctwid:SUN_X_PCT pcthei:SUN_Y_PCT+1]];
	
    [self update_posx:0 posy:0];
	
	if (bgtime_curmode == MODE_DAY) {
		[GEventDispatcher push_event:[[GEvent cons_type:GEventType_DAY_NIGHT_UPDATE] add_i1:100 i2:0]];
		
	} else if (bgtime_curmode == MODE_NIGHT) {
		[GEventDispatcher push_event:[[GEvent cons_type:GEventType_DAY_NIGHT_UPDATE] add_i1:0 i2:0]];
        [AudioManager transition_mode2];
		
	} else if (bgtime_curmode == MODE_DAY_TO_NIGHT) {
        int pctval = (((float)bgtime_delayct)/TRANSITION_LENGTH)*100;
        [GEventDispatcher push_event:[[GEvent cons_type:GEventType_DAY_NIGHT_UPDATE] add_i1:pctval i2:0]];
		
	} else if (bgtime_curmode == MODE_NIGHT_TO_DAY) {
		int pctval = (1-((float)bgtime_delayct)/TRANSITION_LENGTH)*100;
		[GEventDispatcher push_event:[[GEvent cons_type:GEventType_DAY_NIGHT_UPDATE] add_i1:pctval i2:0]];
		
	}

    [self addChild:sun];
    [self addChild:moon];
	
	
}

#define cons_daynight_event(x) [GEventDispatcher push_event:[[GEvent cons_type:GEventType_DAY_NIGHT_UPDATE] add_i1:x i2:0]];
//#define cons_daynight_event(x) [GEventDispatcher push_event:[[GEvent cons_type:GEventType_DAY_NIGHT_UPDATE] add_i1:0 i2:0]];


//0 night, 100 day
-(void)update_posx:(float)posx posy:(float)posy {
    bgtime_delayct--;
    if (bgtime_curmode == MODE_DAY) {
		[sun setPosition:[Common screen_pctwid:SUN_X_PCT pcthei:SUN_Y_PCT]];
        [moon setPosition:[Common screen_pctwid:SUN_X_PCT pcthei:SUN_Y_PCT+1]];
		[sun setVisible:YES];
		[moon setVisible:NO];
		
        cons_daynight_event(100);
		
		if (bgtime_delayct <= 0) {
            bgtime_curmode = MODE_DAY_TO_NIGHT;
            bgtime_delayct = TRANSITION_LENGTH;
        }
        
    } else if (bgtime_curmode == MODE_DAY_TO_NIGHT) {
        int pctval = (((float)bgtime_delayct)/TRANSITION_LENGTH)*100;
        float fpctval = (((float)bgtime_delayct)/TRANSITION_LENGTH)*100;
		[sun setVisible:YES];
		[moon setVisible:YES];
		
		cons_daynight_event(pctval);
		
        [sun setPosition:[Common screen_pctwid:SUN_X_PCT pcthei:SUN_Y_PCT-((100-fpctval)/100.0)]];
        [moon setPosition:[Common screen_pctwid:SUN_X_PCT pcthei:SUN_Y_PCT+(fpctval/100.0)]];
        
		if (bgtime_delayct == TRANSITION_LENGTH/2) {
			[AudioManager transition_mode2];
		}
		
        if (bgtime_delayct <= 0) {
            bgtime_curmode = MODE_NIGHT;
            bgtime_delayct = DAYNIGHT_LENGTH;
        }
        
    } else if (bgtime_curmode == MODE_NIGHT) {
		[sun setPosition:[Common screen_pctwid:SUN_X_PCT pcthei:SUN_Y_PCT-1]];
        [moon setPosition:[Common screen_pctwid:SUN_X_PCT pcthei:SUN_Y_PCT]];
		[sun setVisible:NO];
		[moon setVisible:YES];
		
		cons_daynight_event(0);
		
        if (bgtime_delayct <= 0) {
            bgtime_curmode = MODE_NIGHT_TO_DAY;
            bgtime_delayct = TRANSITION_LENGTH;
        }
        
    } else if (bgtime_curmode == MODE_NIGHT_TO_DAY) {
        int pctval = (1-((float)bgtime_delayct)/TRANSITION_LENGTH)*100;
        float fpctval = (1-((float)bgtime_delayct)/TRANSITION_LENGTH)*100;
		[sun setVisible:YES];
		[moon setVisible:YES];
        
        cons_daynight_event(pctval);
		
		[sun setPosition:[Common screen_pctwid:SUN_X_PCT pcthei:((fpctval)/100.0)*SUN_Y_PCT]];
        [moon setPosition:[Common screen_pctwid:SUN_X_PCT pcthei:SUN_Y_PCT+(fpctval/100.0)]];
        
		if (bgtime_delayct == TRANSITION_LENGTH/2) {
            [AudioManager transition_mode1];
		}
		
        if (bgtime_delayct <= 0) {
            bgtime_curmode = MODE_DAY;
            bgtime_delayct = DAYNIGHT_LENGTH;
        }
        
    }
    
}

@end
