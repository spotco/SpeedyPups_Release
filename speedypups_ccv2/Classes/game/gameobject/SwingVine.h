#import "GameObject.h"

@interface SwingVine : GameObject {
    CCSprite* vine;
    CCSprite* headcov;
    
    CGPoint ins_offset;
    
    float vr;
    
    float length;
    
    float cur_dist;
    
    int disable_timer;
}

+(SwingVine*)cons_x:(float)x y:(float)y len:(float)len;
-(void)temp_disable;
-(CGPoint)get_tangent_vel;

@end
