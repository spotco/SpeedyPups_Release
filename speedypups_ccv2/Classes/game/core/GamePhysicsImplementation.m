#import "GamePhysicsImplementation.h"

//Used in move along island
#define ABS_MAX_SPEED 20
#define SLOPE_ACCEL 0.5
#define FRICTION 0.96
#define TO_GROUND_ROTATION_SPEED 0.3

//Used in freefall
#define CENTERING_UP_VEC_SPD 0.07
#define MAX_LOSS 0.3

@implementation GamePhysicsImplementation

+(void)player_move:(id<PhysicsObject>)player with_islands:(NSMutableArray*)islands {
    if (player.current_swingvine != NULL || player.current_cannon != NULL) {
        return;
    }
	
    if (player.current_island == NULL) {
        player.position = [GamePhysicsImplementation player_free_fall:player islands:islands];
    } else {
        player.position = [GamePhysicsImplementation player_move_along_island:player islands:islands];
    }
}

+(CGPoint)player_move_along_island:(id<PhysicsObject>)player islands:(NSMutableArray*)islands {
    float MIN_SPEED = [player get_speed];
    
    Island *i = player.current_island;
    Vec3D tangent_vec = [i get_tangent_vec];
    
    player.last_ndir = (i.ndir < 0)?-1:1;
    
    if (tangent_vec.y < 0) {
        float ang = [VecLib get_angle_in_rad:tangent_vec];
        if (ang < -M_PI_2) {
            ang = ang + M_PI;
        }
        float pct = ABS(ang/M_PI_2);
        
        player.vx += SLOPE_ACCEL *pct;
        player.vy += SLOPE_ACCEL *pct;
        
        MIN_SPEED += (ABS_MAX_SPEED - MIN_SPEED)*(pct);
    }
    

    float mov_speed = sqrtf(powf(player.vx, 2) + powf(player.vy, 2)) * [Common get_dt_Scale];
    
    if (mov_speed > ABS_MAX_SPEED * [Common get_dt_Scale]) {
        mov_speed = ABS_MAX_SPEED;
    }
    if (mov_speed > MIN_SPEED  * [Common get_dt_Scale]) {
        player.vx *= FRICTION;
        player.vy *= FRICTION;
    }
    if (mov_speed < MIN_SPEED) {
        float acc = (MIN_SPEED - mov_speed)/5;
        player.vx += acc;
        player.vy += acc;
    }
    player.up_vec = [VecLib cross:[VecLib Z_VEC] with:tangent_vec];
    player.up_vec = [VecLib normalize:player.up_vec];
    player.up_vec = [VecLib scale:player.up_vec by:i.ndir];
    
    float tar_rad = -[VecLib get_angle_in_rad:tangent_vec];
    float tar_deg = [Common rad_to_deg:tar_rad];
    float dir = [Common shortest_dist_from_cur:player.rotation to:tar_deg];
    player.rotation += dir*TO_GROUND_ROTATION_SPEED;
    
    CGPoint position_final;
    
    if (player.movedir > 0) {
		
        float t = [i get_t_given_position:player.position];
        float t_final = t+mov_speed;
        position_final = [i get_position_given_t:t_final];
        
        if (position_final.x == [Island NO_VALUE] || position_final.y == [Island NO_VALUE]) {
            if (i.next != NULL) {
                float t_sum = mov_speed;
                t_sum -= [i get_t_given_position:ccp(i.endX,i.endY)] - t;
                player.current_island = i.next;
                if ([player.current_island get_position_given_t:t_sum].x != [Island NO_VALUE] && [player.current_island get_position_given_t:t_sum].y != [Island NO_VALUE]) {
                    position_final = [player.current_island get_position_given_t:t_sum];
                } else {
                    position_final = ccp(player.current_island.endX,player.current_island.endY);
                }
                
            } else {
                
                position_final = ccp(player.position.x + tangent_vec.x*mov_speed, player.position.y + tangent_vec.y*mov_speed);
                
                player.current_island = NULL;
                player.vx = tangent_vec.x * mov_speed / [Common get_dt_Scale];
                player.vy = tangent_vec.y * mov_speed / [Common get_dt_Scale];
            }
        }
        
    } else {
        float t = [i get_t_given_position:player.position];
        float t_final = t+mov_speed*player.movedir;
        if (t_final >= 0) {
            position_final = [i get_position_given_t:t_final];
            
        } else {
            float remainder_t = ABS(t_final);
            while (remainder_t > 0) {
                i = i.prev;
                if (i != NULL) {
                    if (remainder_t < i.t_max) {
                        player.current_island = i;
                        position_final = [i get_position_given_t:i.t_max - remainder_t];
                        break;
                        
                    } else {
                        remainder_t -= i.t_max;
                        
                    }
                    
                } else {
                    player.current_island = NULL;
                    position_final = ccp(
						player.position.x + tangent_vec.x*mov_speed*player.movedir,
						player.position.y + tangent_vec.y*mov_speed*player.movedir
					);
                    player.vx = tangent_vec.x * mov_speed * player.movedir;
                    player.vy = tangent_vec.y * mov_speed * player.movedir;
                    break;
                    
                }
            }
            
        }
        
    }
    
    return position_final;
}

+(CGPoint)player_free_fall:(id<PhysicsObject>)player islands:(NSMutableArray*)islands {
    float GRAVITY = [player get_current_params].cur_gravity;
    if (player.floating) {
        if ([Player current_character_has_power:CharacterPower_SLOWFALL]){
            GRAVITY = GRAVITY * 0.3;
        } else {
            GRAVITY = GRAVITY * 0.4;
        }
        
    }
    player.up_vec = [VecLib cons_x:0 y:1 z:0];
    
    CGPoint player_pre = player.position;
    CGPoint player_post = ccp(player.position.x+player.vx * [Common get_dt_Scale],player.position.y+player.vy * [Common get_dt_Scale]);
    line_seg player_mov = [Common cons_line_seg_a:player_pre b:player_post];
    Vec3D player_mov_vec = [VecLib cons_x:player_mov.b.x - player_mov.a.x y:player_mov.b.y - player_mov.a.y z:0];
    
    Island* contact_island = NULL;
    CGPoint contact_intersection;
    line_seg contact_segment;
    
    for (Island *i in islands) {     
        line_seg island_seg = [i get_line_seg];
        CGPoint intersection = [Common line_seg_intersection_a:player_mov b:island_seg];
        Vec3D inormal_vec = [i get_normal_vecC];
        if (i.can_land && intersection.x != [Island NO_VALUE] && intersection.y != [Island NO_VALUE] && ABS([VecLib rad_angle_between_a:player_mov_vec and_b:inormal_vec]) >= M_PI / 2) {
            contact_island = i;
            contact_intersection = intersection;
            contact_segment = island_seg;
        }
    }
    
    if (contact_island != NULL) {
        float extrat = sqrtf(powf(player_post.x - contact_intersection.x,2)+ powf(player_post.y - contact_intersection.y,2))/[Common get_dt_Scale];
        float cur_t = [contact_island get_t_given_position:contact_intersection];
        
        if (extrat+cur_t > contact_island.t_max) {
            player_post = ccp(contact_island.endX,contact_island.endY);
        } else {
            player_post = [contact_island get_position_given_t:cur_t+extrat];
        }
        player.current_island = contact_island;
        
        Vec3D a = [VecLib cons_x:player_mov.b.x - player_mov.a.x y:player_mov.b.y - player_mov.a.y z:0];
        Vec3D b = [VecLib cons_x:contact_segment.b.x - contact_segment.a.x y:contact_segment.b.y - contact_segment.a.y z:0];
        float theta = [VecLib rad_angle_between_a:a and_b:b];
        if (theta < M_PI) {
            player.vx *= MAX((M_PI - theta)/(M_PI),MAX_LOSS);
            player.vy *= MAX((M_PI - theta)/(M_PI),MAX_LOSS);
        } else {
            player.vx *= MAX_LOSS * [Common get_dt_Scale];
            player.vy *= MAX_LOSS * [Common get_dt_Scale];
        }
        
    } else {
        float grav_const = GRAVITY;
        player.vx += grav_const * player.up_vec.x * [Common get_dt_Scale];
        player.vy += grav_const * player.up_vec.y * [Common get_dt_Scale];
    }
    
	//note: rotation code for this is in Player.m
    return player_post;
}


@end
