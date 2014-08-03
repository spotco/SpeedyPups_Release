#import "DogShadow.h"
#import "GameEngineLayer.h"

@implementation DogShadow

+(DogShadow*)cons {
    return [DogShadow node];
}

-(id)init {
    self = [super init];
    [self addChild:[CCSprite spriteWithTexture:[Resource get_tex:TEX_DOG_SHADOW]]];
	[self setOpacity:120];
    return self;
}

-(void)check_should_render:(GameEngineLayer *)g {
}

-(int)get_render_ord {
    return surfg ? [GameRenderImplementation GET_RENDER_ABOVE_FG_ORD] : [GameRenderImplementation GET_RENDER_PLAYER_SHADOW_ORD];
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    surfg = (player.current_island && !player.current_island.can_land);
    [[self parent] reorderChild:self z:[self get_render_ord]];
    
    if (player.current_island != NULL) {
        if (player.last_ndir < 0) {
            [self setVisible:NO];
            [self setPosition:player.position];
        } else {
            [self setVisible:YES];
            [self setPosition:player.position];
            Vec3D tv = [player.current_island get_tangent_vec];
            [self setRotation:-[Common rad_to_deg:[VecLib get_angle_in_rad:tv]]];
            [self csf_setScale:1];
			
			if ([player is_armored] || streq([Player get_character],TEX_DOG_RUN_6)) {
				[self csf_setScale:[self csf_scale]*1.2];
			}
       }
    } else {
        shadowinfo v = [DogShadow calc_g_dist:player islands:g.islands];
        if (v.dist == INFINITY) {
            [self setVisible:NO];
        } else {
            [self setVisible:YES];
        }
        [self setPosition:ccp(player.position.x,v.y)];
        [self setRotation:v.rotation];
        [self csf_setScale:MAX(0, (300-v.dist)/300)];
		
		if ([player is_armored] || streq([Player get_character],TEX_DOG_RUN_6)) {
			[self csf_setScale:[self csf_scale]*1.2];
		}
    }
}

+(shadowinfo)calc_g_dist:(Player*)player islands:(NSMutableArray*)islands {
    struct shadowinfo n;
    if (player.current_island != NULL) {
        return n;
    }
    
    float dist = INFINITY;
    CGPoint pos = player.position;
    for (Island* i in islands) {
        if (pos.x > i.endX || pos.x < i.startX) continue;
        float ipos = [i get_height:pos.x];
        if (ipos != [Island NO_VALUE] && pos.y > ipos && (pos.y - ipos) < dist) {
            dist = pos.y - ipos;
            n.y = ipos;
            Vec3D tv = [i get_tangent_vec];
            n.rotation = -[Common rad_to_deg:[VecLib get_angle_in_rad:tv]];
        }
    }
    
    n.dist = dist;
    return n;
}
@end

@implementation ObjectShadow {
	int _last_gameobjects_count;
}

+(ObjectShadow*)cons_tar:(GameObject *)o {
    return [[ObjectShadow node] cons_tar:o];
}

-(void)check_should_render:(GameEngineLayer *)g {
    do_render = tar.do_render;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}

-(id)cons_tar:(GameObject*)o {
    tar = o;
    [self cons_body];
    return self;
}

-(void)cons_body {
    [self addChild:[CCSprite spriteWithTexture:[Resource get_tex:TEX_DOG_SHADOW]]];
    [self setOpacity:120];
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (!do_render)return;
    
    shadowinfo v = [ObjectShadow calc_g_dist:tar islands:g.islands];
    if (v.dist == INFINITY) {
        [self setVisible:NO];
    } else {
        [self setVisible:YES];
    }
    [self setPosition:ccp(tar.position.x,v.y)];
    
    [self setRotation:v.rotation];
    [self update_scale:v];
	
	if (g.game_objects.count != _last_gameobjects_count) {
		if (![g.game_objects containsObject:tar]) {
			tar = NULL;
			[g remove_gameobject:self];
		}
	}
	_last_gameobjects_count = (int)g.game_objects.count;
}

-(void)update_scale:(shadowinfo)v {
    [self csf_setScale:MAX(0, (300-v.dist)/300)];
}

+(shadowinfo)calc_g_dist:(GameObject*)tar islands:(NSMutableArray*)islands {
    struct shadowinfo n;
    float dist = INFINITY;
    CGPoint pos = tar.position;
    pos.y += 5;
    for (Island* i in islands) {
        if (pos.x > i.endX || pos.x < i.startX) continue;
        float ipos = [i get_height:pos.x];
        if (ipos != [Island NO_VALUE] && pos.y > ipos && (pos.y - ipos) < dist) {
            dist = pos.y - ipos;
            n.y = ipos;
            Vec3D tv = [i get_tangent_vec];
            n.rotation = -[Common rad_to_deg:[VecLib get_angle_in_rad:tv]];
        }
    }
    n.dist = dist;
    return n;
}

@end