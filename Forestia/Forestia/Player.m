//
//  Player.m
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "Player.h"

#define TARGET_REACH_DIST 1

@implementation Player

- (id)initWithLayer:(GameLayer *)layer {
    self = [super initWithFile:@"bullet.png"];
    
    if (self != nil) {
        _speed = 2;
        _targetPoint = ccp(0, 0);
        _state = 0;
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    if (_state == 1) {
        CGPoint dir = ccpNormalize(ccpSub(_targetPoint, self.position));
        self.position = ccp(self.position.x + dir.x * _speed, self.position.y + dir.y * _speed);
        
        // change state if we reached target
        if (ccpDistanceSQ(self.position, _targetPoint) < TARGET_REACH_DIST * TARGET_REACH_DIST) {
            _state = 0;
        }
    }
}

- (void)targetWithPoint:(CGPoint)target {
    _targetPoint = target;
    _state = 1;
}

@end
