#import "GameObject.h"
@class TutorialAnim;
#import "GEventDispatcher.h"

typedef enum {
    TutorialProf_FLYIN,
    TutorialProf_MESSAGE,
    TutorialProf_FLYOUT
} TutorialProfState;

@interface TutorialProf : GameObject <GEventListener> {
    CSF_CCSprite *body,*messagebubble;
    TutorialAnim *messageanim;
    CGPoint vibration,START,TAR,curpos;
    float vibration_ct;
    TutorialProfState curstate;
    
    GameObject *shadow;
    
    int ct;
}

+(TutorialProf*)cons_msg:(NSString *)msg y:(float)y;

+(NSString*)msg_for_tutorial:(NSString*)tut;

@end
