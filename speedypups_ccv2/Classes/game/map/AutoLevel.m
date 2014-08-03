#import "AutoLevel.h"
#import "GameEngineLayer.h"
#import "DogBone.h"
#import "SwingVine.h" 

@implementation AutoLevel

#define REMOVEBUFFER 1000
#define ADDBUFFER 1300

+(AutoLevel*)cons_with_glayer:(GameEngineLayer*)glayer startat:(WorldStartAt)world {
    AutoLevel* a = [AutoLevel node];
    [a cons:glayer startat:world];
    [GEventDispatcher add_listener:a];
    return a;
}

-(void)cons:(GameEngineLayer*)glayer startat:(WorldStartAt)world {
    cur_state = [AutoLevelState cons_startat:world];
    tglayer = glayer;

    map_sections = [[NSMutableArray alloc] init];
    stored = [[NSMutableArray alloc] init];
    queued_sections = [[NSMutableArray alloc] init];
    [self load_into_queue:[cur_state get_level]];
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_CHECKPOINT) {
        [self cleanup_start:tglayer.player.start_pt player:tglayer.player.position];
        
    } else if (e.type == GEventType_BOSS1_ACTIVATE || e.type == GEventType_BOSS2_ACTIVATE || e.type == GEventType_BOSS3_ACTIVATE) {
		[cur_state to_boss_mode];
        [self remove_all_ahead_but_current:e.pt];
        [self shift_queue_into_current];
	}
}

-(void)game_quit {
	for (MapSection *m in map_sections) m.stop_repool = YES;
}

-(void)remove_all_ahead_but_current:(CGPoint)pos {
    CGPoint min_cur = ccp(cur_x,cur_y);
    for (MapSection *m in queued_sections) {
        if ([m get_offset].x < min_cur.x) {
            min_cur = [m get_offset];
        }
    }
    [queued_sections removeAllObjects];
    for (int i = (int)map_sections.count-1; i >= 0; i--) {
        if (map_sections.count-1 < i) continue;
        MapSection *m = [map_sections objectAtIndex:i];
        MapSection_Position p = [m get_position_status:pos];
        if (p != MapSection_Position_CURRENT) {
            if (p != MapSection_Position_PAST && [m get_offset].x < min_cur.x) {
                min_cur = [m get_offset];
            }
            [self remove_map_section_from_current:m];
        }
    }
    cur_x = min_cur.x;
    cur_y = min_cur.y;
    
}

-(void)load_into_queue:(NSString*)key { //load map into queue
	
	[self checkrep];
	
    MapSection *m = [MapSection cons_from_name:key g:tglayer];
    if (!has_pos_initial) {
        cur_x = m.map.connect_pts_x1;
        cur_y = m.map.connect_pts_y1;
        has_pos_initial = YES;
    }
    
    
    [m offset_x:cur_x y:cur_y];
    cur_x = (m.map.connect_pts_x2 - m.map.connect_pts_x1)+cur_x;
    cur_y = (m.map.connect_pts_y2 - m.map.connect_pts_y1)+cur_y;
    [queued_sections addObject:m];

	[self checkrep];
}

-(void)checkrep {
	for (NSArray *list in @[map_sections, queued_sections, stored]) {
		for (MapSection *m in list) {
			for (NSArray *list2 in @[map_sections, queued_sections, stored]) {
				for (MapSection *m2 in list2) {
					if (m2 != m) {
						for (GameObject *o in m.map.game_objects) {
							for (GameObject *o2 in m2.map.game_objects) {
								if (o == o2) {
									NSLog(@"DUPE GAMEOBJ (%p,%p)",o,o2);
								}
							}
						}
					}
				}
			}
		}
	}
}

-(void)shift_queue_into_current { //move top map in queue to current
    if ([queued_sections count] == 0) {
        [tglayer.get_stats increment:GEStat_SECTIONS];
        [self load_into_queue:[cur_state get_level]];
    }
    MapSection *m = [queued_sections objectAtIndex:0];
    [queued_sections removeObjectAtIndex:0];
    
    [map_sections addObject:m];
    
    [tglayer.islands addObjectsFromArray:m.map.n_islands];
    [Island link_islands:tglayer.islands];
    for (Island* i in m.map.n_islands) {
        [tglayer addChild:i z:[i get_render_ord]];
    }
    
    for (GameObject* o in m.map.game_objects) {
        [tglayer add_gameobject:o];
    }
	
}

-(void)remove_map_section_from_current:(MapSection*)m {
    [tglayer.islands removeObjectsInArray:m.map.n_islands];
    for (Island* i in m.map.n_islands) {
        if (tglayer.player.current_island == i) tglayer.player.current_island = NULL;
        if (i.prev != NULL) {
            i.prev.next = NULL;
            i.prev = NULL;
        }
        if (i.next != NULL) {
            i.next.prev = NULL;
            i.next = NULL;
        }
        [tglayer removeChild:i cleanup:YES];
    }
    
    for(GameObject* o in m.map.game_objects) {
        if (tglayer.player.current_swingvine == o) tglayer.player.current_swingvine = NULL;
		[tglayer remove_gameobject:o];
	}
    [tglayer do_remove_gameobjects];
	
    [map_sections removeObject:m];
}

-(void)cleanup_start:(CGPoint)player_startpt player:(CGPoint)cur {
    for(int j = (int)map_sections.count-1; j >= 0; j--) {
        MapSection *i = [map_sections objectAtIndex:j];
        MapSection_Position ip = [i get_position_status:player_startpt];
        if (ip == MapSection_Position_PAST) {
            [self remove_map_section_from_current:i];
        }
    }

    [stored removeAllObjects];
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    CGPoint pos = player.position;
    NSMutableArray *tostore = [[NSMutableArray alloc] init];
    MapSection *current;
    int ct_ahead = 0;
    
    for (MapSection *i in map_sections) { //get past ones
        CGRange range = [i get_range];
        MapSection_Position ip = [i get_position_status:pos];
        if (ip == MapSection_Position_PAST && range.max+REMOVEBUFFER < player.position.x) {
            [tostore addObject:i];
        } else if (ip == MapSection_Position_CURRENT) {
            current = i;
        } else if (ip == MapSection_Position_AHEAD) {
            ct_ahead++;
        }
    }
    
    if ([tostore count] > 0) { //move past ones to stored
        for (MapSection *i in tostore) {
			[stored addObject:i];
            [self remove_map_section_from_current:i];
        }
    }
    
    if ( ([map_sections count] == 0) || 
         (ct_ahead == 0 && [current get_range].max-ADDBUFFER < player.position.x) ) {
        [self shift_queue_into_current];
    }
    
    [tostore removeAllObjects];
    return;
}

-(void)reset_map:(MapSection*)m {
    for (GameObject *o in m.map.game_objects) {
        [o reset];
    }
}

-(void)reset { //move all in stored to current (TODO: some in queue)
    for (int i = (int)map_sections.count-1; i>=0; i--) {
        MapSection *t = [map_sections objectAtIndex:i];
        [self reset_map:t];
        [queued_sections insertObject:t atIndex:0];
        [self remove_map_section_from_current:t];
        
    }
    for (int i = (int)stored.count-1; i>=0; i--) {
        MapSection *t = [stored objectAtIndex:i];
        [self reset_map:t];
        [queued_sections insertObject:t atIndex:0];
        [stored removeObjectAtIndex:i];
        
    }
    [self shift_queue_into_current];
    
    [super reset];
}

-(void)dealloc {
    [queued_sections removeAllObjects];
    [stored removeAllObjects];
    [map_sections removeAllObjects];
}
@end


