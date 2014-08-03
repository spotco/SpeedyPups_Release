#import "ExtrasManager.h"
#import "DataStore.h" 
#import "Resource.h" 
#import "AudioManager.h" 
#import "ExtrasArtPopup.h"
#import "Common.h"
#import "FileCache.h"

@implementation ExtrasManager

static NSDictionary *names;
static NSDictionary *descs;

static NSArray *arts;
static NSArray *sfxs;
static NSArray *musics;

+(void)initialize {
	arts = @[
		EXTRAS_ART_GOOBER,
		EXTRAS_ART_MOEMOERUSH,
		EXTRAS_ART_PENGMAKU,
		EXTRAS_ART_WINDOWCLEANER,
		
		EXTRAS_ART_OLDLOGO,
		EXTRAS_ART_GANG,
		EXTRAS_ART_WORLD4_EARLY,
		EXTRAS_ART_OLDDOG,
		EXTRAS_ART_WORLD1_PROGRESS,
		EXTRAS_ART_LABASSETS,
		EXTRAS_ART_LOGOHEAD,
		EXTRAS_ART_LABENTRANCE,
		EXTRAS_ART_INTRO_FRAME1,
		EXTRAS_ART_DOGS_FINAL,
		EXTRAS_ART_LAB_FINAL,
		EXTRAS_ART_WORLD3_EARLY,
		EXTRAS_ART_SUN,
		EXTRAS_ART_WORLD5_EARLY,
		EXTRAS_ART_GOSTRICH,
		EXTRAS_ART_MENU4,
		EXTRAS_ART_MENU3,
		EXTRAS_ART_MENU2,
		EXTRAS_ART_MENU1,
		EXTRAS_ART_TUTORIAL2,
		EXTRAS_ART_TUTORIAL1,
		EXTRAS_ART_WORLD2_EARLY,
		EXTRAS_ART_WORLD1_EARLY,
		EXTRAS_ART_DOG_FINAL,
		EXTRAS_ART_ROBOTS,
		EXTRAS_ART_BOSS,
		EXTRAS_ART_ITEMS,
		EXTRAS_ART_LAB,
		EXTRAS_ART_BIRTHDAY
	];
	sfxs = @[
		SFX_FANFARE_WIN,
		SFX_FANFARE_LOSE,
		SFX_CHECKPOINT,
		SFX_WHIMPER,
		SFX_BARK_LOW,
		SFX_BARK_MID,
		SFX_BARK_HIGH,
		SFX_BOSS_ENTER,
		SFX_CAT_LAUGH,
		SFX_CAT_HIT,
		SFX_CHEER
	];
	musics = @[
		BGMUSIC_MENU1,
		BGMUSIC_INTRO,
		BGMUSIC_GAMELOOP1,
		BGMUSIC_GAMELOOP1_NIGHT,
		BGMUSIC_LAB1,
		BGMUSIC_BOSS1,
		BGMUSIC_CAPEGAMELOOP,
		BGMUSIC_JINGLE,
		BGMUSIC_GAMELOOP2,
		BGMUSIC_GAMELOOP2_NIGHT,
		BGMUSIC_GAMELOOP3,
		BGMUSIC_GAMELOOP3_NIGHT,
		BGMUSIC_INVINCIBLE
	];
	
	names = @{
		EXTRAS_ART_GOOBER: @"Jump, Goober, Jump!",
		EXTRAS_ART_MOEMOERUSH: @"MoeMoeRush!!",
		EXTRAS_ART_PENGMAKU: @"Manaic Pengmaku!",
		EXTRAS_ART_WINDOWCLEANER: @"Window Cleaner",
		
		EXTRAS_ART_OLDLOGO:@"Old Logo",
		EXTRAS_ART_GANG:@"The Gang",
		EXTRAS_ART_WORLD4_EARLY:@"World 4 Early",
		EXTRAS_ART_OLDDOG:@"Old Dog",
		EXTRAS_ART_WORLD1_PROGRESS:@"World 1 Progress",
		EXTRAS_ART_LABASSETS:@"Lab Assets",
		EXTRAS_ART_LOGOHEAD:@"Logo Head",
		EXTRAS_ART_LABENTRANCE:@"Lab Entrance",
		EXTRAS_ART_INTRO_FRAME1:@"Intro Frame 1",
		EXTRAS_ART_DOGS_FINAL:@"Dogs Final",
		EXTRAS_ART_LAB_FINAL:@"Lab Final",
		EXTRAS_ART_WORLD3_EARLY:@"World 3 Early",
		EXTRAS_ART_SUN:@"Sun",
		EXTRAS_ART_WORLD5_EARLY:@"World 5 Early",
		EXTRAS_ART_GOSTRICH:@"GoStrich",
		EXTRAS_ART_MENU4:@"Menu Mock 4",
		EXTRAS_ART_MENU3:@"Menu Mock 3",
		EXTRAS_ART_MENU2:@"Menu Mock 2",
		EXTRAS_ART_MENU1:@"Menu Mock 1",
		EXTRAS_ART_TUTORIAL2:@"Tutorial Mock 2",
		EXTRAS_ART_TUTORIAL1:@"Tutorial Mock 1",
		EXTRAS_ART_WORLD2_EARLY:@"World 2 Early",
		EXTRAS_ART_WORLD1_EARLY:@"World 1 Early",
		EXTRAS_ART_DOG_FINAL:@"OG Final",
		EXTRAS_ART_ROBOTS:@"Robots",
		EXTRAS_ART_BOSS:@"Boss",
		EXTRAS_ART_ITEMS:@"Items",
		EXTRAS_ART_LAB:@"Lab",
		EXTRAS_ART_BIRTHDAY:@"Birthday Cake!",
		
		SFX_FANFARE_WIN: @"Fanfare Win",
		SFX_FANFARE_LOSE: @"Fanfare Lose",
		SFX_CHECKPOINT: @"Checkpoint",
		SFX_WHIMPER: @"Dog Whimper",
		SFX_BARK_LOW: @"Low Bark",
		SFX_BARK_MID: @"Mid Bark",
		SFX_BARK_HIGH: @"High Bark",
		SFX_BOSS_ENTER: @"Boss Enter",
		SFX_CAT_LAUGH: @"Cat Laugh",
		SFX_CAT_HIT: @"Cat Hit",
		SFX_CHEER: @"Cheer",
		
		BGMUSIC_MENU1: @"Menu BGM",
		BGMUSIC_INTRO: @"Intro BGM",
		BGMUSIC_GAMELOOP1: @"World 1 Day BGM",
		BGMUSIC_GAMELOOP1_NIGHT: @"World 1 Night BGM",
		BGMUSIC_LAB1: @"Lab BGM",
		BGMUSIC_BOSS1: @"Boss BGM",
		BGMUSIC_CAPEGAMELOOP: @"Sky World BGM",
		BGMUSIC_JINGLE: @"Game Over Jingle",
		BGMUSIC_GAMELOOP2: @"World 2 Day BGM",
		BGMUSIC_GAMELOOP2_NIGHT: @"World 2 Night BGM",
		BGMUSIC_GAMELOOP3: @"World 3 Day BGM",
		BGMUSIC_GAMELOOP3_NIGHT: @"World 3 Night BGM",
		BGMUSIC_INVINCIBLE: @"Invincible Jingle"
	};
	
	descs = @{
		EXTRAS_ART_GOOBER: @"SPOTCO's first published game. Play online in a browser!",
		EXTRAS_ART_MOEMOERUSH: @"Made by SPOTCO in 24 hours with a few friends.",
		EXTRAS_ART_PENGMAKU: @"Made by SPOTCO for Ludum Dare 48.",
		EXTRAS_ART_WINDOWCLEANER: @"Made by SPOTCO with a few friends for CyberPunk Jam 2014.",
		
		EXTRAS_ART_OLDLOGO:@"Speedypups logo first iteration.",
		EXTRAS_ART_GANG:@"All characters group shot.",
		EXTRAS_ART_WORLD4_EARLY:@"Very early world 4 concept, somewhat inspired ingame world 2.",
		EXTRAS_ART_OLDDOG:@"Dog1 (OG) first iteration.",
		EXTRAS_ART_WORLD1_PROGRESS:@"World 1 decorations iterations.",
		EXTRAS_ART_LABASSETS:@"Lab decorations iterations.",
		EXTRAS_ART_LOGOHEAD:@"Animation frames for bouncing head in logo.",
		EXTRAS_ART_LABENTRANCE:@"World 1 Lab Entrance concept art.",
		EXTRAS_ART_INTRO_FRAME1:@"First frame in intro cartoon.",
		EXTRAS_ART_DOGS_FINAL:@"Final designs for all seven dogs.",
		EXTRAS_ART_LAB_FINAL:@"Lab 1 concept art.",
		EXTRAS_ART_WORLD3_EARLY:@"Very early world 3 concept, somewhat inspired ingame world 2.",
		EXTRAS_ART_SUN:@"Concept art, used in the intro cartoon.",
		EXTRAS_ART_WORLD5_EARLY:@"Early world 5 concept. Didn't make it ingame.",
		EXTRAS_ART_GOSTRICH:@"This game started with running ostriches. That didn't go far.",
		EXTRAS_ART_MENU4:@"Initial menu mockup for inventory window.",
		EXTRAS_ART_MENU3:@"Initial menu mockup for character select page.",
		EXTRAS_ART_MENU2:@"Initial menu mockup for shop page.",
		EXTRAS_ART_MENU1:@"Initial menu mockup for initial 'play' page.",
		EXTRAS_ART_TUTORIAL2:@"Unused ingame tutorial concept.",
		EXTRAS_ART_TUTORIAL1:@"Ingame tutorial concept art and mockup.",
		EXTRAS_ART_WORLD2_EARLY:@"Early world 2 (snow world) concept. Refined and used in final game.",
		EXTRAS_ART_WORLD1_EARLY:@"Early world 1 art, refined and used in main game.",
		EXTRAS_ART_DOG_FINAL:@"Dog1 (OG) final designs, highres.",
		EXTRAS_ART_ROBOTS:@"Cat robots final designs.",
		EXTRAS_ART_BOSS:@"Boss 1 battle mockup.",
		EXTRAS_ART_ITEMS:@"Ingame powerup design sheet.",
		EXTRAS_ART_LAB:@"Lab 1 concept art.",
		EXTRAS_ART_BIRTHDAY:@"Birthday Cake!",
		
		SFX_FANFARE_WIN: @"Fanfare that plays on success.",
		SFX_FANFARE_LOSE: @"Fanfare that plays on failure.",
		SFX_CHECKPOINT: @"Checkpoint sound.",
		SFX_WHIMPER: @"Dog whimpering sound",
		SFX_BARK_LOW: @"Bark for Husky and Lab.",
		SFX_BARK_MID: @"Bark for Mutt and Dalmation.",
		SFX_BARK_HIGH: @"Bark for Corgi, Poodle and Pug.",
		SFX_BOSS_ENTER: @"Menacing boss enter cry, taken from Goober.",
		SFX_CAT_LAUGH: @"Evil cat laugh.",
		SFX_CAT_HIT: @"Cat gets hit!",
		SFX_CHEER: @"Cheers! Taken from Goober.",
		
		BGMUSIC_MENU1: @"Main menu music, by Joshua Kaplan.",
		BGMUSIC_INTRO: @"Music for intro cartoon, by Joshua Kaplan.",
		BGMUSIC_GAMELOOP1: @"Music for world 1 daytime, by Joshua Kaplan.",
		BGMUSIC_GAMELOOP1_NIGHT: @"Music for world 1 nighttime, by Joshua Kaplan.",
		BGMUSIC_LAB1: @"Music for labs, by Joshua Kaplan.",
		BGMUSIC_BOSS1: @"Music for boss battle, by Joshua Kaplan.",
		BGMUSIC_CAPEGAMELOOP: @"Music for cape minigame, by Joshua Kaplan.",
		BGMUSIC_JINGLE: @"Jingle that plays on game over, by Joshua Kaplan.",
		BGMUSIC_GAMELOOP2: @"Music for world 2 daytime, by Joshua Kaplan.",
		BGMUSIC_GAMELOOP2_NIGHT: @"Music for world 2 nighttime, by Joshua Kaplan.",
		BGMUSIC_GAMELOOP3: @"Music for world 3 daytime, by Joshua Kaplan.",
		BGMUSIC_GAMELOOP3_NIGHT: @"Music for world 3 nighttime, by Joshua Kaplan.",
		BGMUSIC_INVINCIBLE: @"Jingle that plays on invincible, by Joshua Kaplan."
	};
}

+(Extras_Type)type_for_key:(NSString*)key {
	if ([arts containsObject:key]) {
		return Extras_Type_ART;
	} else if ([musics containsObject:key]) {
		return Extras_Type_MUSIC;
	} else {
		return Extras_Type_SFX;
	}
}

+(TexRect*)texrect_for_type:(Extras_Type)type {
	return [TexRect cons_tex:[Resource get_tex:TEX_NMENU_ITEMS]
						rect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:
							  type == Extras_Type_ART?  @"extrasicon_art":
							  type == Extras_Type_MUSIC?  @"extrasicon_music":
							  @"extrasicon_sfx"]];
}

+(NSString*)name_for_key:(NSString*)key {
	NSString *rtv = [names objectForKey:key];
	return rtv ? rtv : @"???";
}

+(NSString*)desc_for_key:(NSString*)key {
	NSString *rtv = [descs objectForKey:key];
	return rtv ? rtv : @"???";
}

+(BOOL)own_extra_for_key:(NSString*)key {
	return [DataStore get_int_for_key:key];
}

+(void)set_own_extra_for_key:(NSString*)key {
	[DataStore set_key:key int_value:1];
}

+(NSMutableArray*)all_extras {
	NSMutableArray *rtv = [NSMutableArray array];
	for (NSString *key in names.keyEnumerator) [rtv addObject:key];
	return rtv;
}

+(NSString*)random_unowned_extra {
	NSMutableArray *all_extras = [self all_extras];
	[all_extras shuffle];
	while ([all_extras count] > 0) {
		if (![self own_extra_for_key:all_extras.lastObject]) {
			return all_extras.lastObject;
		}
		[all_extras removeLastObject];
	}
	return NULL;
}
@end
