//
//  Ghost.h
//  Cocos2DSimpleGame
//
//  Created by AdminMacLC04 on 9/12/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "cocos2d.h"

#import "GameObject.h"
#import "HelloWorldLayer.h"

@interface Ghost : GameObject {
    HelloWorldLayer *_layer;
    float _speed;
    int _type;
    int _initY;
    float _timer;
}

- (id)initWithLayer:(HelloWorldLayer *)layer speed:(float)speed type:(int)type;
- (void)update:(ccTime)delta;

@end
