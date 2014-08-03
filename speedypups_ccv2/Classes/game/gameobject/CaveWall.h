
#import "GameObject.h"

@interface CaveWall : GameObject {
    GLRenderObject* tex;
    float wid,hei;
}

+(CaveWall*)cons_x:(float)x y:(float)y width:(float)width height:(float)height g:(GameEngineLayer*)g;
-(void)cons_x:(float)x y:(float)y width:(float)width height:(float)height g:(GameEngineLayer*)g;
-(CCTexture2D*)get_tex:(GameEngineLayer*)g;

@end
