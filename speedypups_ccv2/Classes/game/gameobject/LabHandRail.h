#import "GameObject.h"

@interface LabHandRail : GameObject {
	GLRenderObject *center;
	Vec3D dir_vec;
}

+(LabHandRail*)cons_pt1:(CGPoint)pt1 pt2:(CGPoint)pt2;

@end
