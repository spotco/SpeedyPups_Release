#import "GroundDetail.h"
#import "GameEngineLayer.h"
#import "ObjectPool.h"

@implementation GroundDetail
@synthesize imgtype;
@synthesize img;

static NSArray* IDTOKEY;
static NSArray* ABOVE;

+(void)initialize {
	ABOVE = @[
		@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31,@32,@33,@34,@35,@36
	];
}

+(NSString*)id_to_key:(int)gid {
    if (IDTOKEY==NULL) IDTOKEY = @[
      @"",
      @"fence",
      @"sign_go",
      @"sign_dog",
      @"sign_dog2",
      @"sign_noswim",
      @"tree1",
      @"lab_light",
      @"lab_pipe",
      @"lab_pipe2",
      @"sign_vines", //10
      @"sign_warning",
      @"sign_rocks",
      @"sign_water",
      @"sign_spikes",
	  @"dogbush",
	  @"dogbush2",
	  @"dogstatue",
	  @"emptybush",
	  @"flower0",
	  @"flower1", //20
	  @"flower2",
	  @"flower3",
	  @"flower4",
	  @"flower6",
	  @"grass",
	  @"grass1",
	  @"grass2",
	  @"grass3",
	  @"mushroombush",
	  @"rock0", //30
	  @"rock1",
	  @"rock2",
	  @"rock3",
	  @"rock4",
	  @"rock5",
	  @"rock6",
	  @"roundbush",
	  @"tallbush",
	  @"tree0",
	  @"tree1", //40
	  @"tree2",
	  @"tree3",
	  @"tree4"
    ];
    return [IDTOKEY objectAtIndex:gid];
}

-(void)repool {
	if ([self class] == [GroundDetail class]) {
		[self setTexture:[Resource get_tex:TEX_BLANK]];
		[ObjectPool repool:self class:[GroundDetail class]];
	}
}

+(GroundDetail*)cons_x:(float)posx y:(float)posy type:(int)type islands:(NSMutableArray *)islands g:(GameEngineLayer *)g{
    //GroundDetail *d = [GroundDetail node];
    GroundDetail *d = [ObjectPool depool:[GroundDetail class]];
	
	d.position = ccp(posx,posy);
    
    CGRect texrect;
	if (g.world_mode.cur_world == WorldNum_3) {
		texrect = [FileCache get_cgrect_from_plist:TEX_BG3_GROUND_DETAIL_SS idname:[self id_to_key:type]];
	} else {
		texrect = [FileCache get_cgrect_from_plist:TEX_GROUND_DETAILS idname:[self id_to_key:type]];
	}
	
	CCTexture2D *tex;
	if (g.world_mode.cur_world == WorldNum_2) {
		tex = [Resource get_tex:TEX_GROUND_DETAILS_WORLD2];
	} else if (g.world_mode.cur_world == WorldNum_3) {
		tex = [Resource get_tex:TEX_BG3_GROUND_DETAIL_SS];
	} else {
		tex = [Resource get_tex:TEX_GROUND_DETAILS];
	}
	
    //d.img = [CCSprite spriteWithTexture:tex rect:texrect];
    [d.img setTexture:tex];
	[d.img setTextureRect:texrect];
	[d.img setPosition:ccp(0,texrect.size.height/2)];
    d.imgtype = type;
    //[d addChild:d.img];
    [d attach_toisland:islands];
	
    return d;
}

-(id)init {
	self = [super init];
	self.img = [CCSprite node];
	[self addChild:self.img];
	
	return self;
}

-(int)get_render_ord {
    if ([self is_above]) {
        return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];
    } else {
        return [super get_render_ord];
    }
}

-(void)check_should_render:(GameEngineLayer *)g {
    if ([Common hitrect_touch:[g get_viewbox] b:[self get_hit_rect]]) {
        do_render = YES;
    } else {
        do_render = NO;
    }
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x y1:[self position].y wid:1 hei:1];
}

-(void)attach_toisland:(NSMutableArray*)islands {
    Island* i = [self get_connecting_island:islands];
    if (i != NULL) {
        Vec3D tangent_vec = [i get_tangent_vec];
        tangent_vec=[VecLib scale:tangent_vec by:[i ndir]];
        float tar_rad = -[VecLib get_angle_in_rad:tangent_vec];
        float tar_deg = [Common rad_to_deg:tar_rad];
        img.rotation = tar_deg;
        
        tangent_vec = [VecLib normalize:tangent_vec];
        Vec3D normal_vec = [VecLib cross:[VecLib Z_VEC] with:tangent_vec];
        
        if ([self is_above]) {
            normal_vec = [VecLib scale:normal_vec by:-10];
            [self setPosition:[VecLib transform_pt:[self position] by:normal_vec]];
        } else {
			normal_vec = [VecLib scale:normal_vec by:-5];
            [self setPosition:[VecLib transform_pt:[self position] by:normal_vec]];
		}
    }
}

-(BOOL)is_above {
	return [ABOVE containsObject:[NSNumber numberWithInt:self.imgtype]];
}


@end
