#import "Blocker.h"
#import "GameRenderImplementation.h"

@interface CameraArea : Blocker {
    CameraZoom tar;
}

+(CameraArea*)cons_x:(float)x y:(float)y wid:(float)wid hei:(float)hei zoom:(CameraZoom)czoom;

@end
