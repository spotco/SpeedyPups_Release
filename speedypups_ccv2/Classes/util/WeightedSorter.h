#import <Foundation/Foundation.h>

@interface WeightedSorter : NSObject {
	NSMutableDictionary *buckets;
	NSMutableDictionary *bucket_indexes;
}

+(WeightedSorter*)cons_vals:(NSDictionary *)vals use:(NSArray*)use;
-(NSString*)get_from_bucket:(NSString*)key;

@end
