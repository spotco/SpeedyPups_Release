#import "Particle.h"

@interface ShopBuyFlyoffTextParticle : Particle {
	int ct;
	CGPoint vel;
}

+(ShopBuyFlyoffTextParticle*)cons_pt:(CGPoint)pt text:(NSString*)text;
+(ShopBuyFlyoffTextParticle*)cons_pt:(CGPoint)pt text:(NSString *)text color:(ccColor3B)_color;
@end
