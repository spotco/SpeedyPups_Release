#import "GameObject.h"

typedef struct shadowinfo {
    float y,dist,rotation;
} shadowinfo;

@interface DogShadow : GameObject {
    BOOL surfg;
}
+(DogShadow*)cons;
@end

@interface ObjectShadow : GameObject {
    GameObject* tar;
}
+(ObjectShadow*)cons_tar:(GameObject*)o;
-(void)cons_body;
-(void)update_scale:(shadowinfo)v;
@end