#import "IntroAnim.h"
#import "Resource.h"
#import "GameMain.h"

#import "IntroAnimFrame1.h"
#import "IntroAnimFrame2.h"
#import "IntroAnimFrame3.h"
#import "IntroAnimFrame4.h"
#import "IntroAnimFrame5.h"
#import "IntroAnimFrame6.h"

@implementation IntroAnimFrame
-(void)update{}
-(BOOL)should_continue{ return YES; }
-(void)force_continue{}
+(void)set_opacity_tar:(CCNode*)tar val:(GLubyte)val {
	if ([[tar class] isSubclassOfClass:[CCSprite class]]) {
		[(CCSprite*)tar setOpacity:val];
	}
	for(CCNode *chld in [tar children]) {
		if ([[chld class] isSubclassOfClass:[CCSprite class]]) {
			CCSprite *sprite = (CCSprite*)chld;
			sprite.opacity = val;
		}
		[self set_opacity_tar:chld val:val];
	}
	
}
-(void)set_recursive_opacity:(GLubyte)opacity {
	[IntroAnimFrame set_opacity_tar:self val:opacity];
}
@end

@implementation IntroAnim

+(CCScene*)scene {
	CCScene *rtv = [CCScene node];
	[rtv addChild:[IntroAnim node]];
	CCLabelTTF *skiplabel = [Common cons_label_pos:[Common screen_pctwid:0.98 pcthei:0.02]
									   color:ccc3(0,0,0)
									fontsize:16
										 str:@"Tap Anywhere To Skip..."];
	[skiplabel setAnchorPoint:ccp(1,0)];
	[rtv addChild:skiplabel];
	return rtv;
}

-(id)init {
	self = [super init];
	frames = [NSMutableArray array];
	[self schedule:@selector(update:)];
	self.isTouchEnabled = YES;
	
	[self cons_frames];
	
	for (IntroAnimFrame *i in frames) {
		[self addChild:i];
		[i setVisible:NO];
	}
	[frames[cur_frame] setVisible:YES];
	
	transitioning_out = NO;
	transitioning_in = NO;
	force_end = NO;
	
	[AudioManager playbgm_imm:BGM_GROUP_INTRO];
	
	return self;
}

-(void)cons_frames {
	//[frames addObject:[IntroAnimFrame6 cons]];
	
	[frames addObject:[IntroAnimFrame1 cons]];
	[frames addObject:[IntroAnimFrame2 cons]];
	[frames addObject:[IntroAnimFrame3 cons]];
	[frames addObject:[IntroAnimFrame4 cons]];
	[frames addObject:[IntroAnimFrame5 cons]];
	[frames addObject:[IntroAnimFrame6 cons]];
}

-(void)update:(ccTime)dt {
    [Common set_dt:dt];
	if (!transitioning_out && !transitioning_in) {
		IntroAnimFrame *animating_frame = frames[cur_frame];
		[animating_frame update];
		if ([animating_frame should_continue]) {
			[animating_frame set_recursive_opacity:255];
			transitioning_out = YES;
		}
		
	} else if (transitioning_out) {
		IntroAnimFrame *animating_frame = frames[cur_frame];
		[animating_frame set_recursive_opacity:animating_frame.opacity-15];
		if (animating_frame.opacity <= 0) {
			[animating_frame setVisible:NO];
			cur_frame++;
			if (cur_frame < [frames count] && !force_end) {
				[frames[cur_frame] setVisible:YES];
				[(IntroAnimFrame*)frames[cur_frame] set_recursive_opacity:0];
				transitioning_out = NO;
				transitioning_in = YES;
				
			} else {
				[GameMain start_menu];
				return;
			}
		}
		
	} else if (transitioning_in) {
		IntroAnimFrame *animating_frame = frames[cur_frame];
		[animating_frame set_recursive_opacity:animating_frame.opacity+15];
		if (animating_frame.opacity >= 255) {
			transitioning_in = NO;
		}
	}
}

-(void)exit_to_menu {
    [Common unset_dt];
	[GameMain start_menu];
}

-(void) ccTouchesBegan:(NSSet*)pTouches withEvent:(UIEvent*)pEvent {
	[frames[cur_frame] force_continue];
	force_end = YES;
}

@end
