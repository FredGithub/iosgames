//
//  Player.m
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "Player.h"

#define PLAYER_TARGET_REACH_DIST 1
#define PLAYER_STATE_IDLE 1
#define PLAYER_STATE_CHASING 2

@implementation Player

- (id)initWithLayer:(GameLayer *)layer {
    self = [super initWithFile:@"bullet.png"];
    
    if (self != nil) {
        _layer = layer;
        _speed = 2;
        _targetPoint = ccp(0, 0);
        _state = PLAYER_STATE_IDLE;
        _currentPath = nil;
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    if (_state == PLAYER_STATE_CHASING) {
        // move towards target
        CGPoint dir = ccpSub(_targetPoint, self.position);
        if (ccpLengthSQ(dir) > 0) {
            dir = ccpNormalize(dir);
        }
        self.position = ccp(self.position.x + dir.x * _speed, self.position.y + dir.y * _speed);
        
        // change state if we reached target
        if (ccpFuzzyEqual(self.position, _targetPoint, PLAYER_TARGET_REACH_DIST)) {
            // if we have nodes left in our current path
            if (_currentPathIndex < [_currentPath count] - 1) {
                _currentPathIndex++;
                _targetPoint = [self currentPathTargetPoint];
                NSLog(@"%f %f", _targetPoint.x, _targetPoint.y);
            } else {
                NSLog(@"reached end of path");
                _state = PLAYER_STATE_IDLE;
            }
        }
    }
}

- (void)targetWithPoint:(CGPoint)target {
    int indexStart = [_layer cellIndexForPosition:self.position];
    int indexDest = [_layer cellIndexForPosition:target];
    NSArray *path = [_layer.graph calcPathFrom:[_layer.graph nodeForIndex:indexStart] to:[_layer.graph nodeForIndex:indexDest]];
    
    if (path == nil) {
        _state = PLAYER_STATE_IDLE;
        NSLog(@"path not found");
    } else {
        _currentPath = path;
        _state = PLAYER_STATE_CHASING;
        _currentPathIndex = 0;
        _targetPoint = [self currentPathTargetPoint];
        NSLog(@"first point %f %f", _targetPoint.x, _targetPoint.y);
    }
}

- (CGPoint)currentPathTargetPoint {
    PathNode *node = _currentPath[_currentPathIndex];
    float x = node.col * _layer.tileMap.tileSize.width + _layer.tileMap.tileSize.width / 2;
    float y = node.row * _layer.tileMap.tileSize.height + _layer.tileMap.tileSize.height / 2;
    return ccp(x, y);
}

@end
