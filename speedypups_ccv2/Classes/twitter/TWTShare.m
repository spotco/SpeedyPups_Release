#import "TWTShare.h"

@implementation TWTShare

+(void)share {
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://post?message=Love%20this%20game!%20www.speedypups.com%20@spotco"]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/spotco"]];
	}
}

@end
