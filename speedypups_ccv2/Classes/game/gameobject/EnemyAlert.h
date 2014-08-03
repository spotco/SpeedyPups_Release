#import "GameObject.h"

@interface EnemyAlert : GameObject {
    CGPoint size;
    BOOL activated;
}

+(EnemyAlert*)cons_p1:(CGPoint)p1 size:(CGPoint)size;

@end
