//
//  Player.m
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "Player.h"
#import "Vector.h"

#define PLAYER_STATE_IDLE 1
#define PLAYER_STATE_WALK 2
#define PLAYER_STATE_WAITING_FOR_ATTACK 3
#define PLAYER_STATE_ATTACK 4

#define PLAYER_RADIUS 14
#define PLAYER_MASS 10
#define PLAYER_WALK_FORCE 1400

@implementation Player

- (id)initWithLayer:(GameLayer *)layer {
    self = [super initWithLayer:layer radius:PLAYER_RADIUS mass:PLAYER_MASS];
    
    if (self != nil) {
        _currentAnimAction = nil;
        
        // build animations
        NSMutableArray *frames = [NSMutableArray array];
		for(int i = 1; i < 5; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"elf_walk_%04d.png", i]];
			[frames addObject:frame];
		}
        _walkAnim = [CCAnimation animationWithSpriteFrames:frames delay:0.1f];
        
        frames = [NSMutableArray array];
		for(int i = 1; i < 8; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"elf_attack_%04d.png", i]];
			[frames addObject:frame];
		}
        _attackAnim = [CCAnimation animationWithSpriteFrames:frames delay:0.2f];
        
        _maxLife = 100;
        _life = _maxLife;
        
        self.anchorPoint = ccp(0.35f, 0.5f);
        self.shape.layers = COLLISION_TERRAIN | COLLISION_UNITS;
        self.walkForce = PLAYER_WALK_FORCE;
        
        [self updateUI];
        [self startIdleState];
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    [super update:delta];
    
    if (_state == PLAYER_STATE_WALK) {
        if (self.currentPath == nil) {
            [self startIdleState];
        }
    }
    
    [self.layer.debugRenderer.points addObjectsFromArray:self.currentPath];
}

- (void)inputWithPoint:(CGPoint)target {
    [super targetWithPoint:target];
    if (self.currentPath != nil) {
        [self startWalkState];
    }
}

- (void)damageWithAmount:(float)amount {
    _life -= amount;
    [self updateUI];
}

/* Private methods */

- (void)startIdleState {
    _state = PLAYER_STATE_IDLE;
    [self stopAnimation];
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"elf_idle.png"]];
}

- (void)startWalkState {
    _state = PLAYER_STATE_WALK;
    [self stopAnimation];
    _currentAnimAction = [self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_walkAnim]]];
}

- (void)stopAnimation {
    if (_currentAnimAction != nil) {
        [self stopAction:_currentAnimAction];
    }
}

- (void)updateUI {
    self.layer.lifeBar.percentage = 100 * _life / _maxLife;
}

@end
