#import "cocos2d.h"

@class CallBack;
@class CSF_CCSprite;
@interface LoadingScene : CCScene {
	BOOL finished_loading;
	CallBack *on_finish;
	NSMutableArray *loading_letters;
	
	CCTexture2D *letters_tex, *paw_tex, *bg_tex, *spotcos_logo_ss;
	CSF_CCSprite *goober;
	
	int arr_anim_i;
	int anim_ct;
}

+(LoadingScene*)cons;
-(void)load_with_callback:(CallBack*)cb;

@end
