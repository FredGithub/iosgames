//
//  Ghost.m
//  Cocos2DSimpleGame
//
//  Created by AdminMacLC04 on 9/12/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Ghost.h"

@implementation Ghost

- (id)initWithLayer:(HelloWorldLayer *)layer speed:(float)speed type:(int)type {
    self = [super initWithFile:@"monster.png"];
    
    if (self != nil) {
        _layer = layer;
        _speed = speed;
        _type = type;
        _initY = -1;
        _timer = 0;
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    _timer += delta;
    
    if (_initY < 0) {
        _initY = self.position.y;
    }
    
    if (_type == 0) {
        self.position = ccp(self.position.x - _speed, self.position.y);
    } else if (_type == 1) {
        self.position = ccp(self.position.x - _speed, _initY + sinf(_timer * _speed * 3) * 20);
    }
    
    if (self.position.x < -self.contentSize.width/2) {
        [_layer looseLife];
        self.active = false;
    }
}

@end
