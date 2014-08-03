#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef struct Vec3D {
    float x,y,z;
} Vec3D;

@interface VecLib : NSObject
+(Vec3D) cons_x:(float)x y:(float)y z:(float)z;
+(float) rad_angle_between_a:(Vec3D)a and_b:(Vec3D)b;
+(Vec3D) add:(Vec3D)v1 to:(Vec3D)v2;
+(Vec3D) sub:(Vec3D)v from:(Vec3D)v2;
+(Vec3D) scale:(Vec3D)v by:(float)sf;
+(BOOL) eq:(Vec3D)v1 to:(Vec3D)v2;
+(Vec3D) negate:(Vec3D)v;
+(double) length:(Vec3D)v;
+(Vec3D) normalize:(Vec3D)v;
+(Vec3D) cross:(Vec3D)v1 with:(Vec3D)v2;
+(float) dot:(Vec3D)v1 with:(Vec3D)v2;
+(CGPoint) transform_pt:(CGPoint)p by:(Vec3D)v;
+(Vec3D)rotate:(Vec3D)v by_rad:(float)rad;
+(float)get_angle_in_rad:(Vec3D)v;
+(void) print:(Vec3D)v;
+(Vec3D)Z_VEC;
+(float)get_rotation:(Vec3D)dirvec offset:(float)offset;

+(Vec3D)normalized_x:(float)x y:(float)y z:(float)z;
@end
