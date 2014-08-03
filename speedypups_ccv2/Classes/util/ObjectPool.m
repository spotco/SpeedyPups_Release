#import "ObjectPool.h"

#import "DogBone.h"
#import "GroundDetail.h"
#import "WaveParticle.h"
#import "CloudGenerator.h"
#import "StreamParticle.h"
#import "BoneCollectUIAnimation.h"
#import "LineIsland.h"
#import "Common.h"
#import "JumpParticle.h"
#import "FireworksParticleA.h"

@interface ObjectPoolInfo : NSObject
+(ObjectPoolInfo*)cons;
-(ObjectPoolInfo*)increment_total:(int)_total used:(int)_used;
@property(readwrite,assign) int total, used;
@end

@implementation ObjectPool

#define DO_DEBUG_INFO NO

static NSMutableDictionary *class_pool;
static NSMutableDictionary *info_pool;

void prepool(Class classname, int count) {
	NSMutableArray *arr = [NSMutableArray array];
	for(int i = 0; i < count; i++) [arr addObject:[[classname alloc] init]];
	[class_pool setObject:arr forKey:NSStringFromClass(classname)];
	if (DO_DEBUG_INFO) {
		if ([info_pool objectForKey:NSStringFromClass(classname)] == NULL) [info_pool setObject:[ObjectPoolInfo cons] forKey:NSStringFromClass(classname)];
		[[info_pool objectForKey:NSStringFromClass(classname)] increment_total:count used:0];
	}
}

+(void)initialize {
	class_pool = [NSMutableDictionary dictionary];
	info_pool = [NSMutableDictionary dictionary];
}

+(void)prepool {
	prepool([DogBone class], 200);
	prepool([GroundDetail class], 100);
	prepool([WaveParticle class], 200);
	prepool([Cloud class], 50);
	prepool([StreamParticle class], 50);
	prepool([BoneCollectUIAnimation class], 30);
	prepool([LineIsland class], 200);
	prepool([CCLabelTTF_Pooled class], 35);
	prepool([JumpParticle class], 5);
	prepool([FireworksParticleA class], 15);
	prepool([SubFireworksParticleA class], 300);
}

+(id)depool:(Class)c {
	NSString *class_name = NSStringFromClass(c);
	if ([class_pool objectForKey:class_name] == NULL) [class_pool setObject:[NSMutableArray array] forKey:class_name];
	NSMutableArray *obj_pool = [class_pool objectForKey:class_name];
	
	if ([obj_pool count] == 0) {
		
		if (DO_DEBUG_INFO) {
			if ([info_pool objectForKey:class_name] == NULL) [info_pool setObject:[ObjectPoolInfo cons] forKey:class_name];
			[[info_pool objectForKey:class_name] increment_total:1 used:1];
		}
		
		return [[c alloc] init];
	}
	
	if (DO_DEBUG_INFO) {
		if ([info_pool objectForKey:class_name] == NULL) [info_pool setObject:[ObjectPoolInfo cons] forKey:class_name];
		[[info_pool objectForKey:class_name] increment_total:0 used:1];
	}
	
	id rtv = [obj_pool lastObject];
	[obj_pool removeLastObject];
	return rtv;
}

+(void)repool:(id)obj class:(Class)c {
	NSString *class_name = NSStringFromClass(c);
	if ([class_pool objectForKey:class_name] == NULL) [class_pool setObject:[NSMutableArray array] forKey:class_name];
	
	if (DO_DEBUG_INFO) {
		if ([info_pool objectForKey:class_name] == NULL) [info_pool setObject:[ObjectPoolInfo cons] forKey:class_name];
		[[info_pool objectForKey:class_name] increment_total:0 used:-1];
		
		if ([[info_pool objectForKey:class_name] used] < 0) {
			NSLog(@"ObjectPool double repool of (%@) at (%d,%d)",class_name, [[info_pool objectForKey:class_name] used], [[info_pool objectForKey:class_name] total]);
		}
	}
	
	NSMutableArray *obj_pool = [class_pool objectForKey:class_name];
	[obj_pool addObject:obj];
}

+(void)print_info {
	if (DO_DEBUG_INFO) {
		NSLog(@"--Begin [ObjectInfo print_info]--");
		for (NSString *class_name in info_pool.keyEnumerator) {
			ObjectPoolInfo *objinfo = info_pool[class_name];
			NSLog(@"   {%@ -- (%d/%d)}",class_name,objinfo.used,objinfo.total);
		}
		NSLog(@"--End [ObjectInfo print_info]--");
	}
}

@end

@implementation ObjectPoolInfo
@synthesize total,used;
+(ObjectPoolInfo*)cons { return [[ObjectPoolInfo alloc] init]; }
-(ObjectPoolInfo*)increment_total:(int)_total used:(int)_used {
	total += _total;
	used += _used;
	return self;
}
@end

