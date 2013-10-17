//
//  Ghost.h
//  Cocos2DSimpleGame
//
//  Created by AdminMacLC04 on 9/12/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "cocos2d.h"

#import "GameObject.h"
#import "GameLayer.h"

@interface Enemy : GameObject {
    GameLayer *_layer;
    int _initY;
    float _angleOffset;
    int _animIndex;
    float _animTime;
};

@property int type;
@property int life;
@property CGPoint speed;

+ (id)createEnemyWithLayer:(GameLayer *)layer type:(int)type;

- (id)initWithLayer:(GameLayer *)layer type:(int)type life:(int)life speed:(CGPoint)speed spriteFrameName:(NSString *)spriteFrameName;
- (void)update:(ccTime)delta;
- (void)damage:(int)dmg;

@end
