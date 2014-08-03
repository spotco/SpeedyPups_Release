#import "UsedItem.h"
#import "Player.h"

@implementation UsedItem

+(UsedItem*)cons {
    return [UsedItem spriteWithTexture:[Resource get_tex:TEX_ITEM_SS] rect:CGRectZero];
}

-(void)check_should_render:(GameEngineLayer *)g {
    do_render = YES;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    Vec3D pv;
    if (player.current_island == NULL) {
        pv = [VecLib cons_x:-player.vx y:-player.vy z:0];
    } else {
        pv = player.current_island.get_tangent_vec;
        pv = [VecLib scale:pv by:-CGPointDist(ccp(player.vx,player.vy), CGPointZero)];
    }
    pv = [VecLib scale:pv by:5];
    CGPoint tar_offset = ccp(pv.x,pv.y);
    
    cur_offset.x += (tar_offset.x-cur_offset.x)/10;
    cur_offset.y += (tar_offset.y-cur_offset.y)/10;
    
    CGPoint base = CGPointAdd(player.position, ccp(player.up_vec.x*30,player.up_vec.y*30));
    Vec3D ntan = [VecLib cross:[VecLib Z_VEC] with:player.up_vec];
    ntan = [VecLib scale:ntan by:player.up_vec.y<0?-10:10];
    base.x += ntan.x;
    base.y += ntan.y;
    
    [self setPosition:CGPointAdd(base, ccp(cur_offset.x,cur_offset.y))];
}

@end
