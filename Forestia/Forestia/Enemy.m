//
//  Enemy.m
//  Forestia
//
//  Created by AdminMacLC04 on 11/7/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "Enemy.h"
#import "Player.h"

#define ENEMY_RADIUS 12
#define ENEMY_MASS 5
#define ENEMY_WALK_FORCE 1000
#define ENEMY_ATTACK_RANGE 35
#define ENEMY_RELOAD_TIME 1.8f
#define ENEMY_DAMAGE 10
#define ENEMY_DAMAGE_DELAY 0.2f
#define ENEMY_MAX_LIFE 80

@implementation Enemy

- (id)initWithLayer:(GameLayer *)layer {
    self = [super initWithLayer:layer radius:ENEMY_RADIUS mass:ENEMY_MASS];
    
    if (self != nil) {
        self.anchorPoint = ccp(0.4f, 0.5f);
        self.shape.layers = COLLISION_TERRAIN | COLLISION_UNITS;
        
        self.walkForce = ENEMY_WALK_FORCE;
        self.attackRange = ENEMY_ATTACK_RANGE;
        self.reloadTime = ENEMY_RELOAD_TIME;
        self.damage = ENEMY_DAMAGE;
        self.damageDelay = ENEMY_DAMAGE_DELAY;
        self.maxLife = ENEMY_MAX_LIFE;
        self.life = self.maxLife;
        
        CCSpriteFrame *idleFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"orc_idle.png"];
        self.idleAnim = [CCAnimation animationWithSpriteFrames:[NSArray arrayWithObjects:idleFrame, nil] delay:100];
        
        NSMutableArray *frames = [NSMutableArray array];
		for(int i = 1; i < 5; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"orc_walk_%04d.png", i]];
			[frames addObject:frame];
		}
        self.walkAnim = [CCAnimation animationWithSpriteFrames:frames delay:0.1f];
        
        frames = [NSMutableArray array];
		for(int i = 1; i < 5; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"orc_attack_%04d.png", i]];
			[frames addObject:frame];
		}
        self.attackAnim = [CCAnimation animationWithSpriteFrames:frames delay:0.08f];
        
        [self startIdleState];
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"orc_idle.png"]];
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    [super update:delta];
    
    if (self.state == UNIT_STATE_IDLE) {
        self.targetUnit = self.layer.player;
        [self startChaseState];
    }
}

@end
