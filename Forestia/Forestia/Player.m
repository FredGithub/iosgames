//
//  Player.m
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "Player.h"

#define PLAYER_STATE_IDLE 1
#define PLAYER_STATE_WALK 2
#define PLAYER_STATE_WAITING_FOR_ATTACK 3
#define PLAYER_STATE_ATTACK 4

@implementation Player

- (id)initWithLayer:(GameLayer *)layer {
    self = [super init];
    
    if (self != nil) {
        _layer = layer;
        _speed = 2;
        _targetPoint = ccp(0, 0);
        _state = PLAYER_STATE_IDLE;
        _currentPath = nil;
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
        
        [self startIdleState];
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    if (_state == PLAYER_STATE_WALK) {
        // move towards target
        CGPoint dir = ccpSub(_targetPoint, self.position);
        if (ccpLengthSQ(dir) > 0) {
            dir = ccpNormalize(dir);
        }
        self.position = ccp(self.position.x + dir.x * _speed, self.position.y + dir.y * _speed);
        if (ccpLengthSQ(dir) > 0) {
            self.rotation = -ccpAngleSigned(ccp(1, 0), dir) * 180 / M_PI;
        }
        
        // pick next target if we reached the current target
        if (ccpFuzzyEqual(self.position, _targetPoint, 1)) {
            // if we have nodes left in our current path
            if (_currentPathIndex < [_currentPath count] - 1) {
                _currentPathIndex++;
                _targetPoint = [self currentPathTargetPoint];
                NSLog(@"%f %f", _targetPoint.x, _targetPoint.y);
            } else {
                NSLog(@"reached end of path");
                [self startIdleState];
            }
        }
    }
}

- (void)targetWithPoint:(CGPoint)target {
    int indexStart = [_layer cellIndexForPosition:self.position];
    int indexDest = [_layer cellIndexForPosition:target];
    NSArray *path = [_layer.graph calcPathFrom:[_layer.graph nodeForIndex:indexStart] to:[_layer.graph nodeForIndex:indexDest]];
    
    if (path == nil) {
        [self startIdleState];
        NSLog(@"path not found");
    } else {
        [self startWalkState];
        _currentPath = path;
        _currentPathIndex = 0;
        _targetPoint = [self currentPathTargetPoint];
        NSLog(@"first point %f %f", _targetPoint.x, _targetPoint.y);
    }
}

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

- (CGPoint)currentPathTargetPoint {
    PathNode *node = _currentPath[_currentPathIndex];
    float x = node.col * _layer.tileMap.tileSize.width + _layer.tileMap.tileSize.width / 2;
    float y = node.row * _layer.tileMap.tileSize.height + _layer.tileMap.tileSize.height / 2;
    return ccp(x, y);
}

@end
