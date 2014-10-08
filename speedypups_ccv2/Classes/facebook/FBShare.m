#import "FBShare.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation FBShare

+(void)fb_log {
	[FBSettings setDefaultAppID:@"1446443165607542"];
	[FBAppEvents activateApp];
}

+(void)share {
	FBShareDialogParams *p = [[FBShareDialogParams alloc] init];
	p.link = [NSURL URLWithString:@"http://speedypups.com"];
	
	if ([FBDialogs canPresentShareDialogWithParams:p]) {
		[FBDialogs presentShareDialogWithLink:[NSURL URLWithString:@"http://speedypups.com"]
										 name:@"SpeedyPups"
									  caption:@"Like the game? Share it!"
								  description:@"The speediest and craziest platformer you'll ever play, coming soon to iOS and Android!"
									  picture:[NSURL URLWithString:@"http://speedypups.com/Icon-hr.png"]
								  clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
									  NSLog(@"lel");
								  }];
		
	} else {
	
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   @"SpeedyPups", @"name",
									   @"Like the game? Share what you think with your friends!", @"description",
									   @"http://speedypups.com", @"link",
									   @"http://speedypups.com/Icon-hr.png", @"picture",
									   nil];
		
		[FBWebDialogs presentFeedDialogModallyWithSession:nil
											   parameters:params
												  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
													  if (error) {
														  NSLog(@"Error publishing story: %@", error.description);
													  } else {
														  if (result == FBWebDialogResultDialogNotCompleted) {
															  NSLog(@"User cancelled.");
														  } else {
															  NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
															  
															  if (![urlParams valueForKey:@"post_id"]) {
																  NSLog(@"User cancelled.");
																  
															  } else {
																  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
																  NSLog(@"result %@", result);
																  
															  }
														  }
													  }
												  }];
	}
	
}
+(NSDictionary*)parseURLParams:(NSString *)query {
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
		NSString *val =
		[kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		params[kv[0]] = val;
	}
	return params;
}
@end