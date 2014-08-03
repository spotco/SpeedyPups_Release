#import "FishGenerator.h"

#define SPAWN_MARGIN 25
#define SPAWN_WAIT_BASE 100

#define FISH_GRAVITY 0.1
#define FISH_VEL_VARIANCE 5
#define FISH_XVEL_OFFSET -2
#define FISH_YVEL_OFFSET 3

@interface Fish: CSF_CCSprite {
    float vx,vy;
    int wait;
}
@property(readwrite,assign) int wait;
-(void)update:(float)bwidth hei:(float)hei numactive:(int)numactive;
@end

@implementation Fish
@synthesize wait;
-(id)init{
    wait = rand()%((int)SPAWN_MARGIN*5);
    return [super init];
}
-(void)update:(float)bwidth hei:(float)hei numactive:(int)numactive {  
    if(wait > 0) {
        wait--;
        if (wait == 0 && numactive >= 2) {
            wait = 1;
            return;
        }
        if (wait == 0) {
            float npos = rand()%((int)(bwidth-SPAWN_MARGIN*2));
            npos+=SPAWN_MARGIN;
            [self setVisible:YES];
            [self setPosition:ccp(npos,hei)];
            vx = (rand()%FISH_VEL_VARIANCE)+FISH_XVEL_OFFSET;
            vy = rand()%FISH_VEL_VARIANCE+FISH_YVEL_OFFSET;
        }
        return;
    }
    
    [self setPosition:ccp([self position].x+vx,[self position].y+vy)];
    vy-=FISH_GRAVITY;
    
    if([self position].y < hei) {
        [self setPosition:ccp(0,0)];
        [self setVisible:NO];
        wait = SPAWN_WAIT_BASE;
    }
    
    Vec3D dv = [VecLib cons_x:vx y:vy z:0];
    dv=[VecLib normalize:dv];
    float rot = -[Common rad_to_deg:[VecLib get_angle_in_rad:dv]];
    [self setRotation:rot];
}
-(void)dealloc {
    [self stopAllActions];
}
@end

@implementation FishGenerator

+(FishGenerator*)cons_ofwidth:(float)wid basehei:(float)hei {
    FishGenerator *n = [FishGenerator node];
    n.anchorPoint = ccp(0,0);
    [n cons_given_width:wid basehei:hei];
    return n;
}

-(void)cons_given_width:(float)wid basehei:(float)hei {
    bwidth = wid;
    bheight = hei;
	[self setScale:1];
    
    CCTexture2D *tex = [Resource get_tex:TEX_FISH_SS];
    NSMutableArray *names = [NSMutableArray arrayWithObjects:@"green_%i",@"purple_%i",@"red_%i",@"yellow_%i", nil];
    fishes = [NSMutableArray array];
    
    for (NSString* n in names) {
        CCSprite *f = [self fish_from_formatstring:n and_tex:tex];
        [self addChild:f];
        [fishes addObject:f];
    } 
}


-(Fish*)fish_from_formatstring:(NSString*)tar and_tex:(CCTexture2D*)tex {
    Fish *n = [Fish node];
    NSMutableArray *animFrames = [NSMutableArray array];
    for(int i = 1; i <= 3; i++) {
        CCSpriteFrame *c = [CCSpriteFrame frameWithTexture:tex rect:[FishGenerator fish_ss_spritesheet_rect_tar:[NSString stringWithFormat:tar,i]]];
        [animFrames addObject:c];
    }
    [n runAction:[Common make_anim_frames:animFrames speed:0.1]];
    [n csf_setScale:0.5];
    n.position = ccp(0,-100);
    return n;
}

-(void)update {
    int activect = 0;
    for(Fish* i in fishes) {
        if (i.wait == 0) {
            activect++;
        }
    }
    for (Fish* i in fishes) {
        [i update:bwidth hei:bheight numactive:activect];
    }
}

+(CGRect)fish_ss_spritesheet_rect_tar:(NSString*)tar {
    return [FileCache get_cgrect_from_plist:TEX_FISH_SS idname:tar];
}

-(void)dealloc {
    [fishes removeAllObjects];
     //GO FISHIES GO HOME
    [self removeAllChildrenWithCleanup:YES];
}

@end