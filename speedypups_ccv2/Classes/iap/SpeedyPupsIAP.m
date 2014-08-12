#import "SpeedyPupsIAP.h"
#import "DataStore.h"
#import "Common.h"
#import "UserInventory.h"

@implementation IAPObject
@synthesize identifier, name, desc;
@synthesize price;
@synthesize product;
@end

@implementation SpeedyPupsIAP

#define IAP_DATASTORE_KEY(str) [NSString stringWithFormat:@"IAP_OWNED_%@",str]

static NSMutableArray *iap_objects;

+(void)preload {
	iap_objects = [NSMutableArray array];
	[[IAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
		NSLog(@"BEGIN IAP");
		for (SKProduct *i in products) {
			IAPObject *o = [[IAPObject alloc] init];
			o.identifier = i.productIdentifier;
			o.name = i.localizedTitle;
			o.desc = i.localizedDescription;
			o.price = i.price;
			o.product = i;
			[iap_objects addObject:o];
			
			NSLog(@"IAP %@,%@,%@",o.identifier,o.name,o.desc);
		}
	}];
}

+(void)content_for_key:(NSString*)key {
	if (streq(key, SPEEDYPUPS_AD_FREE)) {
		if ([DataStore get_int_for_key:IAP_DATASTORE_KEY(SPEEDYPUPS_AD_FREE)] == 0) {
			[UserInventory add_coins:10];
		}
		[UserInventory set_ads_disabled:YES];
		[DataStore set_key:IAP_DATASTORE_KEY(SPEEDYPUPS_AD_FREE) int_value:1];
		
	} else if (streq(key, SPEEDYPUPS_10_COINS)) {
		[UserInventory add_coins:10];
	}
}

+(SKProduct*)product_for_key:(NSString*)key {
	for (IAPObject *i in iap_objects) {
		if (streq(key, i.identifier)) {
			return i.product;
		}
	}
	return NULL;
}

+(NSSet*)get_all_requested_iaps {
#ifdef ANDROID
	return [NSSet setWithObjects:SPEEDYPUPS_AD_FREE, SPEEDYPUPS_10_COINS,nil];
#else
	return [NSSet setWithObjects:SPEEDYPUPS_AD_FREE, SPEEDYPUPS_10_COINS,nil];
#endif
}

+(NSArray*)get_all_loaded_iaps {
	return iap_objects;
}

@end
