#import "cocos2d.h"

@interface Resource : NSObject

+(void)load_all;
+(CCTexture2D*)get_tex:(NSString*)key;
+(void)unload_textures;

#define TEX_INTRO_ANIM_SS @"intro_anim_ss"

#define TEX_GROUND_TEX_1 @"GroundTexture1"
#define TEX_GROUND_TOP_1 @"GroundTop1"
#define TEX_GROUND_CORNER_TEX_1 @"ground_1_corner"
#define TEX_BRIDGE_EDGE @"BridgeEdge"
#define TEX_BRIDGE_SECTION @"BridgeSection"
#define TEX_TOP_EDGE @"GroundTopEdge"

#define TEX_GROUND_DETAILS @"grounddetail_ss"
#define TEX_GROUND_DETAILS_WORLD2 @"grounddetail_world2_ss"

#define TEX_LAB_BG @"labbg"
#define TEX_LAB_GROUND_1 @"labground1"
#define TEX_LAB_GROUND_TOP @"labgroundtop"
#define TEX_LAB_GROUND_TOP_EDGE @"labgroundtopedge"
#define TEX_LAB_GROUND_CORNER @"labgroundcorner"
#define TEX_LAB_ENTRANCE_BACK @"labentranceback"
#define TEX_LAB_ENTRANCE_FORE @"labentrancefore"
#define TEX_LAB_ENTRANCE_CEIL @"labentranceceil"
#define TEX_LAB_ENTRANCE_CEIL_REPEAT @"labentranceceilrepeat"
#define TEX_LAB_WALL @"labwall"
#define TEX_LAB_BG_LAYER @"lab_bg_layer"
#define TEX_LAB_ROCK_PARTICLE @"lab_rock_particle"
#define TEX_LAB_HANDRAIL @"lab_handrail"

#define TEX_LAB2_WATER_BACK @"lab2_water_back"
#define TEX_LAB2_WATER_FRONT @"lab2_water_front"
#define TEX_LAB2_DOCKS @"lab2_docks"
#define TEX_LAB2_WINDOWWALL @"lab2_windowwall"
#define TEX_LAB2_TANKER_BACK @"lab2_tanker_back"
#define TEX_LAB2_TANKER_FRONT @"lab2_tanker_front"
#define TEX_LAB2_WATER_FG @"lab2_water_fg"

#define TEX_LAB3_BGBACK @"lab3_bgback" 
#define TEX_LAB3_BGWALL @"lab3_bgwall" 
#define TEX_LAB3_BGFRONT @"lab3_bgfront"

#define TEX_CAVE_ROCKWALL_BASE @"RockWallBase"
#define TEX_CAVE_ROCKWALL_SECTION @"RockWallSection"
#define TEX_LAB_ROCKWALL_BASE @"LabRockWallBase"
#define TEX_LAB_ROCKWALL_SECTION @"LabRockWallSection"
#define TEX_CAVE_ROCKPARTICLE @"RockParticle"

#define TEX_DOG_RUN_1 @"dog1ss"
#define TEX_DOG_RUN_2 @"dog2ss"
#define TEX_DOG_RUN_3 @"dog3ss"
#define TEX_DOG_RUN_4 @"dog4ss"
#define TEX_DOG_RUN_5 @"dog5ss"
#define TEX_DOG_RUN_6 @"dog6ss"
#define TEX_DOG_RUN_7 @"dog7ss"
#define TEX_DOG_SPLASH @"splash_ss"
#define TEX_DOG_SHADOW @"dogshadow"
#define TEX_DOG_ARMORED @"armored_dog_ss"
#define TEX_SWEATANIM_SS @"sweatanim_ss"
#define TEX_DASHJUMPPARTICLES_SS @"dashjumpparticles_ss"

#define TEX_ISLAND_BORDER @"IslandBorder"

#define TEX_GOAL_SS @"goal_ss"

#define TEX_BG_SKY @"BgSky"
#define TEX_BG_SUN @"BgSun"
#define TEX_BG_MOON @"BgMoon"
#define TEX_BG_STARS @"BgStars"
#define TEX_BG_LAYER_1 @"BgLayer1"
#define TEX_BG_LAYER_3 @"BgLayer3"

#define TEX_BG2_BACKHILLS @"BG2_backhills"
#define TEX_BG2_FRONTHILLS @"BG2_fronthills"
#define TEX_BG2_FRONTISLANDS_0 @"BG2_frontislands_0"
#define TEX_BG2_FRONTISLANDS_1 @"BG2_frontislands_1"
#define TEX_BG2_SKY @"BG2_sky"
#define TEX_BG2_WATER @"BG2_water"
#define TEX_BG2_CLOUDS_SS @"cloud_world2_ss"

#define TEX_BG2_ISLAND_TOP_FILL @"BG2_island_top_fill"
#define TEX_BG2_ISLAND_CORNER @"BG2_island_corner"
#define TEX_BG2_ISLAND_TOP_EDGE @"BG2_island_top_edge"

#define TEX_BG3_SKY @"BG3_sky"
#define TEX_BG3_BACKMOUNTAINS @"BG3_backmountains"
#define TEX_BG3_CASTLE @"BG3_castle"
#define TEX_BG3_BACKHILLS @"BG3_backhills"
#define TEX_BG3_FRONTHILLS @"BG3_fronthills"
#define TEX_BG3_SKY @"BG3_sky"
#define TEX_BG3_TOP_FILL @"BG3_top_fill"
#define TEX_BG3_ISLAND_CORNER @"BG3_island_corner"
#define TEX_BG3_ISLAND_EDGE @"BG3_island_edge"
#define TEX_BG3_ISLAND_FILL @"BG3_island_fill"
#define TEX_BG3_GROUND_DETAIL_SS @"grounddetail_world3_ss"

#define TEX_SPIKE @"Spike"
#define TEX_WATER @"Water"
#define TEX_FISH_SS @"fish_ss"
#define TEX_BIRD_SS @"bird_ss"
#define TEX_JUMPPAD @"jumppad"
#define TEX_SPEEDUP @"speedup_ss"
#define TEX_SPIKE_VINE_BOTTOM @"SpikeVineRight"
#define TEX_SPIKE_VINE_SECTION @"SpikeVineSection"
#define TEX_CANNON_SS @"cannon_ss"

#define TEX_ITEM_SS @"item_ss"
#define TEX_PARTICLES @"particles"

#define TEX_ENEMY_ROBOT @"robot_default"
#define TEX_ENEMY_LAUNCHER @"launcher_default"
#define TEX_ENEMY_ROCKET @"rocket"
#define TEX_ENEMY_COPTER @"copter_default"
#define TEX_ROBOT_PARTICLE @"robot_particle"
#define TEX_EXPLOSION @"explosion_default"
#define TEX_ENEMY_BOMB @"bomb"
#define TEX_ENEMY_SUBBOSS @"subboss"
#define TEX_ENEMY_ROBOTBOSS @"robotboss" 

#define TEX_SWINGVINE_BASE @"SwingVineBase"
#define TEX_SWINGVINE_TEX @"SwingVineTex"
#define TEX_LABSWINGVINE_BASE @"LABSwingVineBase"

#define TEX_ELECTRIC_BODY @"electricbody"
#define TEX_ELECTRIC_BASE @"electricbase"

#define TEX_CHECKPOINT_1 @"CheckPointPre"
#define TEX_CHECKPOINT_2 @"CheckPointPost"

#define TEX_CANNONFIRE_PARTICLE @"cannonfire_default"
#define TEX_CANNONTRAIL @"cannontrail_default"

#define TEX_UI_INGAMEUI_SS @"ingame_ui_ss"

#define TEX_TUTORIAL_OBJ @"tutorial_obj"
#define TEX_TUTORIAL_ANIM_1 @"tut_anim_1"
#define TEX_TUTORIAL_ANIM_2 @"tut_anim_2"

#define TEX_NMENU_ITEMS @"nmenu_items"

#define TEX_NMENU_BGS_0 @"nmenu_bgs_0"
#define TEX_NMENU_BGS_1 @"nmenu_bgs_1"
#define TEX_NMENU_BGS_2 @"nmenu_bgs_2"
#define TEX_NMENU_BGS_3 @"nmenu_bgs_3"


#define TEX_NMENU_DOGHOUSEMASK @"doghousemask"
#define TEX_NMENU_LEVELSELOBJ @"nmenu_levelselectobj"
#define TEX_FREERUNSTARTICONS @"freerunstart_icons"

#define TEX_BLANK @"blank"

#define TEX_CLOUDGAME_BG @"cloudbg"
#define TEX_CLOUDGAME_CLOUDFLOOR @"cloudfloor"
#define TEX_CLOUDGAME_BGCLOUDS @"bgclouds"

#define TEX_CLOUDGAME_BOSS_BG @"cloudgame_boss_bg"
#define TEX_CLOUDGAME_BOSS_CLOUDFLOOR @"cloudgame_boss_cloudfloor"
#define TEX_CLOUDGAME_BOSS_BG_THUNDER @"cloudgame_boss_bg_thunder.png" 

#define TEX_CANNONMOVETRACK_BODY @"cannonmovetrack_body"
#define TEX_CANNONMOVETRACK_EDGE @"cannonmovetrack_edge"

#define TEX_CHECKERBOARD_TEXTURE @"checkerboard_texture"

#define TEX_SPOTCOS_LOGO_SS @"spotcos_logo_ss"

@end
