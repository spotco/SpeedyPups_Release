#import "MainMenuLayer.h"

@interface NMenuCharSelectPage : NMenuPage <GEventListener> {
    CCSprite* dog_spr,*spotlight;
    CCMenu *controlm;
	CCMenuItem *select;
    int cur_dog;
    
    //CCLabelTTF *infodesc;
    CCSprite *available_disp;
    CCLabelTTF *name_disp;
    CCLabelTTF *power_disp;
    
    CCSprite *locked_disp;
    
    bool kill;
	
	CCMenu *nav_menu;
	float charselfbutton_anim_scale;
}

+(NMenuCharSelectPage*)cons;

@end
