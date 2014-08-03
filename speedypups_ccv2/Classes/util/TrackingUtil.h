#import <Foundation/Foundation.h>

typedef enum TrackingEvt {
	TrackingEvt_Login = 0,
	TrackingEvt_PlayFreeRun = 1,
	TrackingEvt_PlayChallenge = 2,
	TrackingEvt_ChallengeComplete = 3,
	TrackingEvt_GameEnd = 4,
	TrackingEvt_ShopBuy = 5,
	TrackingEvt_SpinWheel = 6,
	TrackingEvt_Reset = 7
} TrackingEvt;

@interface TrackingUtil : NSObject
+(void)track_evt:(TrackingEvt)type;
+(void)track_evt:(TrackingEvt)type val1:(NSString*)v1;
+(void)track_evt:(TrackingEvt)type val1:(NSString*)v1 val2:(NSString*)v2;
+(void)track_evt:(TrackingEvt)type val1:(NSString*)v1 val2:(NSString*)v2 val3:(NSString*)v3;

@end
