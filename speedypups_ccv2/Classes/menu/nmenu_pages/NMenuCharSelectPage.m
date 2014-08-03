#import "NMenuCharSelectPage.h"
#import "MenuCommon.h"
#import "Player.h"
#import "UserInventory.h"
#import "AudioManager.h"

@implementation NMenuCharSelectPage

static NSMutableArray* _anim_table;

+(void)initialize {
    _anim_table = [NSMutableArray arrayWithObjects:
                   @"",TEX_DOG_RUN_1,TEX_DOG_RUN_2,TEX_DOG_RUN_3,TEX_DOG_RUN_4,TEX_DOG_RUN_5,TEX_DOG_RUN_6,TEX_DOG_RUN_7, nil];
}

+(NMenuCharSelectPage*)cons {
    return [NMenuCharSelectPage node];
}

-(CCAction*)cons_anim:(NSString*)tar {
    NSArray* frames = @[@"sit_0",@"sit_1",@"sit_2",@"sit_0",@"sit_1",@"sit_2",@"sit_0",@"sit_1",@"sit_2",@"sit_0",@"sit_1_blink",@"sit_2"];
    CCTexture2D *texture = [Resource get_tex:tar];
    NSMutableArray *animFrames = [NSMutableArray array];
    for (NSString* i in frames) {
        [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:i]]];
    }
    return [Common make_anim_frames:animFrames speed:0.2];
}

-(void)dog_spr_anim {
    [dog_spr stopAllActions];
    [dog_spr runAction:[self cons_anim:[_anim_table objectAtIndex:cur_dog]]];
}

-(id)init {
    self = [super init];
    [GEventDispatcher add_listener:self];
    
    cur_dog = 1;
    
    dog_spr = [CSF_CCSprite node];
    [self dog_spr_anim];
    [dog_spr setPosition:[Common screen_pctwid:0.5 pcthei:0.35]];
    [self addChild:dog_spr];
	
#define t_CHARSELMENU 123901
	[self addChild:[MenuCommon menu_item:TEX_NMENU_ITEMS id:@"nmenu_charselmenu" pos:[Common screen_pctwid:0.5 pcthei:0.75]] z:10 tag:t_CHARSELMENU];
    CCSprite *charselmenu = (CCSprite*)[self getChildByTag:t_CHARSELMENU];
	
    CCMenuItem *leftarrow = [MenuCommon item_from:TEX_NMENU_ITEMS
											 rect:@"nmenu_arrow_left"
											  tar:self
											  sel:@selector(arrow_left)
											  pos:[Common pct_of_obj:charselmenu pctx:0 pcty:-0.5]
							 ];
	[leftarrow setScale:1];
	
    CCMenuItem *rightarrow = [MenuCommon item_from:TEX_NMENU_ITEMS
											  rect:@"nmenu_arrow_right"
											   tar:self
											   sel:@selector(arrow_right)
											   pos:[Common pct_of_obj:charselmenu pctx:1 pcty:-0.5]
							  ];
	[rightarrow setScale:1];
	
    select = [MenuCommon item_from:TEX_NMENU_ITEMS
							  rect:@"nmenu_checkbutton"
							   tar:self
							   sel:@selector(select_char)
							   pos:[Common pct_of_obj:charselmenu pctx:1 pcty:0]
			  ];
	[select setScale:1];
	
    controlm = [CCMenu menuWithItems:leftarrow,rightarrow,select, nil];
    [controlm setPosition:CGPointZero];
    [charselmenu addChild:controlm z:1];
    
    spotlight = [MenuCommon menu_item:TEX_NMENU_ITEMS id:@"nmenu_spotlight" pos:[Common screen_pctwid:0.5 pcthei:0.55]];
    [self addChild:spotlight];
    
#define t_CURTAINS 12345
	[self addChild:[MenuCommon menu_item:TEX_NMENU_ITEMS id:@"nmenu_curtains" pos:[Common screen_pctwid:0.5 pcthei:0.95]] z:0 tag:t_CURTAINS];
    [[self getChildByTag:t_CURTAINS] setScaleX:[Common scale_from_default].x];
	
	
    nav_menu = [MenuCommon cons_common_nav_menu];
    [self addChild:nav_menu];
    
    available_disp = [CCSprite node];
    [charselmenu addChild:available_disp];
    [available_disp addChild:[[[Common cons_label_pos:[Common pct_of_obj:charselmenu pctx:0.08 pcty:0.6]
                                              color:ccc3(200,20,20)
                                           fontsize:13
                                                str:@"Name:"] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
    
    [available_disp addChild:[[[Common cons_label_pos:[Common pct_of_obj:charselmenu pctx:0.08 pcty:0.35]
                                              color:ccc3(200,20,20)
                                           fontsize:13
                                                str:@"Ability:"] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
    
    name_disp = [[[Common cons_label_pos:[Common pct_of_obj:charselmenu pctx:0.225 pcty:0.55]
                                 color:ccc3(0,0,0)
                              fontsize:20
                                    str:@"nom"] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
    power_disp = [[[Common cons_label_pos:[Common pct_of_obj:charselmenu pctx:0.275 pcty:0.3]
                                   color:ccc3(0,0,0)
                                fontsize:20
                                     str:@"power"] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
    [available_disp addChild:name_disp];
    [available_disp addChild:power_disp];
    
    locked_disp = [CCSprite node];
    [charselmenu addChild:locked_disp];
    [locked_disp addChild:[[Common cons_label_pos:[Common pct_of_obj:charselmenu pctx:0.5 pcty:0.4]
                                          color:ccc3(0,0,0)
                                       fontsize:19
                                             str:@"unlock me at the store!"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
    
    for(int i = 0; i < [_anim_table count]; i++) {
        if ([_anim_table[i] isEqualToString:[Player get_character]]) {
            cur_dog = i;
            break;
        }
    }
    [self refresh];
	
	charselfbutton_anim_scale = 1;
    
    return self;
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_MENU_INVENTORY) {
        [controlm setVisible:NO];
        
    } else if (e.type == GEVentType_MENU_CLOSE_INVENTORY) {
        [controlm setVisible:YES];
        
    } else if (e.type == GEventType_MENU_TICK) {
		charselfbutton_anim_scale = charselfbutton_anim_scale - (charselfbutton_anim_scale - 1)/3;
		CCMenuItem *charbtn = [MenuCommon nav_menu_get_charselbutton:nav_menu];
		[charbtn setScale:charselfbutton_anim_scale * CC_CONTENT_SCALE_FACTOR()];
		
	}
}

-(void)refresh {
    [self dog_spr_anim];
    if ([((NSString*)[_anim_table objectAtIndex:cur_dog]) isEqualToString:[Player get_character]]) {
        [spotlight setVisible:YES];
		[select setVisible:NO];
    } else {
        [spotlight setVisible:NO];
		[select setVisible:YES];
    }
	
	if ([UserInventory get_character_unlocked:[_anim_table objectAtIndex:cur_dog]]) {
        [available_disp setVisible:YES];
        [locked_disp setVisible:NO];
        [name_disp setString:[Player get_full_name:_anim_table[cur_dog]]];
        [power_disp setString: [Player get_power_desc:_anim_table[cur_dog]]];
		[dog_spr setColor:ccc3(255,255,255)];
		
		
	} else {
        [available_disp setVisible:NO];
        [locked_disp setVisible:YES];
        [dog_spr setColor:ccc3(0,0,0)];
		[select setVisible:NO];
	}
    
}

-(void)select_char {
    [Player set_character:_anim_table[cur_dog]];
    [GEventDispatcher push_event:[GEvent cons_type:GEventType_CHANGE_CURRENT_DOG]];
    [self refresh];
	charselfbutton_anim_scale = 3;
	[Player character_bark];
}

-(void)arrow_left {
    cur_dog--;
    if (cur_dog <= 0) {
        cur_dog = (int)[_anim_table count]-1;
    }
	[AudioManager playsfx:SFX_MENU_UP];
    [self refresh];
}

-(void)arrow_right {
    cur_dog++;
    if (cur_dog >= [_anim_table count]) {
        cur_dog = 1;
    }
	[AudioManager playsfx:SFX_MENU_UP];
    [self refresh];
}

-(void)dealloc {
	[self removeAllChildrenWithCleanup:YES];
}

@end
