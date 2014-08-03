#import "WeightedSorter.h"
#import "Common.h"

@implementation WeightedSorter

+(WeightedSorter*)cons_vals:(NSDictionary *)vals use:(NSArray*)use {
	return [[WeightedSorter alloc] cons_vals:vals use:use];
}

-(id)cons_vals:(NSDictionary*)vals use:(NSArray*)use {
	buckets = [NSMutableDictionary dictionary];
	bucket_indexes = [NSMutableDictionary dictionary];
	
	for (NSString* key in use) {
		buckets[key] = [NSMutableArray array];
		bucket_indexes[key] = @0;
		
		NSDictionary *lvl_to_dif = vals[key];
		for (NSString *lvlname in lvl_to_dif) {
			[buckets[key] addObject:lvlname];
		}
		
		[buckets[key] shuffle];
		
		[buckets[key] sortUsingComparator:^(id a, id b) {
			NSNumber *va = lvl_to_dif[a];
			NSNumber *vb = lvl_to_dif[b];
			return [va compare:vb];
		}];
		
		[self somewhat_shuffle:buckets[key]];
	}
	return self;
}

-(void)somewhat_shuffle:(NSMutableArray*)tar {
	for (int i = 0; i < tar.count-1; i++) {
		if (int_random(0, 2)) {
			id a = tar[i];
			id b = tar[i+1];
			tar[i] = b;
			tar[i+1] = a;
		}
	}
}

-(NSString*)get_from_bucket:(NSString *)key {
	NSMutableArray *tar_bucket = buckets[key];
	if (tar_bucket == NULL) {
		NSLog(@"error bucket for %@ is null",key);
		return @"";
	}
	int tar_ind = ((NSNumber*)bucket_indexes[key]).intValue;
	NSString *rtv = tar_bucket[tar_ind];
	tar_ind = tar_ind+1>=tar_bucket.count?0:tar_ind+1;
	bucket_indexes[key] = [NSNumber numberWithInt:tar_ind];
	return rtv;
}

@end
