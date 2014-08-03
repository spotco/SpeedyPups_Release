#import "GameObject.h"

@interface TutorialLauncher : GameObject

+(TutorialLauncher*)cons_pos:(CGPoint)pos anim:(NSString*)str;

@property(readwrite,strong)NSString* anim;

@end
