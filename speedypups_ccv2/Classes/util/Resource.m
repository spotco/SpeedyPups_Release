#import "Resource.h"
#define _NSSET(...)  [NSMutableSet setWithArray:@[__VA_ARGS__]]
#define streq(a,b) [a isEqualToString:b]

@interface AsyncImgLoad : NSObject
+(AsyncImgLoad*)load:(NSString *)file key:(NSString*)key ;
@property(readwrite,assign) BOOL finished;
@property(readwrite,strong) NSString *key;
@property(readwrite,strong) CCTexture2D* tex;
@end

@implementation AsyncImgLoad
+(AsyncImgLoad*)load:(NSString *)file key:(NSString*)key {
	return [[AsyncImgLoad alloc] init_with:file key:key];
}
-(id)init_with:(NSString*)file key:(NSString*)key {
	self = [super init];
	self.finished = NO;
	self.key = key;
	[[CCTextureCache sharedTextureCache] addImageAsync:file target:self selector:@selector(on_finish:)];
	return self;
}
-(void)on_finish:(CCTexture2D*)tex {
	self.tex = tex;
	self.finished = YES;
}
@end

@implementation Resource


static NSDictionary* all_textures;
static NSMutableDictionary* loaded_textures;
static NSSet* dont_load;

+(void)initialize {
}

+(void)load_all {
	loaded_textures = [NSMutableDictionary dictionary];
	all_textures = @{
	 TEX_INTRO_ANIM_SS : @"intro_anim_ss.png",
	
	 TEX_GROUND_TEX_1 : @"BG1_island_fill.png",
	 TEX_GROUND_TOP_1 : @"BG1_top_fill.png",
	 TEX_GROUND_CORNER_TEX_1 : @"BG1_island_corner.png",
	 TEX_TOP_EDGE : @"BG1_island_top_edge.png",
	 TEX_BRIDGE_EDGE : @"BG1_bridge_edge.png",
	 TEX_BRIDGE_SECTION : @"BG1_bridge_section.png",
	 
	 TEX_LAB_GROUND_1 : @"lab_ground_1.png",
	 TEX_LAB_GROUND_TOP : @"lab_ground_top.png",
	 TEX_LAB_GROUND_TOP_EDGE : @"lab_ground_top_edge.png",
	 TEX_LAB_GROUND_CORNER : @"lab_island_corner.png",
	 TEX_LAB_ENTRANCE_BACK : @"back_labentrance_pillar.png",
	 TEX_LAB_ENTRANCE_FORE : @"front_labentrance_pillar.png",
	 TEX_LAB_ENTRANCE_CEIL : @"ceil_labentrance.png",
	 TEX_LAB_ENTRANCE_CEIL_REPEAT:@"ceil_repeat_labentrance.png",
	 TEX_LAB_WALL:@"lab_wall.png",
	 
	 TEX_LAB_ROCK_PARTICLE:@"lab_rock_particle.png",
	 TEX_LAB_HANDRAIL:@"lab_handrail.png",
	 
	 //world specific
	 TEX_GROUND_DETAILS : @"grounddetail_ss.png",
	 TEX_GROUND_DETAILS_WORLD2 : @"grounddetail_world2_ss.png",
	 
	 TEX_BG_SKY:@"BG1_sky.png",
	 TEX_BG_LAYER_1:@"BG1_layer_1.png",
	 TEX_BG_LAYER_3:@"BG1_layer_3.png",
	 
	 TEX_BG2_BACKHILLS:@"BG2_backhills.png",
	 TEX_BG2_FRONTHILLS:@"BG2_fronthills.png",
	 TEX_BG2_FRONTISLANDS_0:@"BG2_frontislands_0.png",
	 TEX_BG2_FRONTISLANDS_1:@"BG2_frontislands_1.png",
	 TEX_BG2_SKY:@"BG2_sky.png",
	 TEX_BG2_WATER:@"BG2_water.png",
	 TEX_BG2_CLOUDS_SS:@"cloud_world2_ss.png",
	 
	 TEX_BG2_ISLAND_TOP_FILL:@"BG2_top_fill.png",
	 TEX_BG2_ISLAND_TOP_EDGE:@"BG2_island_top_edge.png",
	 TEX_BG2_ISLAND_CORNER:@"BG2_island_corner.png",
	 
	 TEX_BG3_SKY:@"BG3_sky.png",
	 TEX_BG3_BACKMOUNTAINS:@"BG3_backmountains.png",
	 TEX_BG3_CASTLE:@"BG3_castle.png",
	 TEX_BG3_BACKHILLS:@"BG3_backhills.png",
	 TEX_BG3_FRONTHILLS:@"BG3_fronthills.png",
	 TEX_BG3_SKY:@"BG3_sky.png",
	 TEX_BG3_TOP_FILL:@"BG3_top_fill.png",
	 TEX_BG3_ISLAND_CORNER:@"BG3_island_corner.png",
	 TEX_BG3_ISLAND_EDGE:@"BG3_island_top_edge.png",
	 TEX_BG3_ISLAND_FILL:@"BG3_island_fill.png",
	 TEX_BG3_GROUND_DETAIL_SS:@"grounddetail_world3_ss.png",
	 
	 TEX_LAB_BG : @"lab_bg.png",
	 TEX_LAB_BG_LAYER:@"lab_bg_layer.png",
	 
	 TEX_LAB2_WATER_BACK: @"lab2_water_back.png",
	 TEX_LAB2_WATER_FRONT: @"lab2_water_front.png",
	 TEX_LAB2_DOCKS: @"lab2_docks.png",
	 TEX_LAB2_WINDOWWALL: @"lab2_windowwall.png",
	 TEX_LAB2_TANKER_BACK: @"lab2_tanker_back.png",
	 TEX_LAB2_TANKER_FRONT: @"lab2_tanker_front.png",
	 TEX_LAB2_WATER_FG: @"lab2_water_fg.png",
	 
	 TEX_LAB3_BGBACK:@"lab3_bgback.png",
	 TEX_LAB3_BGWALL:@"lab3_bgwall.png",
	 TEX_LAB3_BGFRONT:@"lab3_bgfront.png",
	 //end
	 
	 TEX_CAVE_ROCKWALL_BASE:@"breakablewall_base.png",
	 TEX_CAVE_ROCKWALL_SECTION:@"breakablewall_body.png",
	 TEX_LAB_ROCKWALL_BASE:@"labbreakablewall_base.png",
	 TEX_LAB_ROCKWALL_SECTION:@"labbreakablewall_body.png",
	 TEX_CAVE_ROCKPARTICLE:@"rock_particle.png",
	 
	 TEX_BG_SUN:@"BG1_sun.png",
	 TEX_BG_MOON:@"BG1_moon.png",
	 TEX_BG_STARS:@"BG1_stars.png",
	 TEX_ISLAND_BORDER:@"BG1_island_border.png",
	 TEX_WATER:@"water.png",
	 TEX_CANNON_SS:@"cannon_ss.png",
	 
	 TEX_FISH_SS:@"fish_ss.png",
	 TEX_BIRD_SS:@"bird_ss.png",
	 TEX_JUMPPAD:@"jumppad.png",
	 TEX_SPEEDUP:@"speedup_ss.png",
	 TEX_SPIKE_VINE_BOTTOM:@"spike_vine_bottom.png",
	 TEX_SPIKE_VINE_SECTION:@"spike_vine_section.png",
	 TEX_GOAL_SS:@"goal_ss.png",
	 TEX_SWINGVINE_BASE:@"swingvine_base.png",
	 TEX_SWINGVINE_TEX:@"swingvine_tex_loose.png",
	 TEX_LABSWINGVINE_BASE:@"labswingvine_base.png",
	 TEX_ELECTRIC_BODY:@"electric_body.png",
	 TEX_ELECTRIC_BASE:@"electric_post.png",
	 TEX_ITEM_SS:@"item_ss.png",
	 TEX_ENEMY_ROBOT:@"robot_default.png",
	 TEX_ENEMY_LAUNCHER:@"launcher_default.png",
	 TEX_ENEMY_ROCKET:@"rocket.png",
	 TEX_ENEMY_COPTER:@"copter_default.png",
	 TEX_ENEMY_SUBBOSS:@"subboss.png",
	 TEX_ENEMY_ROBOTBOSS:@"robotboss.png",
	 TEX_ROBOT_PARTICLE:@"robot_particle.png",
	 TEX_EXPLOSION:@"explosion_default.png",
	 TEX_ENEMY_BOMB:@"bomb.png",
	 
	 //char specific
	 TEX_DOG_RUN_1:@"dog1ss.png",
	 TEX_DOG_RUN_2:@"dog2ss.png",
	 TEX_DOG_RUN_3:@"dog3ss.png",
	 TEX_DOG_RUN_4:@"dog4ss.png",
	 TEX_DOG_RUN_5:@"dog5ss.png",
	 TEX_DOG_RUN_6:@"dog6ss.png",
	 TEX_DOG_RUN_7:@"dog7ss.png",
	 //end
	 
	 TEX_DOG_SPLASH:@"splash_ss.png",
	 TEX_DOG_SHADOW:@"dog_shadow.png",
	 TEX_DOG_ARMORED:@"armored_dog_ss.png",
	 TEX_SWEATANIM_SS:@"sweatanim_ss.png",
	 TEX_DASHJUMPPARTICLES_SS:@"dashjumpparticles_ss.png",
	 TEX_SPIKE:@"spikes.png",
	 TEX_CHECKPOINT_1:@"checkpoint1.png",
	 TEX_CHECKPOINT_2:@"checkpoint2.png",
	 TEX_CANNONFIRE_PARTICLE:@"cannonfire_default.png",
	 TEX_CANNONTRAIL:@"cannontrail_default.png",
	 TEX_UI_INGAMEUI_SS:@"ingame_ui_ss.png",
	 TEX_TUTORIAL_OBJ:@"tutorial_obj.png",
	 TEX_TUTORIAL_ANIM_1:@"tut_anim_1.png",
	 TEX_TUTORIAL_ANIM_2:@"tut_anim_2.png",
	 TEX_NMENU_ITEMS:@"nmenu_items.png",
	 
	 TEX_NMENU_BGS_0:@"nmenu_bg_0.png",
	 TEX_NMENU_BGS_1:@"nmenu_bg_1.png",
	 TEX_NMENU_BGS_2:@"nmenu_bg_2.png",
	 TEX_NMENU_BGS_3:@"nmenu_bg_3.png",
	 
	 TEX_NMENU_DOGHOUSEMASK:@"doghouse_mask.png",
	 TEX_NMENU_LEVELSELOBJ:@"nmenu_levelselectobj.png",
	 TEX_FREERUNSTARTICONS:@"freerunstart_icons.png",
	 TEX_BLANK:@"blank.png",
	 TEX_PARTICLES:@"particles.png",
	 
	 TEX_CLOUDGAME_CLOUDFLOOR:@"cloudlevel_cloudfloor.png",
	 TEX_CLOUDGAME_BG:@"cloudlevel_bg.png",
	 TEX_CLOUDGAME_BGCLOUDS:@"cloudlevel_bgclouds.png",
	 TEX_CLOUDGAME_BOSS_BG:@"cloudlevel_boss_bg.png",
	 TEX_CLOUDGAME_BOSS_CLOUDFLOOR:@"cloudlevel_boss_cloudfloor.png",
	 
	 TEX_CANNONMOVETRACK_BODY:@"cannonmovetrack_body.png",
	 TEX_CANNONMOVETRACK_EDGE:@"cannonmovetrack_edge.png",
	 
	 TEX_CLOUDGAME_BOSS_BG_THUNDER:@"cloudlevel_boss_bg_thunder.png",
	 TEX_CHECKERBOARD_TEXTURE:@"checkerboard_texture.png",
	 
	 TEX_SPOTCOS_LOGO_SS:@"spotcos_logo_ss.png"
	};
	
	
	dont_load = _NSSET(
		TEX_CLOUDGAME_BOSS_BG_THUNDER,
		TEX_TUTORIAL_OBJ,
		TEX_NMENU_DOGHOUSEMASK,
		TEX_NMENU_LEVELSELOBJ,
	
		TEX_INTRO_ANIM_SS,
	
		TEX_ENEMY_COPTER,
		TEX_ENEMY_SUBBOSS,
		TEX_ENEMY_ROBOTBOSS,
				   
		TEX_DOG_RUN_1,
		TEX_DOG_RUN_2,
		TEX_DOG_RUN_3,
		TEX_DOG_RUN_4,
		TEX_DOG_RUN_5,
		TEX_DOG_RUN_6,
		TEX_DOG_RUN_7,
						  
		TEX_LAB_BG,
		TEX_LAB_BG_LAYER,
		TEX_GROUND_DETAILS,
		TEX_BG_SKY,
		TEX_BG_LAYER_1,
		TEX_BG_LAYER_3,

		TEX_GROUND_DETAILS_WORLD2,
		TEX_BG2_BACKHILLS,
		TEX_BG2_FRONTHILLS,
		TEX_BG2_FRONTISLANDS_0,
		TEX_BG2_FRONTISLANDS_1,
		TEX_BG2_SKY,
		TEX_BG2_WATER,
		TEX_BG2_CLOUDS_SS,
		TEX_LAB2_WATER_BACK,
		TEX_LAB2_WATER_FRONT,
		TEX_LAB2_DOCKS,
		TEX_LAB2_WINDOWWALL,
		TEX_LAB2_TANKER_BACK,
		TEX_LAB2_TANKER_FRONT,
		TEX_LAB2_WATER_FG,

		TEX_BG3_SKY,
		TEX_BG3_BACKMOUNTAINS,
		TEX_BG3_CASTLE,
		TEX_BG3_BACKHILLS,
		TEX_BG3_FRONTHILLS,
		TEX_BG3_SKY,
		TEX_BG3_GROUND_DETAIL_SS,
		TEX_LAB3_BGBACK,
		TEX_LAB3_BGWALL,
		TEX_LAB3_BGFRONT
	);
	
	NSMutableArray *imgloaders = [NSMutableArray array];
	for (NSString *key in all_textures.keyEnumerator) {
		if ([dont_load containsObject:key]) continue;
		[imgloaders addObject:[AsyncImgLoad load:all_textures[key] key:key]];
	}
	NSMutableArray *to_remove = [NSMutableArray array];
	while ([imgloaders count] > 0) {
		for (AsyncImgLoad *loader in imgloaders) {
			if (loader.finished) {
				[loader.tex setAntiAliasTexParameters];
				loaded_textures[loader.key] = loader.tex;
				[to_remove addObject:loader];
				loader.tex = NULL;
			}
		}
		[imgloaders removeObjectsInArray:to_remove];
		[to_remove removeAllObjects];
		[NSThread sleepForTimeInterval:0.001];
	}
	
	
	/*
	 //sync loading
	 for (NSString *key in all_textures) {
		CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:all_textures[key]];
		[tex setAntiAliasTexParameters];
		loaded_textures[key] = tex;
	}
	 */
}

+(CCTexture2D*)get_tex:(NSString *)key {
	if (loaded_textures[key] != nil) {
		return loaded_textures[key];
	} else {
		CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:all_textures[key]];
		[tex setAntiAliasTexParameters];
		loaded_textures[key] = tex;
		//NSLog(@"loading:%@",all_textures[key]);
		return loaded_textures[key];
	}
}

-(void)nullcb{}

+(void)load_world_textures:(int)i {
	
}

+(void)unload_textures {
	for (NSString *key in dont_load) {
		if (loaded_textures[key]) {
			CCTexture2D *tex = loaded_textures[key];
			if ([[CCTextureCache sharedTextureCache] isTextureUnused:tex]) {
				[loaded_textures removeObjectForKey:key];
				[[CCTextureCache sharedTextureCache] removeTexture:tex];
				//NSLog(@"unload %@",key);
			}
		}
	}
	
	//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	//[loaded_textures removeAllObjects];
	//[[CCTextureCache sharedTextureCache] removeAllTextures];
}



@end
