//
//  Player.h
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "cocos2d.h"

#import "Unit.h"
#import "GameLayer.h"
#import "Enemy.h"

@interface Player : Unit

- (id)initWithLayer:(GameLayer *)layer;
- (void)inputWithPoint:(CGPoint)target;
- (void)inputWithEnemy:(Enemy *)enemy;

@end
