//
//  Player.m
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "Player.h"
#import "Vector.h"
#import "Projectile.h"

#define PLAYER_RADIUS 14
#define PLAYER_MASS 10
#define PLAYER_WALK_FORCE 1700
#define PLAYER_ATTACK_RANGE 200
#define PLAYER_RELOAD_TIME 1.1f
#define PLAYER_DAMAGE 50
#define PLAYER_ATTACK_DELAY 0.5f
#define PLAYER_MAX_LIFE 100

@implementation Player

- (id)initWithLayer:(GameLayer *)layer {
    self = [super initWithLayer:layer radius:PLAYER_RADIUS mass:PLAYER_MASS];
    
    if (self != nil) {
        self.anchorPoint = ccp(0.35f, 0.5f);
        self.shape.layers = COLLISION_TERRAIN | COLLISION_UNITS;
        
        self.walkForce = PLAYER_WALK_FORCE;
        self.attackRange = PLAYER_ATTACK_RANGE;
        self.reloadTime = PLAYER_RELOAD_TIME;
        self.damage = PLAYER_DAMAGE;
        self.attackDelay = PLAYER_ATTACK_DELAY;
        self.maxLife = PLAYER_MAX_LIFE;
        self.life = self.maxLife;
        
        CCSpriteFrame *idleFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"elf_idle.png"];
        self.idleAnim = [CCAnimation animationWithSpriteFrames:[NSArray arrayWithObjects:idleFrame, nil] delay:100];
        
        NSMutableArray *frames = [NSMutableArray array];
		for(int i = 1; i < 5; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"elf_walk_%04d.png", i]];
			[frames addObject:frame];
		}
        self.walkAnim = [CCAnimation animationWithSpriteFrames:frames delay:0.1f];
        
        frames = [NSMutableArray array];
		for(int i = 1; i < 8; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"elf_attack_%04d.png", i]];
			[frames addObject:frame];
		}
        self.attackAnim = [CCAnimation animationWithSpriteFrames:frames delay:0.1f];
        
        [self updateUI];
        [self startIdleState];
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"elf_idle.png"]];
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    [super update:delta];
    
    if (self.state == UNIT_STATE_WALK) {
        if (self.currentPath == nil) {
            [self startIdleState];
        }
    }
    
    [self.layer.debugRenderer.points addObjectsFromArray:self.currentPath];
}

- (void)inputWithPoint:(CGPoint)target {
    [super targetWithPoint:target];
    if (self.currentPath != nil) {
        self.targetUnit = nil;
        [self startWalkState];
    }
}

- (void)inputWithEnemy:(Unit *)unit {
    if (self.targetUnit != unit) {
        self.targetUnit = unit;
        [self startChaseState];
    }
}

- (void)damageWithAmount:(float)amount {
    [super damageWithAmount:amount];
    [self updateUI];
}

/* Private methods */

- (void)applyAttack {
    Projectile *projectile = [[Projectile alloc] initWithLayer:self.layer target:self.targetUnit damage:self.damage];
    projectile.position = self.position;
    projectile.rotation = self.rotation;
    [self.layer addProjectile:projectile];
}

- (void)updateUI {
    self.layer.lifeBar.percentage = 100 * self.life / self.maxLife;
}

@end
