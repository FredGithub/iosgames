//
//  Enemy.m
//  Forestia
//
//  Created by AdminMacLC04 on 11/7/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "Enemy.h"
#import "Player.h"

#define ENEMY_STATE_IDLE 1
#define ENEMY_STATE_CHASE 2
#define ENEMY_STATE_WAITING_FOR_ATTACK 3
#define ENEMY_STATE_ATTACK 4

#define ENEMY_RADIUS 12
#define ENEMY_MASS 5
#define ENEMY_WALK_FORCE 1000
#define ENEMY_RELOAD_TIME 1.8f
#define ENEMY_ATTACK_RANGE 40
#define ENEMY_REFRESH_PATH_TIME 1
#define ENEMY_DAMAGE 10
#define ENEMY_ATTACK_DAMAGE_DELAY 0.2f

@implementation Enemy

- (id)initWithLayer:(GameLayer *)layer {
    self = [super initWithLayer:layer radius:ENEMY_RADIUS mass:ENEMY_MASS];
    
    if (self != nil) {
        _currentAnimAction = nil;
        _lastAttackTime = 0;
        _damageApplied = NO;
        _lastPathTime = 0;
        
        // build animations
        NSMutableArray *frames = [NSMutableArray array];
		for(int i = 1; i < 5; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"orc_walk_%04d.png", i]];
			[frames addObject:frame];
		}
        _walkAnim = [CCAnimation animationWithSpriteFrames:frames delay:0.1f];
        
        frames = [NSMutableArray array];
		for(int i = 1; i < 5; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"orc_attack_%04d.png", i]];
			[frames addObject:frame];
		}
        _attackAnim = [CCAnimation animationWithSpriteFrames:frames delay:0.08f];
        
        _maxLife = 50;
        _life = _maxLife;
        
        self.anchorPoint = ccp(0.4f, 0.5f);
        self.shape.layers = COLLISION_TERRAIN | COLLISION_UNITS;
        self.walkForce = ENEMY_WALK_FORCE;
        
        [self startIdleState];
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    [super update:delta];
    
    if (_state == ENEMY_STATE_IDLE) {
        [self startChaseState];
    }
    
    if (_state == ENEMY_STATE_CHASE) {
        BOOL inRange = ccpDistanceSQ(self.body.pos, self.layer.player.body.pos) <= ENEMY_ATTACK_RANGE * ENEMY_ATTACK_RANGE;
        if (inRange) {
            self.currentPath = nil;
            [self startWaitingForAttackState];
        } else {
            // refresh path if we don't have one or if it's too old
            if (self.currentPath == nil || _lastPathTime + ENEMY_REFRESH_PATH_TIME <= self.layer.time) {
                _lastPathTime = self.layer.time;
                [self targetWithPoint:self.layer.player.body.pos];
            }
        }
    }
    
    if (_state == ENEMY_STATE_WAITING_FOR_ATTACK) {
        BOOL outOfRange = ccpDistanceSQ(self.body.pos, self.layer.player.body.pos) > ENEMY_ATTACK_RANGE * ENEMY_ATTACK_RANGE;;
        if (outOfRange) {
            [self startChaseState];
        } else if (_lastAttackTime + ENEMY_RELOAD_TIME <= self.layer.time) {
            _lastAttackTime = self.layer.time;
            _damageApplied = NO;
            [self startAttackState];
        } else {
            // face the player
            [self.body setAngle:ccpToAngle(ccpSub(self.layer.player.body.pos, self.body.pos))];
        }
    }
    
    if (_state == ENEMY_STATE_ATTACK) {
        if (!_damageApplied && (_lastAttackTime + ENEMY_ATTACK_DAMAGE_DELAY <= self.layer.time || [_currentAnimAction isDone])) {
            [self.layer.player damageWithAmount:ENEMY_DAMAGE];
            _damageApplied = YES;
        }
        if ([_currentAnimAction isDone]) {
            [self startWaitingForAttackState];
        }
    }
}

/* Private methods */

- (void)startIdleState {
    _state = ENEMY_STATE_IDLE;
    [self stopAnimation];
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"orc_idle.png"]];
}

- (void)startChaseState {
    _state = ENEMY_STATE_CHASE;
    [self stopAnimation];
    _currentAnimAction = [self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_walkAnim]]];
}

- (void)startWaitingForAttackState {
    _state = ENEMY_STATE_WAITING_FOR_ATTACK;
    [self stopAnimation];
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"orc_idle.png"]];
}

- (void)startAttackState {
    _state = ENEMY_STATE_ATTACK;
    [self stopAnimation];
    _currentAnimAction = [self runAction:[CCAnimate actionWithAnimation:_attackAnim]];
}

- (void)stopAnimation {
    if (_currentAnimAction != nil) {
        [self stopAction:_currentAnimAction];
    }
}

@end
