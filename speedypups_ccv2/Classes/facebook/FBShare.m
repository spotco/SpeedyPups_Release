#import "FBShare.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation FBShare

//https://github.com/fbsamples/ios-howtos/blob/master/FBShareSample/FBShareSample/ShareViewController.m
+(void)share {
	
	FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
	params.link = [NSURL URLWithString:@"http://speedypups.com"];
	
	// If the Facebook app is installed and we can present the share dialog
	if ([FBDialogs canPresentShareDialogWithParams:params]) {

		[FBDialogs presentShareDialogWithLink:params.link
									  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
										  if(error) {
											  NSLog(@"Error publishing story: %@", error.description);
										  } else {
											  [self share_confirm];
										  }
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
																  
																  [self share_confirm];
																  
															  }
														  }
													  }
												  }];
	}
	
}

+(void)share_confirm {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thanks for sharing!"
													message:@""
												   delegate:self
										  cancelButtonTitle:@"Ok"
										  otherButtonTitles:NULL];
	[alert show];
}

// A function for parsing URL parameters returned by the Feed Dialog.
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
