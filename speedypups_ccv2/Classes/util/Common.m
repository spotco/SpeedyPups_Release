#import "Common.h"
#import "Island.h"
#import "GameRenderImplementation.h"
#import "GameMain.h"
#import "ObjectPool.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "CoreFoundation/CoreFoundation.h"

@implementation CSF_CCSprite {
	CGPoint _scf;
}

-(id)init {
	self = [super init];
	[self csf_setScale:1];
	return self;
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect {
	self = [super initWithTexture:texture rect:rect];
	[self csf_setScale:1];
	return self;
}

-(void)csf_setScale:(float)scale {
	_scf = ccp(scale,scale);
	[self setScale:_scf.x * CC_CONTENT_SCALE_FACTOR()];
}

-(float)csf_scale { return _scf.x; }
-(float)csf_scaleX { return _scf.x; }
-(float)csf_scaleY { return _scf.y; }

-(void)csf_setScaleX:(float)s {
	_scf.x = s;
	[super setScaleX:_scf.x * CC_CONTENT_SCALE_FACTOR()];
}

-(void)csf_setScaleY:(float)s {
	_scf.y = s;
	[super setScaleY:_scf.y * CC_CONTENT_SCALE_FACTOR()];
}

@end


float drp(float a, float b, float div) {
	return a + (b - a) / div;
}

float lerp(float a, float b, float t) {
	return a + (b - a) * t;
}

@implementation CCSprite_VerboseDealloc
-(void)dealloc {
	NSLog(@"%@ verbose_dealloc",[self class]);
}
@end

@implementation CCLabelTTF_Pooled
-(void)repool {
	if ([self class] == [CCLabelTTF_Pooled class]) [ObjectPool repool:self class:[CCLabelTTF_Pooled class]];
}
@end

@implementation CallBack
@synthesize selector;
@synthesize target;
@end

@implementation GLRenderObject
    @synthesize isalloc,pts;
    @synthesize texture;
    -(fCGPoint*)tex_pts {return tex_pts;}
    -(fCGPoint*)tri_pts {return tri_pts;}
@end

fCGPoint fCGPointMake(float x, float y){
	fCGPoint rtv;
	rtv.x = x;
	rtv.y = y;
	return rtv;
}

@implementation TexRect
@synthesize tex;
@synthesize rect;
+(TexRect*)cons_tex:(CCTexture2D *)tex rect:(CGRect)rect {
    TexRect *r = [[TexRect alloc] init]; [r setTex:tex]; [r setRect:rect]; return r;
}
@end

@implementation NSArray (Random)
-(id)random {
	uint32_t rnd = (uint32_t)arc4random_uniform((u_int32_t)[self count]);
	return [self objectAtIndex:rnd];
}
-(BOOL)contains_str:(NSString *)tar {
	for (id i in self) {
		if ([i isEqualToString:tar]) return YES;
	}
	return NO;
}
-(NSArray*)copy_removing:(NSArray *)a {
	NSMutableArray *n = [NSMutableArray array];
	for (id i in self) {
		if (![a containsObject:i]) [n addObject:i];
	}
	return n;
}
-(id)get:(int)i {
	if (i >= [self count]) {
		return NULL;
	} else {
		return [self objectAtIndex:i];
	}
}
@end

@implementation NSMutableArray (Shuffle)
-(void)shuffle {
	for (NSUInteger i = [self count] - 1; i >= 1; i--){
		u_int32_t j = (uint32_t)arc4random_uniform((u_int32_t)i + 1);
		[self exchangeObjectAtIndex:j withObjectAtIndex:i];
	}
}
@end

@implementation Common

NSString* strf (char* format, ... ) {
    char outp[255];
    va_list a_list;
    va_start( a_list, format );
    vsprintf(outp, format, a_list);
    va_end(a_list);
    return [NSString stringWithUTF8String:outp];
}

int SIG(float n) {
    if (n > 0) {
        return 1;
    } else if (n < 0) {
        return -1;
    } else {
        return 0;
    }
}

inline CGPoint CGPointAdd(CGPoint a,CGPoint b) {
    return ccp(a.x+b.x,a.y+b.y);
}

int pb(int base,float pctm) {return base+(255-base)*pctm;}
ccColor3B PCT_CCC3(int R,int G,int B,float PCTM) { return ccc3(pb(R,PCTM),pb(G,PCTM),pb(B,PCTM)); }

inline float CGPointDist(CGPoint a,CGPoint b) {
    return sqrtf(powf(a.x-b.x, 2)+powf(a.y-b.y, 2));
}

static BOOL has_set_sdt = NO;
static ccTime sdt = 1;
static ccTime last_sdt = 1;
+(void)set_dt:(ccTime)dt {
	if (!has_set_sdt) {
		has_set_sdt = YES;
		sdt = dt;
		last_sdt = dt;
		return;
	}

	last_sdt = sdt;
	sdt = dt;
	if (ABS(sdt-last_sdt) > 0.01) {
		sdt = last_sdt + 0.01 * SIG(sdt-last_sdt);
	}
}

+(void)unset_dt {
	has_set_sdt = NO;
}

+(float)get_dt_Scale {
	if ([GameMain GET_DO_CONSTANT_DT] || [CCDirectorDisplayLink is_framemodct_modified]) return 1;
	//return clampf(sdt/(1/60.0f), 0.25, 10);
	return clampf(sdt/(1/60.0f), 0.25, 3);
}

+(CGSize)SCREEN {
    return CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
}

+(CGPoint)screen_pctwid:(float)pctwid pcthei:(float)pcthei {
    return ccp([Common SCREEN].width*pctwid,[Common SCREEN].height*pcthei);
}

+(void)run_callback:(CallBack*)c {
    if (c.target != NULL) {
        [c.target performSelector:c.selector];
    } else {
        NSLog(@"callback target is null");
    }
}

+(CallBack*)cons_callback:(NSObject*)tar sel:(SEL)sel {
    CallBack* cb = [[CallBack alloc] init];
    cb.target = tar;
	cb.selector = sel;
    return cb;
}

+(HitRect)hitrect_cons_x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 {
    struct HitRect n;
    n.x1 = x1;
    n.y1 = y1;
    n.x2 = x2;
    n.y2 = y2;
    return n;
}

+(HitRect)hitrect_cons_x1:(float)x1 y1:(float)y1 wid:(float)wid hei:(float)hei {
    return [Common hitrect_cons_x1:x1 y1:y1 x2:x1+wid y2:y1+hei];
}

+(CGRect)hitrect_to_cgrect:(HitRect)rect {
    return CGRectMake(rect.x1, rect.y1, rect.x2-rect.x1, rect.y2-rect.y1);
}

+(CGPoint*)hitrect_get_pts:(HitRect)rect {
    CGPoint *pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
//    pts[0] = ccp(rect.x1,rect.y1);
//    pts[1] = ccp(rect.x1+(rect.x2-rect.x1),rect.y1);
//    pts[2] = ccp(rect.x2,rect.y2);
//    pts[3] = ccp(rect.x1,rect.y1+(rect.y2-rect.y1));
    
    pts[0] = ccp(rect.x1,rect.y1);
    pts[1] = ccp(rect.x2,rect.y1);
    pts[2] = ccp(rect.x2,rect.y2);
    pts[3] = ccp(rect.x1,rect.y2);

    return pts;
    
}

+(BOOL)hitrect_touch:(HitRect)r1 b:(HitRect)r2 {
    return !(r1.x1 > r2.x2 ||
             r2.x1 > r1.x2 ||
             r1.y1 > r2.y2 ||
             r2.y1 > r1.y2);
}

+(CGPoint)line_seg_intersection_a1:(CGPoint)a1 a2:(CGPoint)a2 b1:(CGPoint)b1 b2:(CGPoint)b2 {//2 line segment intersection (seg a1,a2) (seg b1,b2)
    CGPoint null_point = CGPointMake([Island NO_VALUE], [Island NO_VALUE]);
    double Ax = a1.x; double Ay = a1.y;
	double Bx = a2.x; double By = a2.y;
	double Cx = b1.x; double Cy = b1.y;
	double Dx = b2.x; double Dy = b2.y;
	double X; double Y;
	double  distAB, theCos, theSin, newX, ABpos ;
	
	if ((Ax==Bx && Ay==By) || (Cx==Dx && Cy==Dy)) return null_point; //  Fail if either line segment is zero-length.
    
	Bx-=Ax; By-=Ay;//Translate the system so that point A is on the origin.
	Cx-=Ax; Cy-=Ay;
	Dx-=Ax; Dy-=Ay;
	
	distAB=sqrt(Bx*Bx+By*By);//Discover the length of segment A-B.
	
	theCos=Bx/distAB;//Rotate the system so that point B is on the positive X axis.
	theSin=By/distAB;
    
	newX=Cx*theCos+Cy*theSin;
	Cy  =Cy*theCos-Cx*theSin; Cx=newX;
	newX=Dx*theCos+Dy*theSin;
	Dy  =Dy*theCos-Dx*theSin; Dx=newX;
	
	if ((Cy<0. && Dy<0.) || (Cy>=0. && Dy>=0.)) return null_point;//C-D must be origin crossing line
	
	ABpos=Dx+(Cx-Dx)*Dy/(Dy-Cy);//Discover the position of the intersection point along line A-B.
	
    
	if (ABpos<0. || /*ABpos>distAB*/ fm_a_gt_b(ABpos, distAB, 0.001)) {
        return null_point;//  Fail if segment C-D crosses line A-B outside of segment A-B.
	}
        
	X=Ax+ABpos*theCos;//Apply the discovered position to line A-B in the original coordinate system.
	Y=Ay+ABpos*theSin;
	
	return ccp(X,Y);
}
/*
 line_seg player_mov = [Common cons_line_seg_a:ccp(0,0) b:ccp(0,1)];
 line_seg a1 = [Common cons_line_seg_a:ccp(-1,0) b:ccp(0,0)];
 line_seg a2 = [Common cons_line_seg_a:ccp(1,0) b:ccp(0,0)];
 CGPoint i1 = [Common line_seg_intersection_a:player_mov b:a1];
 CGPoint i2 = [Common line_seg_intersection_a:player_mov b:a2];
 NSLog(@"a1:(%f,%f) a2:(%f,%f)",i1.x,i1.y,i2.x,i2.y);
 */

bool fm_a_gt_b(double a,double b,double delta) {
    return a-b > delta;
}

+(CGPoint)line_seg_intersection_a:(line_seg)a b:(line_seg)b {
    return [Common line_seg_intersection_a1:a.a a2:a.b b1:b.a b2:b.b];
}

+(line_seg)cons_line_seg_a:(CGPoint)a b:(CGPoint)b {
    struct line_seg new;
    new.a = a;
    new.b = b;
    return new;
}

+(BOOL)point_fuzzy_on_line_seg:(line_seg)seg pt:(CGPoint)pt {
    Vec3D b_m_a = [VecLib cons_x:seg.b.x-seg.a.x y:seg.b.y-seg.a.y z:0];
    Vec3D c_m_a = [VecLib cons_x:pt.x-seg.a.x y:pt.y-seg.a.y z:0];
    Vec3D ab_c_ac = [VecLib cross:b_m_a with:c_m_a];
    
    float val = [VecLib length:ab_c_ac] / [VecLib length:b_m_a];
    if (val <= 0.1) {
        return YES;
    } else {
        return NO;
    }
}

+(void)print_hitrect:(HitRect)l msg:(NSString*)msg {
    NSLog(@"%@ line segment (%f,%f) to (%f,%f)",msg,l.x1,l.y1,l.x2,l.y2);
}
+(NSString*)hitrect_to_string:(HitRect)r {
    return NSStringFromCGRect([Common hitrect_to_cgrect:r]);
}

+(void)print_line_seg:(line_seg)l msg:(NSString*)msg {
    NSLog(@"%@ line segment (%f,%f) to (%f,%f)",msg,l.a.x,l.a.y,l.b.x,l.b.y);
}

+(BOOL)pt_fuzzy_eq:(CGPoint)a b:(CGPoint)b {
    return [Common fuzzyeq_a:a.x b:b.x delta:0.1] && [Common fuzzyeq_a:a.y b:b.y delta:0.1]; //return ABS(a.x-b.x) <= 0.1 && ABS(a.y-b.y) <= 0.1;
}

+(BOOL)fuzzyeq_a:(float)a b:(float)b delta:(float)delta {
    return ABS(a-b) <= delta;
}

+(float)deg_to_rad:(float)degrees {
    return degrees * M_PI / 180.0;
}

+(float)rad_to_deg:(float)rad {
    return rad * 180.0 / M_PI;
}

+(float)shortest_dist_from_cur:(float)a1 to:(float)a2 {
    a1 = [Common deg_to_rad:a1];
    a2 = [Common deg_to_rad:a2];
    float res = atan2f(cosf(a1)*sinf(a2)-sinf(a1)*cosf(a2),
                       sinf(a1)*sinf(a2)+cosf(a1)*cosf(a2));
    
    res = [Common rad_to_deg:res];
    return res;
}

+(float)sig:(float)n {
    if (n > 0) {
        return 1;
    } else if (n < 0) {
        return -1;
    } else {
        return 0;
    }
}


+(GLRenderObject*)neu_cons_render_obj:(CCTexture2D*)tex npts:(int)npts {
    GLRenderObject *n = [[GLRenderObject alloc] init];
    n.texture = tex;
    n.isalloc = 1;
    n.pts = npts;
    return n;
}

+(GLRenderObject*)cons_render_obj:(CCTexture2D*)tex npts:(int)npts obj:(GLRenderObject *)obj {
	obj.texture = tex;
	obj.isalloc = 1;
	obj.pts = npts;
	return obj;
}

+(void)draw_renderobj:(GLRenderObject*)obj n_vtx:(int)n_vtx {
	/*
    glBindTexture(GL_TEXTURE_2D, obj.texture.name);
	glVertexPointer(2, GL_FLOAT, 0, obj.tri_pts);
	glTexCoordPointer(2, GL_FLOAT, 0, obj.tex_pts);
    
    
    if (n_vtx == 4) {
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    } else {
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }*/
	
	CCGLProgram *prog = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture];
	[prog use];
	[prog setUniformsForBuiltins];
	
	ccGLBindTexture2D( obj.texture.name );
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords);
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, sizeof(fCGPoint), obj.tri_pts);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, sizeof(fCGPoint), obj.tex_pts);
	glDrawArrays(GL_TRIANGLES, 0, 3);
	if (n_vtx == 4) glDrawArrays(GL_TRIANGLES, 1, 3);
}

+(void)tex_map_to_tri_loc:(GLRenderObject*)o len:(int)len {
    for (int i = 0; i < len; i++) {
        o.tex_pts[i] = fccp(o.tri_pts[i].x/o.texture.pixelsWide, o.tri_pts[i].y/o.texture.pixelsHigh);
    }
}

+(CGRect)ssrect_from_dict:(NSDictionary*)dict tar:(NSString*)tar {    
    NSDictionary *frames_dict = [dict objectForKey:@"frames"];
    NSDictionary *obj_info = [frames_dict objectForKey:tar];
    NSString *txt = [obj_info objectForKey:@"textureRect"];
    CGRect r = CGRectFromString(txt);
    return r;
}

+(CCAction*)make_anim_frames:(NSArray*)animFrames speed:(float)speed {
	id animate = [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:animFrames delay:speed] restoreOriginalFrame:YES];
    id m = [CCRepeatForever actionWithAction:animate];
	return m;
}

+(CGFloat) distanceBetween: (CGPoint)point1 and: (CGPoint)point2 {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
}

+(CCMenuItem*)make_button_tex:(CCTexture2D*)tex seltex:(CCTexture2D*)seltex zscale:(float)zscale callback:(CallBack*)cb pos:(CGPoint)pos {
    CCSprite *img = [CCSprite spriteWithTexture:tex];
    CCSprite *img_zoom = [CCSprite spriteWithTexture:seltex];
    [Common set_zoom_pos_align:img zoomed:img_zoom scale:zscale];
    CCMenuItem* i = [CCMenuItemImage itemFromNormalSprite:img selectedSprite:img_zoom target:cb.target selector:cb.selector];
    [i setPosition:pos];
    return i;
}

+(void)set_zoom_pos_align:(CCSprite*)normal zoomed:(CCSprite*)zoomed scale:(float)scale {
    zoomed.scale = scale;
    zoomed.position = ccp((-[zoomed contentSize].width * zoomed.scale + [zoomed contentSize].width)/2
                          ,(-[zoomed contentSize].height * zoomed.scale + [zoomed contentSize].height)/2);
}

+(CCLabelTTF*)cons_label_pos:(CGPoint)pos color:(ccColor3B)color fontsize:(int)fontsize str:(NSString*)str {
    CCLabelTTF *l = [CCLabelTTF labelWithString:str fontName:@"Carton Six" fontSize:fontsize];
    [l setColor:color];
    [l setPosition:pos];
    return l;
}

+(CCLabelBMFont*)cons_bmlabel_pos:(CGPoint)pos color:(ccColor3B)color fontsize:(int)fontsize str:(NSString*)str {
	CCLabelBMFont *rtv;
	if (fontsize >= 22) {
		rtv = [CCLabelBMFont labelWithString:str fntFile:@"carton_six_30.fnt"];
		[rtv setScale:fontsize/30.0];
	} else {
		rtv = [CCLabelBMFont labelWithString:str fntFile:@"carton_six_13.fnt"];
		[rtv setScale:fontsize/13.0];
	}
	[rtv setColor:color];
	[rtv setPosition:pos];
	return rtv;
}

+(CCLabelBMFont*)cons_bm_multiline_label_str:(NSString*)str width:(float)width alignment:(UITextAlignment)alignment fontsize:(int)fontsize {
	CCLabelBMFont *rtv = [CCLabelBMFont labelWithString:str fntFile:@"carton_six_13.fnt" width:width alignment:alignment];
	[rtv setScale:fontsize/13.0];
	return rtv;
}

+(CCLabelTTF_Pooled*)cons_pooled_label_pos:(CGPoint)pos color:(ccColor3B)color fontsize:(int)fontsize str:(NSString*)str {
    //CCLabelTTF_Pooled *l = [CCLabelTTF_Pooled labelWithString:str fontName:@"Carton Six" fontSize:fontsize];
    CCLabelTTF_Pooled *l = [ObjectPool depool:[CCLabelTTF_Pooled class]];
	
	[l set_dimensions:CGSizeZero];
	[l setAnchorPoint:ccp(0.5,0.5)];
	[l set_textalign:CCTextAlignmentLeft];
	[l set_fontname:@"Carton Six" size:fontsize];
	[l setString:str];
	
	[l setColor:color];
    [l setPosition:pos];
    return l;
}

+(void)transform_obj:(GLRenderObject*)o by:(CGPoint)position {
	o.tri_pts[0] = fccp(position.x+o.tri_pts[0].x, position.y+o.tri_pts[0].y);
	o.tri_pts[1] = fccp(position.x+o.tri_pts[1].x, position.y+o.tri_pts[1].y);
	o.tri_pts[2] = fccp(position.x+o.tri_pts[2].x, position.y+o.tri_pts[2].y);
	o.tri_pts[3] = fccp(position.x+o.tri_pts[3].x, position.y+o.tri_pts[3].y);
}

+(CameraZoom)cons_normalcoord_camera_zoom_x:(float)x y:(float)y z:(float)z {
    struct CameraZoom c = {x,y,z};
    return c;
}

+(CGPoint)scale_from_default {
	return CGPointMake([Common SCREEN].width/480.0 * CC_CONTENT_SCALE_FACTOR(), [Common SCREEN].height/320.0 * CC_CONTENT_SCALE_FACTOR());
}

+(void)content_scale:(CCNode*)n {
	[n setScale:CC_CONTENT_SCALE_FACTOR()];
}

+(CGPoint)pct_of_obj:(CCNode *)obj pctx:(float)pctx pcty:(float)pcty {
	CGRect rct = [obj boundingBox];
	return ccp(rct.size.width*pctx*1/ABS(obj.scaleX),rct.size.height*pcty*1/ABS(obj.scaleY));
}

+(ccColor3B)color_from:(ccColor3B)a to:(ccColor3B)b pct:(float)pct {
	return ccc3(a.r+(b.r-a.r)*pct,a.g+(b.g-a.g)*pct,a.b+(b.b-a.b)*pct);
}

+(CCAction*)cons_anim:(NSArray*)a speed:(float)speed tex_key:(NSString*)key {
	CCTexture2D *texture = [Resource get_tex:key];
	NSMutableArray *animFrames = [NSMutableArray array];
    for (NSString* k in a) [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:key idname:k]]];
    return [Common make_anim_frames:animFrames speed:speed];
}

+(CCAction*)cons_nonrepeating_anim:(NSArray*)a speed:(float)speed tex_key:(NSString*)key {
	CCTexture2D *texture = [Resource get_tex:key];
	NSMutableArray *animFrames = [NSMutableArray array];
    for (NSString* k in a) [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:key idname:k]]];
	return [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:animFrames delay:speed] restoreOriginalFrame:NO];
}

+(BOOL)force_compress_textures {
	NSString *platform = [self platform];
	NSLog(@"device -- %@",platform);
	if ([platform isEqualToString:@"iPhone1,1"]) return YES;
	if ([platform isEqualToString:@"iPhone1,2"]) return YES;
	if ([platform isEqualToString:@"iPhone2,1"]) return YES;
	if ([platform isEqualToString:@"iPhone3,1"]) return YES;
	if ([platform isEqualToString:@"iPhone3,3"]) return YES;
	if ([platform isEqualToString:@"iPhone4,1"]) return NO;
	if ([platform isEqualToString:@"iPod1,1"]) return YES;
	if ([platform isEqualToString:@"iPod2,1"]) return YES;
	if ([platform isEqualToString:@"iPod3,1"]) return YES;
	if ([platform isEqualToString:@"iPod4,1"]) return YES;
	if ([platform isEqualToString:@"iPad1,1"]) return NO;
	if ([platform isEqualToString:@"iPad2,1"]) return NO;
	if ([platform isEqualToString:@"iPad2,2"]) return NO;
	if ([platform isEqualToString:@"iPad2,3"]) return NO;
	if ([platform isEqualToString:@"i386"]) return NO;
	if ([platform isEqualToString:@"x86_64"]) return NO;
	return NO;
}

+(NSString *) platform{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithUTF8String:machine];
	free(machine);
	return platform;
}

+(BOOL)is_visible:(CCNode*)tar {
	while (tar != NULL) {
		if (!tar.visible) return NO;
		tar = tar.parent;
	}
	return YES;
}

+(void)scale_to_screen_expected:(CCNode*)spr {
	[spr setScaleX:[Common scale_from_default].x];
	[spr setScaleY:[Common scale_from_default].y];
}
+(void)scale_to_fit_screen_x:(CCSprite *)spr {
	[spr setScaleX:[Common SCREEN].width/spr.texture.contentSize.width];
}
+(void)scale_to_fit_screen_y:(CCSprite *)spr {
	[spr setScaleY:[Common SCREEN].height/spr.texture.contentSize.height];
}

#define KEY_UUID @"key_uuid"
+(NSString*)unique_id {
	if ([DataStore get_str_for_key:KEY_UUID] == NULL) {
		CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
		NSString *uuid_str = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuid);
		CFRelease((CFTypeRef)uuid);
		[DataStore set_key:KEY_UUID str_value:uuid_str];
	}
	return [DataStore get_str_for_key:KEY_UUID];
}
@end
