#import <Foundation/Foundation.h>
@class TexRect;
#import "FreeRunStartAtManager.h"

typedef enum {
	ChallengeType_NONE = 0,
    ChallengeType_COLLECT_BONES = 1,
    ChallengeType_TIMED = 2,
    ChallengeType_FIND_SECRET = 3,
	ChallengeType_BOSSRUSH = 4
} ChallengeType;

@interface ChallengeInfo : NSObject

+(ChallengeInfo*)cons_name:(NSString*)map_name type:(ChallengeType)type ct:(int)ct reward:(int)rw world:(WorldNum)w;
+(ChallengeInfo*)cons_name:(NSString*)map_name type:(ChallengeType)type ct:(int)ct reward:(int)rw;
@property(readwrite,strong) NSString* map_name;
@property(readwrite,assign) ChallengeType type;
@property(readwrite,assign) int ct,reward;
@property(readwrite,assign) WorldNum world;

-(NSString*)to_string;

@end

@interface ChallengeRecord : NSObject

+(TexRect*)get_for:(ChallengeType)type;
+(TexRect*)get_preview_for:(ChallengeType)type;
+(TexRect*)get_small_preview_for:(ChallengeType)type;

+(int)get_num_challenges;
+(ChallengeInfo*)get_challenge_number:(int)i;
+(int)get_number_for_challenge:(ChallengeInfo*)c;

+(BOOL)get_beaten_challenge:(int)i;
+(void)set_beaten_challenge:(int)i to:(BOOL)k;
+(int)get_highest_available_challenge;

@end