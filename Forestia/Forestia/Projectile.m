//
//  Projectile.m
//  Forestia
//
//  Created by AdminMacLC04 on 11/28/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "Projectile.h"
#import "Utils.h"

#define PROJECTILE_ANGLE_SMOOTH 0.8f

@implementation Projectile

- (id)initWithLayer:(GameLayer *)layer target:(Unit *)target damage:(float)damage {
    self = [super init];
    
    if (self != nil) {
        _target = target;
        _speed = 5;
        _damage = damage;
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"arrow.png"]];
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    [super update:delta];
    
    // move towards target
    CGPoint dir = ccpSub(_target.position, self.position);
    if (ccpLengthSQ(dir) > 0) {
        dir = ccpNormalize(dir);
        self.rotation += angleMoveDeg(self.rotation, -180 * ccpToAngle(dir) / M_PI) * PROJECTILE_ANGLE_SMOOTH;
    }
    self.position = ccpAdd(self.position, ccpMult(dir, _speed));
    
    // if we hit the target
    if (ccpLengthSQ(ccpSub(_target.position, self.position)) <= _target.shape.radius * _target.shape.radius) {
        [_target damageWithAmount:_damage];
        self.active = NO;
    }
}

@end
