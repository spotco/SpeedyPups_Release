#import <Foundation/Foundation.h>
#import <iAd/iAd.h>

@interface iAds_integration : NSObject <ADBannerViewDelegate>
-(id)init_landscape_bottom;
-(void)onEnter;
-(void)onExit;
-(void)setVisible:(BOOL)v;
@end
