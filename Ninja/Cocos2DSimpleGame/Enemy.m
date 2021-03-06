//
//  Ghost.m
//  Cocos2DSimpleGame
//
//  Created by AdminMacLC04 on 9/12/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Enemy.h"

@implementation Enemy

+ (id)createEnemyWithLayer:(GameLayer *)layer type:(int)type {
    Enemy *enemy = nil;
    if (type == 0) {
        enemy = [[Enemy alloc] initWithLayer:layer type:type life:100 speed:ccp(-85, 0) spriteFrameName:@"carrot0001.png"];
    } else if (type == 1) {
        enemy = [[Enemy alloc] initWithLayer:layer type:type life:600 speed:ccp(-50, 0) spriteFrameName:@"eggplant0001.png"];
    } else if (type == 2) {
        enemy = [[Enemy alloc] initWithLayer:layer type:type life:100 speed:ccp(-100, 0) spriteFrameName:@"brocoli.png"];
    }
    return enemy;
}

- (id)initWithLayer:(GameLayer *)layer type:(int)type life:(int)life speed:(CGPoint)speed spriteFrameName:(NSString *)spriteFrameName {
    self = [super initWithSpriteFrameName:spriteFrameName];
    
    if (self != nil) {
        _layer = layer;
        _type = type;
        _initY = -1;
        _angleOffset = M_PI * (arc4random() % 100) / 100.0f;
        _animIndex = 0;
        _animTime = 0;
        _life = life;
        _speed = speed;
        _emitter = nil;
        
        // best would be to create enemy subclasses for each type
        if (type == 2) {
            _emitter = [[CCParticleFire alloc] initWithTotalParticles:70];
            _emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"particle2.png"];
            _emitter.startSize = 2;
            _emitter.endSize = 1;
            _emitter.posVar = ccp(0, 0);
            _emitter.speed = 0;
            _emitter.gravity = ccp(1, 0);
            _emitter.startColor = ccc4f(0, 1, 0, 1);
            _emitter.endColor = ccc4f(0, 1, 0, 1);
            _emitter.life = 1;
            _emitter.autoRemoveOnFinish = YES;
            [_layer addChild:_emitter];
        }
    }
    
    return self;
}

- (void)cleanup {
    if (_emitter != nil) {
        [_emitter stopSystem];
    }
    [super cleanup];
}

- (void)update:(ccTime)delta {
    if (_type == 0) {
        // movement
        self.position = ccp(self.position.x + _speed.x * delta, self.position.y + _speed.y * delta);
        
        // animation
        if (_animTime + 0.05f <= _layer.time) {
            _animTime = _layer.time;
            _animIndex = (_animIndex + 1) % 8;
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"carrot000%d.png", _animIndex + 1, nil]]];
        }
    } else if (_type == 1) {
        // movement
        self.position = ccp(self.position.x + _speed.x * delta, self.position.y + _speed.y * delta);
        
        // animation
        if (_animTime + 0.1f <= _layer.time) {
            _animTime = _layer.time;
            _animIndex = (_animIndex + 1) % 6;
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"eggplant000%d.png", _animIndex + 1, nil]]];
        }
    } else if (_type == 2) {
        // movement
        if (_initY < 0) {
            _initY = self.position.y;
        }
        CGPoint oldPos = self.position;
        self.position = ccp(self.position.x + _speed.x * delta, _initY + sinf(_layer.time * 4 + _angleOffset) * 24);
        self.rotation = (self.position.y - oldPos.y) * 8;
        _emitter.position = ccp(self.position.x + self.contentSize.width / 2, self.position.y);
    }
    
    // out of screen
    if (self.position.x < -self.contentSize.width/2) {
        [_layer looseLife];
        self.active = false;
    }
}

- (void)damage:(int)dmg {
    _life -= dmg;
    if (_life <= 0) {
        [_layer monsterKilled:self];
        self.active = false;
    }
}

@end
