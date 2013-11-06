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
        _speed = 2;
        _targetPoint = ccp(0, 0);
        _state = PLAYER_STATE_IDLE;
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    if (_state == PLAYER_STATE_CHASING) {
        // move towards target
        CGPoint dir = ccpNormalize(ccpSub(_targetPoint, self.position));
        self.position = ccp(self.position.x + dir.x * _speed, self.position.y + dir.y * _speed);
        
        // change state if we reached target
        if (ccpFuzzyEqual(self.position, _targetPoint, PLAYER_TARGET_REACH_DIST)) {
            _state = 0;
        }
    }
}

- (void)targetWithPoint:(CGPoint)target {
    _targetPoint = target;
    _state = PLAYER_STATE_CHASING;
}

@end
