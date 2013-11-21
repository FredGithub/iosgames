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

#define ENEMY_RELOAD_TIME 1.4f

@implementation Enemy

- (id)initWithLayer:(GameLayer *)layer {
    self = [super init];
    
    if (self != nil) {
        self.shape.layers = COLLISION_TERRAIN | COLLISION_UNITS;
        
        _currentAnimAction = nil;
        _lastAttackTime = 0;
        
        // build animations
        NSMutableArray *frames = [NSMutableArray array];
		for(int i = 1; i < 5; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"orc_walk_%04d.png", i]];
			[frames addObject:frame];
		}
        _walkAnim = [CCAnimation animationWithSpriteFrames:frames delay:0.2f];
        
        frames = [NSMutableArray array];
		for(int i = 1; i < 5; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"orc_attack_%04d.png", i]];
			[frames addObject:frame];
		}
        _attackAnim = [CCAnimation animationWithSpriteFrames:frames delay:0.2f];
        
        [self startIdleState];
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    [super update:delta];
    
    if (_state == ENEMY_STATE_IDLE) {
        //[self startChaseState];
    }
    
    if (_state == ENEMY_STATE_CHASE) {
        BOOL inRange = NO;
        if (inRange) {
            [self startWaitingForAttackState];
        } else if (self.currentPath == nil) {
            [self targetWithPoint:self.layer.player.body.pos];
        }
    }
    
    if (_state == ENEMY_STATE_WAITING_FOR_ATTACK) {
        BOOL outOfRange = NO;
        if (outOfRange) {
            
        } else if (_lastAttackTime + ENEMY_RELOAD_TIME <= self.layer.time) {
            _lastAttackTime = self.layer.time;
            [self startAttackState];
        }
    }
    
    if (_state == ENEMY_STATE_ATTACK) {
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
