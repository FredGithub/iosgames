//
//  Player.h
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "cocos2d.h"

#import "PathFollower.h"
#import "GameLayer.h"

@interface Player : PathFollower

@property (nonatomic) int state;
@property (nonatomic, strong) CCAction *currentAnimAction;
@property (nonatomic, strong) CCAnimation *walkAnim;
@property (nonatomic, strong) CCAnimation *attackAnim;
@property (nonatomic) float life;
@property (nonatomic) float maxLife;

- (id)initWithLayer:(GameLayer *)layer;
- (void)inputWithPoint:(CGPoint)target;
- (void)damageWithAmount:(float)amount;

@end
