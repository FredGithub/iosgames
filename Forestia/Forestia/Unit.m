//
//  PathFollower.m
//  Forestia
//
//  Created by AdminMacLC04 on 11/20/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "Unit.h"
#import "Vector.h"
#import "Utils.h"

#define UNIT_FRICTION 0.8f
#define UNIT_ANGLE_SMOOTH 0.2f
#define UNIT_REFRESH_PATH_TIME 1

@implementation Unit

- (id)initWithLayer:(GameLayer *)layer radius:(float)radius mass:(float)mass {
    self = [super init];
    
    if (self != nil) {
        _layer = layer;
        
        _state = UNIT_STATE_IDLE;
        _targetPoint = ccp(0, 0);
        _targetUnit = nil;
        _currentPath = nil;
        _currentPathIndex = 0;
        _lastPathTime = 0;
        
        _walkForce = 1000;
        _attackRange = 50;
        _reloadTime = 2;
        _lastAttackTime = 0;
        _damage = 10;
        _attackApplied = NO;
        _attackDelay = 0;
        _maxLife = 100;
        _life = _maxLife;
        
        _currentAnimAction = nil;
        _idleAnim = nil;
        _walkAnim = nil;
        _attackAnim = nil;
        
        _body = [ChipmunkBody bodyWithMass:mass andMoment:INFINITY];
        _shape = [ChipmunkCircleShape circleWithBody:_body radius:radius offset:cpvzero];
        _shape.friction = 0.1f;
        [layer.space addBody:_body];
        [layer.space addShape:_shape];
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    [super update:delta];
    
    [_body resetForces];
    
    if (_state == UNIT_STATE_CHASE) {
        BOOL inRange = ccpDistanceSQ(_body.pos, _targetUnit.body.pos) <= _attackRange * _attackRange;
        if (inRange) {
            self.currentPath = nil;
            [self startWaitingForAttackState];
        } else {
            // refresh path if we don't have one or if it's too old
            if (self.currentPath == nil || _lastPathTime + UNIT_REFRESH_PATH_TIME <= _layer.time) {
                _lastPathTime = _layer.time;
                [self targetWithPoint:_targetUnit.body.pos];
            }
        }
    }
    
    if (_state == UNIT_STATE_WAITING_FOR_ATTACK) {
        BOOL outOfRange = ccpDistanceSQ(self.body.pos, _targetUnit.body.pos) > _attackRange * _attackRange;;
        if (outOfRange) {
            [self startChaseState];
        } else if (_lastAttackTime + _reloadTime <= self.layer.time) {
            _lastAttackTime = self.layer.time;
            _attackApplied = NO;
            [self startAttackState];
        } else {
            // face the target unit
            [self.body setAngle:ccpToAngle(ccpSub(_targetUnit.body.pos, self.body.pos))];
        }
    }
    
    if (_state == UNIT_STATE_ATTACK) {
        if ([_currentAnimAction isDone]) {
            [self startWaitingForAttackState];
        } else {
            // face the target unit
            [self.body setAngle:ccpToAngle(ccpSub(_targetUnit.body.pos, self.body.pos))];
            
            // apply damage
            if (!_attackApplied && (_lastAttackTime + _attackDelay <= self.layer.time || [_currentAnimAction isDone])) {
                _attackApplied = YES;
                [self applyAttack];
            }
        }
    }
    
    if (_currentPath != nil) {
        // move towards target
        CGPoint dir = ccpSub(_targetPoint, _body.pos);
        if (ccpLengthSQ(dir) > 0) {
            dir = ccpNormalize(dir);
            float rotation = [_body angle];
            [_body setAngle:rotation + angleMove(rotation, ccpToAngle(dir)) * UNIT_ANGLE_SMOOTH];
        }
        [_body applyForce:ccpMult(dir, _walkForce * _body.mass) offset:cpvzero];
        
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
    _body.vel = ccpMult(_body.vel, UNIT_FRICTION);
}

- (void)updateAfterPhysics:(ccTime)delta {
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

- (void)damageWithAmount:(float)amount {
    _life -= amount;
    if (_life <= 0) {
        self.active = NO;
    }
}

- (void)startIdleState {
    self.state = UNIT_STATE_IDLE;
    [self stopAnimation];
    if (_idleAnim != nil) {
        _currentAnimAction = [self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_idleAnim]]];
    }
}

- (void)startWalkState {
    self.state = UNIT_STATE_WALK;
    [self stopAnimation];
    if (_walkAnim != nil) {
        _currentAnimAction = [self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_walkAnim]]];
    }
}

- (void)startChaseState {
    self.state = UNIT_STATE_CHASE;
    [self stopAnimation];
    if (_walkAnim != nil) {
        _currentAnimAction = [self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_walkAnim]]];
    }
}

- (void)startWaitingForAttackState {
    self.state = UNIT_STATE_WAITING_FOR_ATTACK;
    [self stopAnimation];
    if (_idleAnim != nil) {
        _currentAnimAction = [self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_idleAnim]]];
    }
}

- (void)startAttackState {
    self.state = UNIT_STATE_ATTACK;
    [self stopAnimation];
    if (_attackAnim != nil) {
        _currentAnimAction = [self runAction:[CCAnimate actionWithAnimation:_attackAnim]];
    }
}

/* Private methods */

- (void)applyAttack {
    [_targetUnit damageWithAmount:_damage];
}

- (void)stopAnimation {
    if (_currentAnimAction != nil) {
        [self stopAction:_currentAnimAction];
    }
}

@end
