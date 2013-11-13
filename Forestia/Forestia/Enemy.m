//
//  Enemy.m
//  Forestia
//
//  Created by AdminMacLC04 on 11/7/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "Enemy.h"

#define ENEMY_STATE_IDLE 1
#define ENEMY_STATE_WALK 2
#define ENEMY_STATE_WAITING_FOR_ATTACK 3
#define ENEMY_STATE_ATTACK 4

@implementation Enemy

- (id)initWithLayer:(GameLayer *)layer {
    self = [super init];
    
    if (self != nil) {
        _layer = layer;
        _speed = 2;
        _targetPoint = ccp(0, 0);
        _state = ENEMY_STATE_IDLE;
        _currentPath = nil;
        _currentAnimAction = nil;
        
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
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    
}

- (CGPoint)currentPathTargetPoint {
    PathNode *node = _currentPath[_currentPathIndex];
    float x = node.col * _layer.map.tileSize.width + _layer.map.tileSize.width / 2;
    float y = node.row * _layer.map.tileSize.height + _layer.map.tileSize.height / 2;
    return ccp(x, y);
}

@end
