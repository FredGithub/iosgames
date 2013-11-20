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

- (id)initWithLayer:(GameLayer *)layer;
- (void)update:(ccTime)delta;
- (void)inputWithPoint:(CGPoint)target;

@end
