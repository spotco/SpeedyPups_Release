#import "CapeGameEngineLayer.h"

@interface CreditsFlybyObject : CapeGameObject {
	CCNode *logo_base;
	BOOL do_exit;
}
+(CreditsFlybyObject*)cons_logo;
+(CreditsFlybyObject*)cons_text:(NSString*)text;
-(BOOL)has_enter;
-(void)do_exit;
-(BOOL)has_exit;
@end
