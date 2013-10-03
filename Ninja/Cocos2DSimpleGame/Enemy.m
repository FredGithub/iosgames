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
        enemy = [[Enemy alloc] initWithLayer:layer type:type file:@"projectile.png"];
    }
    return enemy;
}

- (id)initWithLayer:(GameLayer *)layer type:(int)type file:(NSString *)file {
    self = [super initWithFile:file];
    
    if (self != nil) {
        _layer = layer;
        _type = type;
        _initY = -1;
        _timer = 0;
        self.speed = ccp(-120, 0);
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    _timer += delta;
    
    if (_initY < 0) {
        _initY = self.position.y;
    }
    
    if (_type == 0) {
        self.position = ccp(self.position.x + self.speed.x * delta, self.position.y + self.speed.y * delta);
    } else if (_type == 1) {
        self.position = ccp(self.position.x + self.speed.x * delta, _initY + sinf(_timer * 4) * 24);
    }
    
    if (self.position.x < -self.contentSize.width/2) {
        _layer.lifes--;
        [_layer refreshLives];
        self.active = false;
    }
}

@end
