#import "TrackingUtil.h"
#import "WebRequest.h"
#import "Common.h"

@implementation TrackingUtil

#define TRACKING_URL @"http://spotcos.com/SpeedyPups/track_request.php"

+(void)track_evt:(TrackingEvt)type {
	[self track_evt:type val1:@"" val2:@"" val3:@""];
}
+(void)track_evt:(TrackingEvt)type val1:(NSString*)v1 {
	[self track_evt:type val1:v1 val2:@"" val3:@""];
}
+(void)track_evt:(TrackingEvt)type val1:(NSString*)v1 val2:(NSString*)v2{
	[self track_evt:type val1:v1 val2:v2 val3:@""];
}

+(void)track_evt:(TrackingEvt)type val1:(NSString*)v1 val2:(NSString*)v2 val3:(NSString*)v3 {
	[WebRequest post_request_to:TRACKING_URL
						   vals:@{
						       @"uid":[Common unique_id],
							   @"event":strf("%d",type),
							   @"val1":v1,
							   @"val2":v2,
							   @"val3":v3
						   }
					   callback:NULL
	 ];
}

@end
