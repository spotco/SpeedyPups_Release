#import "TutorialAnim.h"
#import "Resource.h"
#import "FileCache.h"

@implementation TutorialAnim
#define NOSHOW ccp(0.1,0.1)

+(TutorialAnim*)cons_msg:(NSString*)msg {
    return [[TutorialAnim node]cons:msg];
}

-(id)cons:(NSString*)msg {
    body = [CCSprite node];
    hand = [CCSprite node];
    effect = [CCSprite node];
    nosign = [CCSprite node];
    
    if ([msg isEqualToString:@"doublejump"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"dbljump0",@"dbljump2" ,@"dbljump3" ,@"dbljump4",@"dbljump5",@"dbljump6",@"dbljump7",@"dbljump8",@"dbljump9",@"dbljump10",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""        ,@"jump"     ,@"jump"     ,@""        ,@""        ,@"jump"    ,@"jump"    ,@""        ,@""        ,@""         ,nil];
        CGPoint handframes[] =                            {ccp(0,0),ccp(0,0),ccp(0,0),ccp(-6,0)  ,ccp(-12,0)  ,ccp(-6,0)   ,ccp(0,0)   ,ccp(-6,0)  ,ccp(-12,0) ,ccp(-6,0)  ,ccp(0,0)   ,ccp(0,0)   ,ccp(0,0)    };
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW     ,NOSHOW      ,NOSHOW      ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW      };
        
        [body setPosition:ccp(0,15)];
        [effect setPosition:ccp(50,-50)];
        defaulthandpos = ccp(100,-100);
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_1];
        
    } else if ([msg isEqualToString:@"minionhit"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"minionhit0",@"minionhit1",@"minionhit2",@"minionhit3",@"minionhit4",@"minionhit5",@"minionhit6",@"minionhit7",@"minionhit7",@"minionhit7",@"minionhit7",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,nil];
        CGPoint handframes[] =                            {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW};
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,ccp(0,0)     ,ccp(0,0)     ,ccp(0,0)};
        
        [body setPosition:ccp(-20,-10)];
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_1];
        
    } else if ([msg isEqualToString:@"minionjump"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"minionjump0",@"minionjump1",@"minionjump2",@"minionjump3",@"minionjump4",@"minionjump5",@"minionjump6",@"minionjump7",@"minionjump8",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""           ,@""           ,@""           ,@"jump"       ,@"jump"       ,@""           ,@""          ,@""            ,@""           ,nil];
        CGPoint handframes[] =                            {ccp(0,0),ccp(0,0),ccp(0,0),ccp(0,0)      ,ccp(0,0)      ,ccp(-6,0)     ,ccp(-12,0)    ,ccp(-6,0)     ,ccp(0,0)      ,ccp(0,0)     ,ccp(0,0)        ,ccp(0,0)    };
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW        ,NOSHOW        ,NOSHOW        ,NOSHOW        ,NOSHOW        ,NOSHOW        ,NOSHOW       ,NOSHOW         ,NOSHOW      };
        
        [effect setPosition:ccp(50,-50)];
        [body setPosition:ccp(-20,-10)];
        defaulthandpos = ccp(100,-100);
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_1];
        
    } else if ([msg isEqualToString:@"rockbreak"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"rockbreak0",@"rockbreak1",@"rockbreak2"     ,@"rockbreak3"     ,@"rockbreak4"         ,@"rockbreak5"             ,@"rockbreak6",@"rockbreak7",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""          ,@""          ,@"swipestraight"  ,@"swipestraight"  ,@"swipestraight"      ,@"swipestraight"          ,@""         ,@""           ,nil];
        CGPoint handframes[] =                            {ccp(0,0),ccp(0,0),ccp(0,0),ccp(0,0)     ,ccp(0,0)     ,ccp(20,0)         ,ccp(50,0)         ,ccp(90,0)            ,ccp(160,0)                  ,ccp(0,0)    ,ccp(0,0)          };
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW      ,NOSHOW            };
        
        [effect setPosition:ccp(50,-50)];
        [body setPosition:ccp(-20,-10)];
        defaulthandpos = ccp(0,-100);
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_1];
    
	/*
    } else if ([msg isEqualToString:@"rockethit"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"rockethit0",@"rockethit1",@"rockethit2",@"rockethit3",@"rockethit4",@"rockethit5",@"rockethit6",@"rockethit7",@"rockethit7",@"rockethit7",@"rockethit7",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,nil];
        CGPoint handframes[] =                            {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW};
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,ccp(0,0)     ,ccp(0,0)     ,ccp(0,0)};
        
        [body setPosition:ccp(-20,-10)];
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_1];
        
    } else if ([msg isEqualToString:@"rocketjump"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"rocketjump5",@"rocketjump6",@"rocketjump7",@"rocketjump8",@"rocketjump9",@"rocketjump10",@"rocketjump11",@"rocketjump12",@"rocketjump13",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""           ,@""           ,@""           ,@"jump"       ,@"jump"       ,@""           ,@""          ,@""            ,@""           ,nil];
        CGPoint handframes[] =                            {ccp(0,0),ccp(0,0),ccp(0,0),ccp(0,0)      ,ccp(0,0)      ,ccp(-6,0)     ,ccp(-12,0)    ,ccp(-6,0)     ,ccp(0,0)      ,ccp(0,0)     ,ccp(0,0)        ,ccp(0,0)    };
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW        ,NOSHOW        ,NOSHOW        ,NOSHOW        ,NOSHOW        ,NOSHOW        ,NOSHOW       ,NOSHOW         ,NOSHOW      };
        
        [effect setPosition:ccp(50,-50)];
        [body setPosition:ccp(-20,-10)];
        defaulthandpos = ccp(100,-100);
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_1];
	*/
	 
    } else if ([msg isEqualToString:@"rockhit"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"rockhit0",@"rockhit1",@"rockhit2",@"rockhit3",@"rockhit4",@"rockhit5",@"rockhit6",@"rockhit7",@"rockhit7",@"rockhit7",@"rockhit7",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,nil];
        CGPoint handframes[] =                            {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW};
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,ccp(0,0)     ,ccp(0,0)     ,ccp(0,0)};
        
        [body setPosition:ccp(-20,-10)];
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_1];
        
    } else if ([msg isEqualToString:@"spikehit"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"spikehit0",@"spikehit1",@"spikehit2",@"spikehit3",@"spikehit4",@"spikehit5",@"spikehit6",@"spikehit7",@"spikehit7",@"spikehit7",@"spikehit7",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,nil];
        CGPoint handframes[] =                            {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW};
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,ccp(0,0)     ,ccp(0,0)     ,ccp(0,0)};
        
        [body setPosition:ccp(-20,-10)];
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_1];
        
    } else if ([msg isEqualToString:@"spikevine"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"spikevine0",@"spikevine1",@"spikevine2",@"spikevine3",@"spikevine4",@"spikevine5",@"spikevine6",@"spikevine7",@"spikevine7",@"spikevine7",@"spikevine7",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,nil];
        CGPoint handframes[] =                            {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW};
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,ccp(0,0)     ,ccp(0,0)     ,ccp(0,0)};
        
        [body setPosition:ccp(-20,-10)];
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_1];
    
	/*
    } else if ([msg isEqualToString:@"splash"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @"splash8"     ,@"splash8"     ,@"splash8"     ,@"splash0",@"splash1",@"splash2",@"splash3",@"splash4",@"splash5",@"splash6",@"splash7",@"splash8",@"splash8",@"splash8",@"splash8",@"splash8",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@"",@"",@""          ,@""          ,@""          ,nil];
        CGPoint handframes[] =                            {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW,NOSHOW,NOSHOW       ,NOSHOW       ,NOSHOW};
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW,NOSHOW,ccp(0,0)     ,ccp(0,0)     ,ccp(0,0)};
        
        [body setPosition:ccp(-20,-10)];
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_1];
	*/
	 
    } else if ([msg isEqualToString:@"hover"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"hover0",@"hover1",@"hover2" ,@"hover3" ,@"hover4",@"hover5",@"hover6",@"hover7",@"hover8",@"hover9",@"hover10",@"hover11",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""        ,@"",@"jump"     ,@"hold"     ,@"hold"        ,@"hold"        ,@"hold"    ,@"hold"    ,@"hold"        ,@"hold"        ,@"hold",@""         ,nil];
        CGPoint handframes[] =                            {ccp(0,0),ccp(0,0),ccp(0,0),ccp(0,0),ccp(-6,0)  ,ccp(-12,0)  ,ccp(-12,0)   ,ccp(-12,0)   ,ccp(-12,0)  ,ccp(-12,0) ,ccp(-12,0)  ,ccp(-12,0)   ,ccp(-12,0)   ,ccp(-12,0),ccp(-12,0)    };
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW,NOSHOW     ,NOSHOW      ,NOSHOW      ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW,NOSHOW      };
        
        [body setPosition:ccp(0,15)];
        [effect setPosition:ccp(50,-50)];
        defaulthandpos = ccp(100,-100);
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_2];
        
    } else if ([msg isEqualToString:@"jump"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"jump0",@"jump1",@"jump2" ,@"jump3" ,@"jump4",@"jump5",@"jump6",@"jump7",@"jump8",@"jump9",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""        ,@"",@""     ,@""     ,@"jump"        ,@"jump"        ,@""    ,@""    ,@""        ,@""                ,nil];
        CGPoint handframes[] =                            {ccp(0,0),ccp(0,0),ccp(0,0),ccp(0,0)  ,ccp(0,0),ccp(-6,0)  ,ccp(-12,0)   ,ccp(-6,0)   ,ccp(0,0)  ,ccp(0,0) ,ccp(0,0)  ,ccp(0,0)   ,ccp(0,0)      };
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW     ,NOSHOW,NOSHOW      ,NOSHOW      ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW        };
        
        [body setPosition:ccp(0,15)];
        [effect setPosition:ccp(50,-50)];
        defaulthandpos = ccp(100,-100);
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_2];
        
    } else if ([msg isEqualToString:@"swingvine"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"swingvine0",@"swingvine1" ,@"swingvine2" ,@"swingvine3",@"swingvine5",@"swingvine6",@"swingvine7",@"swingvine8",@"swingvine9",@"swingvine10",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""        ,@"jump"     ,@"jump"     ,@""        ,@""        ,@"jump"    ,@"jump"    ,@""        ,@""        ,@""         ,nil];
        CGPoint handframes[] =                            {ccp(0,0),ccp(0,0),ccp(0,0),ccp(-6,0)  ,ccp(-12,0)  ,ccp(-6,0)   ,ccp(0,0)   ,ccp(-6,0)  ,ccp(-12,0) ,ccp(-6,0)  ,ccp(0,0)   ,ccp(0,0)   ,ccp(0,0)    };
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW     ,NOSHOW      ,NOSHOW      ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW     ,NOSHOW      };
        
        [body setPosition:ccp(0,15)];
        [effect setPosition:ccp(50,-50)];
        defaulthandpos = ccp(100,-100);
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_2];
    
	/*
    } else if ([msg isEqualToString:@"swipe_down"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"swipe_down0",@"swipe_down1",@"swipe_down2"     ,@"swipe_down3"     ,@"swipe_down4"         ,@"swipe_down5"             ,@"swipe_down6",@"swipe_down7",@"swipe_down8",@"swipe_down9",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""          ,@""          ,@"swipedown"  ,@"swipedown"  ,@"swipedown"      ,@"swipedown"          ,@""         ,@"",@"",@""           ,nil];
        CGPoint handframes[] =                            {ccp(0,0),ccp(0,0),ccp(0,0),ccp(0,0)     ,ccp(0,0)     ,ccp(20,-5)         ,ccp(50,-10)         ,ccp(90,-15)            ,ccp(0,0)                  ,ccp(0,0)    ,ccp(0,0),ccp(0,0),ccp(0,0)          };
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW      ,NOSHOW,NOSHOW,NOSHOW            };
        
        [effect setPosition:ccp(50,-75)];
        [body setPosition:ccp(-20,5)];
        defaulthandpos = ccp(0,-100);
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_2];
	*/
	 
    } else if ([msg isEqualToString:@"swipe_straight"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"swipe_straight0",@"swipe_straight1",@"swipe_straight2"     ,@"swipe_straight3"     ,@"swipe_straight4"         ,@"swipe_straight5"             ,@"swipe_straight6",@"swipe_straight7",@"swipe_straight8",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""          ,@""          ,@"swipestraight"  ,@"swipestraight"  ,@"swipestraight"      ,@"swipestraight"          ,@""         ,@"",@""         ,nil];
        CGPoint handframes[] =                            {ccp(0,0),ccp(0,0),ccp(0,0),ccp(0,0)     ,ccp(0,0)     ,ccp(20,0)         ,ccp(50,0)         ,ccp(90,0)            ,ccp(0,0)                  ,ccp(0,0)    ,ccp(0,0),ccp(0,0)        };
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW      ,NOSHOW,NOSHOW          };
        
        [effect setPosition:ccp(50,-55)];
        [body setPosition:ccp(-20,15)];
        defaulthandpos = ccp(0,-100);
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_2];
	
	/*
    } else if ([msg isEqualToString:@"swipe_up"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"swipe_up0",@"swipe_up1",@"swipe_up2"     ,@"swipe_up3"     ,@"swipe_up4"         ,@"swipe_up5"             ,@"swipe_up6",@"swipe_up7",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""          ,@""          ,@"swipeup"  ,@"swipeup"  ,@"swipeup"      ,@"swipeup"          ,@""         ,@""       ,nil];
        CGPoint handframes[] =                            {ccp(0,0),ccp(0,0),ccp(0,0),ccp(0,0)     ,ccp(0,0)     ,ccp(20,15)         ,ccp(50,30)         ,ccp(90,45)            ,ccp(0,0)                  ,ccp(0,0)    ,ccp(0,0)      };
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW      ,NOSHOW    };
        
        [effect setPosition:ccp(50,-25)];
        [body setPosition:ccp(-20,15)];
        defaulthandpos = ccp(0,-100);
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_2];
    */
	 
    } else if ([msg isEqualToString:@"collectcoin"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"collectcoin0",@"collectcoin1",@"collectcoin2"     ,@"collectcoin3"     ,@"collectcoin4"         ,@"collectcoin5"             ,@"collectcoin6",@"collectcoin7",@"collectcoin8",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""          ,@""          ,@"swipestraight"  ,@"swipestraight"  ,@"swipestraight"      ,@"swipestraight"          ,@""         ,@"",@""         ,nil];
        CGPoint handframes[] =                            {ccp(0,0),ccp(0,0),ccp(0,0),ccp(0,0)     ,ccp(0,0)     ,ccp(20,0)         ,ccp(50,0)         ,ccp(90,0)            ,ccp(0,0)                  ,ccp(0,0)    ,ccp(0,0),ccp(0,0)        };
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW      ,NOSHOW,NOSHOW          };
        
        [effect setPosition:ccp(50,-55)];
        [body setPosition:ccp(-20,15)];
        defaulthandpos = ccp(0,-100);
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_1];
    
	/*
    } else if ([msg isEqualToString:@"upsidedown"]) {
        NSArray* tbodyframes = [NSArray arrayWithObjects:  @""     ,@""     ,@""     ,@"upsidedown0",@"upsidedown1",@"upsidedown2",@"upsidedown3",@"upsidedown4",@"upsidedown5",@"upsidedown6",@"upsidedown7",nil];
        NSArray* teffectframes = [NSArray arrayWithObjects:@""     ,@""     ,@""     ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""          ,@""                    ,nil];
        CGPoint handframes[] =                            {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW      };
        CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       ,NOSHOW       };
        
        [body setPosition:ccp(-20,-10)];
        [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_2];
    */
	 
    } else if ([msg isEqualToString:@"shot"]) {
      NSArray* tbodyframes = [NSArray arrayWithObjects:  @"shot7"     ,@"shot7"     ,@"shot7"     ,@"shot0"  ,@"shot1",@"shot2" ,@"shot3"  ,@"shot4"  ,@"shot5"   ,@"shot6",@"shot7"  ,@"shot7"   ,@"shot7",nil];
      NSArray* teffectframes = [NSArray arrayWithObjects:@""          ,@""          ,@""          ,@""       ,@""     ,@""      ,@""       ,@"jump"   ,@"jump"	  ,@""     ,@""       ,@""        ,@""     ,nil];
      CGPoint handframes[] =                            {ccp(0,0)     ,ccp(0,0)		,ccp(0,0)	  ,ccp(0,0)  ,ccp(0,0),ccp( 0,0),ccp(-6,0),ccp(-12,0) ,ccp(-6,0)  ,ccp(-6,0),ccp(0,0)  ,ccp(0,0)   ,ccp(0,0)      };
      CGPoint nosignfr[] =                              {NOSHOW  ,NOSHOW  ,NOSHOW  ,NOSHOW     ,NOSHOW,NOSHOW      ,NOSHOW      ,NOSHOW    ,NOSHOW   ,NOSHOW   ,NOSHOW     ,NOSHOW     ,NOSHOW        };
      
      [body setPosition:ccp(0,15)];
      [effect setPosition:ccp(50,-50)];
      defaulthandpos = ccp(100,-100);
      [self make_anim_body:tbodyframes effect:teffectframes hand:handframes nosign:nosignfr src:TEX_TUTORIAL_ANIM_1];
      
    } else {
        NSLog(@"ERROR TUTORIAL NOT FOUND:%@",msg);
    }
	[effect setPosition:ccp(effect.position.x/CC_CONTENT_SCALE_FACTOR(),effect.position.y/CC_CONTENT_SCALE_FACTOR())];
    return self;
}

-(void)update {
    animdelayct++;
    if (animdelayct >= animspeed) {
        curframe=curframe+1>=animlen?0:curframe+1;
        [body setTextureRect:frames[curframe]];
        [effect setTextureRect:effectframes[curframe]];
        
		CGPoint tar_hand_pos = CGPointAdd(defaulthandpos, handposframes[curframe]);
		tar_hand_pos.x /= CC_CONTENT_SCALE_FACTOR();
		tar_hand_pos.y /= CC_CONTENT_SCALE_FACTOR();
        [hand setPosition:tar_hand_pos];
        [hand setVisible:!CGPointEqualToPoint(handposframes[curframe], NOSHOW)];
        
        [nosign setPosition:nosignframes[curframe]];
        [nosign setVisible:!CGPointEqualToPoint(nosignframes[curframe], NOSHOW)];
        
        animdelayct=0;
        
    } else {
        animdelayct++;
        
    }
}

-(void)make_anim_body:(NSArray*)tbodyframes effect:(NSArray*)teffectframes hand:(CGPoint*)handframes nosign:(CGPoint*)nosignf src:(NSString*)src {
    [self cons_body_anim_tar:src frames:tbodyframes speed:10];
    [self addChild:body];
    
    [self cons_effect_anim:TEX_TUTORIAL_OBJ frames:teffectframes];
    [self addChild:effect];
    
    [self cons_hand_anim:handframes];
    [hand setPosition:CGPointAdd(defaulthandpos, handposframes[curframe])];
    [self addChild:hand];
    
    [self cons_nosign_anim:nosignf];
    [self addChild:nosign];
}

-(void)cons_nosign_anim:(CGPoint*)poss {
    [nosign setTexture:[Resource get_tex:TEX_TUTORIAL_OBJ]];
    [nosign setTextureRect:[FileCache get_cgrect_from_plist:TEX_TUTORIAL_OBJ idname:@"nosign"]];
    [nosign setScale:1];
    nosignframes= malloc(sizeof(CGPoint)*animlen);
    for(int i = 0; i < animlen; i++) {
        nosignframes[i] = poss[i];
    }
    [nosign setVisible:NO];
}

-(void)cons_hand_anim:(CGPoint*)poss {
    [hand setTexture:[Resource get_tex:TEX_TUTORIAL_OBJ]];
    [hand setTextureRect:[FileCache get_cgrect_from_plist:TEX_TUTORIAL_OBJ idname:@"hand"]];
    [hand setScale:0.75];
    handposframes = malloc(sizeof(CGPoint)*animlen);
    for(int i = 0; i < animlen; i++) {
        handposframes[i] = poss[i];
    }
    [hand setVisible:NO];
}

-(void)cons_effect_anim:(NSString*)tar frames:(NSArray*)a {
    effectframes = malloc(sizeof(CGRect)*animlen);
    for(int i = 0; i < animlen; i++) {
        effectframes[i] = [FileCache get_cgrect_from_plist:tar idname:[a objectAtIndex:i]];
    }
    [effect setTexture:[Resource get_tex:tar]];
    [effect setTextureRect:effectframes[curframe]];
}

-(void)cons_body_anim_tar:(NSString*)tar frames:(NSArray*)a speed:(int)speed {
    frames = malloc(sizeof(CGRect)*[a count]);
    animlen = (int)[a count];
    curframe = 0;
    animspeed = speed;
    
    for (int i = 0; i < [a count]; i++) {
        frames[i] = [FileCache get_cgrect_from_plist:tar idname:[a objectAtIndex:i]];
    }
    [body setTexture:[Resource get_tex:tar]];
    [body setTextureRect:frames[curframe]];
}

-(void)dealloc {
    free(frames);
    free(effectframes);
    free(handposframes);
    free(nosignframes);
}

@end
