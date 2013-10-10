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
        enemy = [[Enemy alloc] initWithLayer:layer type:type file:@"ghost.png"];
    } else if (type == 1) {
        enemy = [[Enemy alloc] initWithLayer:layer type:type spriteFrameName:@"caveman1.png"];
    }
    return enemy;
}

- (id)initWithLayer:(GameLayer *)layer type:(int)type file:(NSString *)file {
    self = [super initWithFile:file];
    
    if (self != nil) {
        _layer = layer;
        _type = type;
        _initY = -1;
        _animIndex = 0;
        _animTime = 0;
        self.speed = ccp(-120, 0);
    }
    
    return self;
}

- (id)initWithLayer:(GameLayer *)layer type:(int)type spriteFrameName:(NSString *)spriteFrameName {
    self = [super initWithSpriteFrameName:spriteFrameName];
    
    if (self != nil) {
        _layer = layer;
        _type = type;
        _initY = -1;
        _animIndex = 0;
        _animTime = 0;
        self.speed = ccp(-120, 0);
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    if (_type == 0) {
        // movement
        self.position = ccp(self.position.x + self.speed.x * delta, self.position.y + self.speed.y * delta);
    } else if (_type == 1) {
        // movement
        if (_initY < 0) {
            _initY = self.position.y;
        }
        self.position = ccp(self.position.x + self.speed.x * delta, _initY + sinf(_layer.time * 4) * 24);
        
        // animation
        if (_animTime + 0.1f <= _layer.time) {
            _animTime = _layer.time;
            _animIndex = (_animIndex + 1) % 8;
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"caveman%d.png", _animIndex + 1, nil]]];
        }
    }
    
    // out of screen
    if (self.position.x < -self.contentSize.width/2) {
        _layer.lifes--;
        [_layer refreshLives];
        self.active = false;
    }
}

@end
