#import "cocos2d.h"
@class GameEngineLayer;
@class GameObject;
@class CSF_CCSprite;

@interface UICommon : NSObject

+(NSString*)parse_gameengine_time:(int)t;
+(void)set_zoom_pos_align:(CCSprite*)normal zoomed:(CCSprite*)zoomed scale:(float)scale;
+(CCLabelTTF*)cons_label_pos:(CGPoint)pos color:(ccColor3B)color fontsize:(int)fontsize;
+(CCMenuItemLabel*)label_cons_menuitem:(CCLabelTTF*)l leftalign:(BOOL)leftalign;
+(CCMenuItem*)cons_menuitem_tex:(CCTexture2D*)tex pos:(CGPoint)pos;

+(CGPoint)player_approx_position:(GameEngineLayer*)game_engine_layer;
+(CGPoint)game_to_screen_pos:(CGPoint)pos g:(GameEngineLayer*)g;

+(void)button:(CCNode *)btn add_desctext:(NSString *)txt color:(ccColor3B)color fntsz:(int)fntsz ;
@end

@interface MenuCurtains : CCSprite
@property(readwrite,assign) CGPoint left_curtain_tpos, right_curtain_tpos, bg_curtain_tpos;
@property(readwrite,strong) CSF_CCSprite *left_curtain, *right_curtain;
@property(readwrite,strong) CCSprite *bg_curtain;
+(MenuCurtains*)cons;
-(void)update;
-(void)set_curtain_animstart_positions;
@end