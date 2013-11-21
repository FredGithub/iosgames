//
//  PathFollower.m
//  Forestia
//
//  Created by AdminMacLC04 on 11/20/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "PathFollower.h"
#import "Vector.h"

#define PATH_FOLLOWER_FRICTION 0.8f
#define PATH_FOLLOWER_ANGLE_SMOOTH 0.2f

@implementation PathFollower

- (id)initWithLayer:(GameLayer *)layer radius:(float)radius {
    self = [super init];
    
    if (self != nil) {
        _layer = layer;
        _walkForce = 2500;
        _targetPoint = ccp(0, 0);
        _currentPath = nil;
        
        // setup physic body
        _body = [ChipmunkBody bodyWithMass:1 andMoment:INFINITY];
        _shape = [ChipmunkCircleShape circleWithBody:_body radius:radius offset:cpvzero];
        _shape.friction = 0.1f;
        [layer.space addBody:_body];
        [layer.space addShape:_shape];
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    [_body resetForces];
    
    if (_currentPath != nil) {
        // move towards target
        CGPoint dir = ccpSub(_targetPoint, _body.pos);
        if (ccpLengthSQ(dir) > 0) {
            dir = ccpNormalize(dir);
            float rotation = [_body angle];
            [_body setAngle:rotation + [self angleMoveFrom:rotation to:ccpToAngle(dir)] * PATH_FOLLOWER_ANGLE_SMOOTH];
        }
        [_body applyForce:ccpMult(dir, _walkForce) offset:cpvzero];
        
        // pick next target if we reached the current target
        if (ccpFuzzyEqual(_body.pos, _targetPoint, _shape.radius + 2)) {
            // if we have nodes left in our current path
            if (_currentPathIndex < [_currentPath count] - 1) {
                _currentPathIndex++;
                Vector *vector = _currentPath[_currentPathIndex];
                _targetPoint = ccp(vector.x, vector.y);
            } else {
                _currentPath = nil;
            }
        }
    }
    
    // apply friction
    _body.vel = ccpMult(_body.vel, PATH_FOLLOWER_FRICTION);
}

- (void)updateAfterPhysics:(ccTime)delta {
    NSLog(@"after %f %f", _body.pos.x, _body.pos.y);
    self.position = _body.pos;
    self.rotation = -ccpToAngle(_body.rot) * 180 / M_PI;
}

- (void)targetWithPoint:(CGPoint)target {
    _currentPath = [_layer pathFrom:_body.pos to:target];
    if (_currentPath != nil) {
        _currentPathIndex = 0;
        Vector *vector = _currentPath[_currentPathIndex];
        _targetPoint = ccp(vector.x, vector.y);
    }
}

/* Private methods */

- (float) angleMoveFrom:(float)rotation to:(float)targetRotation {
    float angleMove = fmodf(targetRotation - rotation, 2 * M_PI);
    if (angleMove > M_PI) {
        angleMove -= 2 * M_PI;
    } else if (angleMove < -M_PI) {
        angleMove += 2 * M_PI;
    }
    return angleMove;
}

@end
