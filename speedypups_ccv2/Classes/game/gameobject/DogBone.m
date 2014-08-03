#import "DogBone.h"
#import "PlayerEffectParams.h"
#import "GameEngineLayer.h"
#import "ObjectPool.h"
#import "ScoreManager.h"

@implementation DogBone

@synthesize bid;

+(DogBone*)cons_x:(float)posx y:(float)posy bid:(int)bid {
    //DogBone *new_coin = [DogBone node];
	DogBone *new_coin = [ObjectPool depool:[DogBone class]];
	new_coin.active = YES;
    [new_coin cons:ccp(posx,posy)];
    new_coin.bid = bid;
    return new_coin;
}

-(id)init {
	self = [super init];
	if ([self class] == [DogBone class]) {
		self.img = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ITEM_SS] rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"goldenbone"]];
		[self addChild:self.img];
	}
	return self;
}

-(void)repool {
	gameengine = NULL;
	if ([self class] == [DogBone class]) [ObjectPool repool:self class:[DogBone class]];
}

-(void)cons:(CGPoint)start {
    [self setPosition:start];
    initial_pos = start;
    follow = NO;
    refresh_cached_hitbox = YES;
    active = YES;
	vx = 0;
	vy = 0;
	challenge_mode_respawn = NO;
	anim_toggle = NO;
}

-(void)setPosition:(CGPoint)position {
    initial_pos = position;
    [super setPosition:position];
    refresh_cached_hitbox = YES;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];
}

-(HitRect)get_hit_rect {
    if (refresh_cached_hitbox) {
        refresh_cached_hitbox = NO;
        cached_hitbox = [Common hitrect_cons_x1:[self position].x-10 y1:[self position].y-10 wid:20 hei:20];
    }
    return cached_hitbox;
}

-(void)update:(Player*)player g:(GameEngineLayer *)g{
	gameengine = g;
    [super update:player g:g];
    if (!active || player.dead) {
        return;
    }
    
    float dist = [Common distanceBetween:[self position] and:player.position];
    if (dist > 500) {
        return;
    }
    
    float rot = [self rotation];
    if (anim_toggle) {
        rot+=0.5;
        if (rot > 10) {
            anim_toggle = !anim_toggle;
        }
    } else {
        rot-=0.5;
        if (rot < -10) {
            anim_toggle = !anim_toggle;
        }
    }
    [self setRotation:rot];
    
    float maxdist = [player get_magnet_rad];
    [super setPosition:ccp([self position].x + vx * [Common get_dt_Scale], [self position].y + vy * [Common get_dt_Scale])];
    if (!follow && dist < maxdist) {
        follow = YES;
    }
    
    if (follow) {
        refresh_cached_hitbox = YES;
        Vec3D vel = [VecLib cons_x:player.position.x-[self position].x y:player.position.y-[self position].y z:0];
        vel = [VecLib normalize:vel];
        vel = [VecLib scale:vel by:MAX(12,sqrtf(powf(player.vx, 2) + powf(player.vy, 2))*1.2)];
        vx = vel.x;
        vy = vel.y;
    } else {
        vx = 0;
        vy = 0;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        [self hit];
    }
}

static float last_collect_time = 0;
static NSString* snds[] = {SFX_BONE,SFX_BONE_2,SFX_BONE_3,SFX_BONE_4};
static int current_sound = 0;

+(void)play_collect_sound:(GameEngineLayer*)gameengine {
	if (gameengine == NULL) {
		NSLog(@"dogbone play_collect_sound gameengine is null");
		return;
	}
	if ([gameengine get_time] - last_collect_time < 5) {
		current_sound = current_sound;
		
	} else if ([gameengine get_time] - last_collect_time < 30) {
		current_sound = MIN(current_sound+1,3);
		
	} else {
		current_sound = 0;
	}
	[AudioManager playsfx:snds[current_sound]];
	last_collect_time = [gameengine get_time];
}

+(void)reset_play_collect_sound {
	last_collect_time = 0;
}

-(void)hit {
	[DogBone play_collect_sound:gameengine];
	[gameengine.score increment_multiplier:0.005];
    [gameengine.score increment_score:10];
	[GEventDispatcher push_event:[GEvent cons_type:GEventType_COLLECT_BONE]];
    active=NO;
}

-(void)notify_challenge_mode:(ChallengeInfo *)c {
    challenge_mode_respawn = YES;
}

-(void)reset {
    [self setPosition:initial_pos];
    follow = NO;
    vx = 0;
    vy = 0;
    
    //if (challenge_mode_respawn) {
	active = YES;
    //}
	[DogBone reset_play_collect_sound];
}

@end
