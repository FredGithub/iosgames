//
//  Ghost.h
//  Cocos2DSimpleGame
//
//  Created by AdminMacLC04 on 9/12/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "cocos2d.h"

#import "HelloWorldLayer.h"

@interface Ghost : CCSprite {
    HelloWorldLayer *_layer;
    float _speed;
    int _type;
    int _initY;
    float _timer;
}

@property bool active;

- (id)initWithLayer:(HelloWorldLayer *)layer file:(NSString *)filename speed:(float)speed type:(int)type;
- (void)update:(ccTime)delta;

@end
