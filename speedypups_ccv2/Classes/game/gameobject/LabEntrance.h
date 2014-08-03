#import "GameObject.h"
#import "GEventDispatcher.h"

@interface LabEntrance : GameObject {
    GameObject *afg_area;
    GLRenderObject *back_body,*ceil_edge,*ceil_body;
    BOOL activated;
}

+(LabEntrance*)cons_pt:(CGPoint)pt;
-(id)cons_pt:(CGPoint)pt;
-(BOOL)get_do_render;
-(void)entrance_event;
@end

@interface LabEntranceFG : GameObject {
    GLRenderObject *front_body;
    LabEntrance* base;
    
}
+(LabEntranceFG*)cons_pt:(CGPoint)pt base:(LabEntrance*)base;
@end
