#import "CameraArea.h"
#import "GameEngineLayer.h"

@implementation CameraArea

+(CameraArea*)cons_x:(float)x y:(float)y wid:(float)wid hei:(float)hei zoom:(CameraZoom)czoom {
    CameraArea* a = [CameraArea node];
    [a cons_x:x y:y width:wid height:hei];
    [a set_tar:czoom];
    return a;
}

-(void)set_tar:(CameraZoom)c {
    //NSLog(@"(%f,%f,%f)",c.x,c.y,c.z);
    tar = c;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (!active) {
        return;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        [g set_target_camera:tar];
    }
    
    return;
}

@end
