#import "SwingVine.h"
#import "AudioManager.h"
#import "GameEngineLayer.h"

@interface VineBody : CSF_CCSprite
+(VineBody*)cons_tex:(CCTexture2D*)tex len:(float)len;
@end

@implementation VineBody
+(VineBody*)cons_tex:(CCTexture2D *)tex len:(float)len {
    ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_REPEAT};
    [tex setTexParameters:&par];
    VineBody* v = [VineBody spriteWithTexture:tex];
    [v cons_len:len/CC_CONTENT_SCALE_FACTOR()];
    return v;
}

-(void)cons_len:(float)len {
    [self setTextureRect:CGRectMake(0, 0, [self.texture contentSizeInPixels].width, len)];
	[self setScaleX:35.0/[self.texture contentSizeInPixels].width * CC_CONTENT_SCALE_FACTOR()];
	[self setAnchorPoint:ccp(0.5/CC_CONTENT_SCALE_FACTOR(),1)];
}
@end


@implementation SwingVine

#define BASEID 9

+(SwingVine*)cons_x:(float)x y:(float)y len:(float)len{
    SwingVine *s = [SwingVine node];
    [s setPosition:ccp(x,y)];
    [s cons_len:len];
    return s;
}

-(void)cons_len:(float)len {
    length = len;
	[self setScale:1];
    vine = [VineBody cons_tex:[Resource get_tex:TEX_SWINGVINE_TEX] len:len];
    [self addChild:vine];
    [self addChild:[CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_SWINGVINE_BASE]] z:0 tag:BASEID];
    active = YES;
    headcov = [CSF_CCSprite spriteWithTexture:[Resource get_tex:[Player get_character]] rect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"swing_head"]];
    [headcov setAnchorPoint:ccp(0.5,0)];
    [headcov setVisible:NO];
    [self addChild:headcov];
    
}

-(void)temp_disable {
    disable_timer = 50;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    //fix satpoly hitbox for moving position, see spikevine update
    
	CCSprite *base = (CCSprite*)[self getChildByTag:BASEID];
	if (g.world_mode.cur_mode == BGMode_LAB) {
		[base setTexture:[Resource get_tex:TEX_LABSWINGVINE_BASE]];
	} else {
		[base setTexture:[Resource get_tex:TEX_SWINGVINE_BASE]];
	}
	
    if (vine.rotation > 0) {
        vr -= 0.1 * [Common get_dt_Scale];
    } else {
        vr += 0.1 * [Common get_dt_Scale];
    }
    [vine setRotation:vine.rotation+vr*[Common get_dt_Scale]];
    
    if (disable_timer >0) {
        disable_timer--;
        [vine setOpacity:150];
        [headcov setVisible:NO];
        return;
    } else {
        [vine setOpacity:255];
    }
    
    if (player.current_swingvine == NULL && player.current_cannon == NULL && player.current_island == NULL && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        line_seg playerseg = [self get_player_mid_line_seg:player];
        line_seg selfseg = [self get_hit_line_seg];
        CGPoint ins = [Common line_seg_intersection_a:playerseg b:selfseg];
        if (ins.x != [Island NO_VALUE] && ins.y != [Island NO_VALUE]) {
            ins_offset = ccp(ins.x-player.position.x,ins.y-player.position.y);
            
            ins.x -= [self position].x;
            ins.y -= [self position].y;
            
            cur_dist = sqrtf(powf(ins.x, 2)+powf(ins.y, 2));
            player.current_swingvine = self;
            player.vx = 0;
            player.vy = 0;
            [player remove_temp_params:g];
            
            vr = -3.5; //~90deg
            [AudioManager playsfx:SFX_SWING];
        }
        
    }
    
    if (player.current_swingvine == self) {        
        if (cur_dist < length) {
            cur_dist += (length-cur_dist)/20.0;
        }

        if (ABS(vine.rotation) > 90) {
            vine.rotation = 90 * [Common sig:vine.rotation];
            vr = 0;
        }
        
        CGPoint tip = [self get_tip_relative_pos];
        Vec3D dirvec = [VecLib cons_x:tip.x y:tip.y z:0];
        dirvec=[VecLib normalize:dirvec];
        Vec3D offset_v = [VecLib cross:dirvec with:[VecLib Z_VEC]];
        dirvec= [VecLib scale:dirvec by:cur_dist];
        offset_v = [VecLib normalize:offset_v];
        offset_v = [VecLib scale:offset_v by:13/CC_CONTENT_SCALE_FACTOR()];
        
        [player setPosition:ccp([self position].x+dirvec.x+offset_v.x-ins_offset.x,[self position].y+dirvec.y+offset_v.y-ins_offset.y)];
        ins_offset.x *= 0.5;
        ins_offset.y *= 0.5;
        
        dirvec = [VecLib scale:dirvec by:-1];
        dirvec=[VecLib normalize:dirvec];
        player.up_vec = dirvec;
        
        Vec3D tangent_vec = [VecLib cross:dirvec with:[VecLib Z_VEC]];
        float tar_rad = -[VecLib get_angle_in_rad:tangent_vec];
        float tar_deg = [Common rad_to_deg:tar_rad];
        
        if ([player cur_anim_mode] == player_anim_mode_SWING) {
            [player setRotation:tar_deg];
            [headcov setVisible:YES];
            [headcov setPosition:ccp((player.position.x-[self position].x),(player.position.y-[self position].y))];
            [headcov setRotation:player.rotation];
            if ([player is_armored]) {
                [headcov setTexture:[Resource get_tex:TEX_DOG_ARMORED]];
                [headcov setTextureRect:[FileCache get_cgrect_from_plist:TEX_DOG_ARMORED idname:@"swing_head"]];
            } else {
                [headcov setTexture:[Resource get_tex:[Player get_character]]];
                [headcov setTextureRect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"swing_head"]];
                
            }
            
        } else {
            [headcov setVisible:NO];
        }
        
        
    } else {
        [headcov setVisible:NO];
        vr *= 0.95;
    }
    
    return;
}

-(line_seg)get_player_mid_line_seg:(Player*)p { 
    //64 wid,58 hei
    CGPoint base = p.position;
    Vec3D up;
    if (p.current_island != NULL) {
        Vec3D nvec = [p.current_island get_normal_vecC];
        up = [VecLib cons_x:nvec.x y:nvec.y z:nvec.z];
    } else {
        up = [VecLib cons_x:0 y:1 z:0];
    }
    up=[VecLib scale:up by:58.0/2.0];
    base.x += up.x;
    base.y += up.y;
    Vec3D tangent = [VecLib cross:up with:[VecLib Z_VEC]];
    tangent=[VecLib normalize:tangent];
    float hwid = 64.0/2.0;
    line_seg ret = [Common cons_line_seg_a:ccp(base.x-hwid*tangent.x,base.y-hwid*tangent.y) b:ccp(base.x+hwid*tangent.x,base.y+hwid*tangent.y)];
    return ret;
}

-(CGPoint)get_tip_relative_pos {
    float calc_a = vine.rotation - 90;
    float calc_rad = [Common deg_to_rad:calc_a];
    return ccp(-length*cosf(calc_rad),length*sinf(calc_rad));
}

-(line_seg)get_hit_line_seg {
    CGPoint tip_rel = [self get_tip_relative_pos];
    return [Common cons_line_seg_a:ccp([self position].x,[self position].y) b:ccp([self position].x+tip_rel.x,[self position].y+tip_rel.y)];
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-length y1:[self position].y-length wid:length*2 hei:length*2];
}

-(void)reset {
    [super reset];
    [vine setRotation:0];
    vr = 0;
}

-(CGPoint)get_tangent_vel {
    CGPoint t_vel = ccp(10,10);
    return t_vel;
}

-(void)draw {
    [super draw];
	if ([GameMain GET_DRAW_HITBOX]) {
		CGPoint tip = [self get_tip_relative_pos];
		ccDrawLine(ccp(0,0), tip);
	}
}

-(void)dealloc {
    [self removeAllChildrenWithCleanup:YES];
}

@end
