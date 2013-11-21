//
//  Enemy.h
//  Forestia
//
//  Created by AdminMacLC04 on 11/7/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "cocos2d.h"

#import "PathFollower.h"
#import "GameLayer.h"

@interface Enemy : PathFollower

@property (nonatomic) int state;
@property (nonatomic, strong) CCAction *currentAnimAction;
@property (nonatomic, strong) CCAnimation *walkAnim;
@property (nonatomic, strong) CCAnimation *attackAnim;
@property (nonatomic) float lastAttackTime;

- (id)initWithLayer:(GameLayer *)layer;

@end
