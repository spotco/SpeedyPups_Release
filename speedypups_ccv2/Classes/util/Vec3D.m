#import "Vec3D.h"
#import "Common.h"

@implementation VecLib

+(Vec3D)Z_VEC {
    return [VecLib cons_x:0 y:0 z:1];
}

+(Vec3D) cons_x:(float)x y:(float)y z:(float)z {
    struct Vec3D v;
    v.x = x;
    v.y = y;
    v.z = z;
    return v;
}

+(float) rad_angle_between_a:(Vec3D)a and_b:(Vec3D)b {
    return acosf([VecLib dot:a with:b]/([VecLib length:a]*[VecLib length:b]));
}


+(Vec3D) add:(Vec3D)v1 to:(Vec3D)v2  {
    return [VecLib cons_x:(v1.x + v2.x) y:(v1.y+v2.y) z:(v1.z+v2.z)];
}

+(Vec3D) sub:(Vec3D)v1 from:(Vec3D)v2  {
    return [VecLib cons_x:(v2.x + v1.x) y:(v2.y+v1.y) z:(v2.z+v1.z)];
}


+(Vec3D)scale:(Vec3D)v by:(float)sf{
    v.x *= sf;
    v.y *= sf;
    v.z *= sf;
    return v;
}

+(BOOL)eq:(Vec3D)v1 to:(Vec3D)v2 {
    return v1.x == v2.x && v1.y == v2.y && v1.z == v2.z;
}

+(Vec3D)negate:(Vec3D)v {
    v.x = -v.x;
    v.y = -v.y;
    v.z = -v.z;
    return v;
}

+(double) length:(Vec3D)v {
    return sqrt((v.x * v.x) + (v.y * v.y) + (v.z * v.z));
}

+(Vec3D) normalize:(Vec3D)v {
    float len = [VecLib length:v];
	if (len == 0) len = 0.0001;
    v.x /= len;
    v.y /= len;
    v.z /= len;
    return v;
}

+(Vec3D) cross:(Vec3D)v1 with:(Vec3D)a{
	float x1, y1, z1;
    x1 = (v1.y*a.z) - (a.y*v1.z);
    y1 = -((v1.x*a.z) - (v1.z*a.x));
    z1 = (v1.x*a.y) - (a.x*v1.y);
    return [VecLib cons_x:x1 y:y1 z:z1];
}

+(float) dot:(Vec3D)v1 with:(Vec3D)a{
	return ( v1.x * a.x ) + ( v1.y * a.y ) + ( v1.z * a.z );
}

+(CGPoint) transform_pt:(CGPoint)p by:(Vec3D)v{
    return ccp(p.x+v.x,p.y+v.y);
}

+(fCGPoint) ftransform_pt:(fCGPoint)p by:(Vec3D)v{
    return fccp(p.x+v.x,p.y+v.y);
}

+(Vec3D)rotate:(Vec3D)v by_rad:(float)rad {
    float mag = [VecLib length:v];
    float ang = atan2f(v.y, v.x);
    ang += rad;
    return [VecLib cons_x:mag*cos(ang) y:mag*sin(ang) z:v.z];
}

+(float)get_angle_in_rad:(Vec3D)v {
    return atan2f(v.y,v.x);
}

+(void) print:(Vec3D)v {
    NSLog(@"<%f,%f,%f>",v.x,v.y,v.z);
}

+(Vec3D)normalized_x:(float)x y:(float)y z:(float)z {
    float len = sqrt((x * x) + (y * y) + (z * z));
	if (len == 0) len = 0.0001;
    return [VecLib cons_x:x/len y:y/len z:z/len];
}

+(float)get_rotation:(Vec3D)dirvec offset:(float)offset {
	float ccwt = [Common rad_to_deg:[VecLib get_angle_in_rad:dirvec]+offset];
	return ccwt > 0 ? 180-ccwt : -(180-ABS(ccwt));
}

@end
