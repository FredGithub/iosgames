//
//  Player.h
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "cocos2d.h"

#import "GameObject.h"
#import "GameLayer.h"

@interface Player : GameObject

@property (nonatomic, weak) GameLayer *layer;
@property (nonatomic) float speed;
@property (nonatomic) CGPoint targetPoint;
@property (nonatomic) int state;
@property (nonatomic, strong) NSArray *currentPath;
@property (nonatomic) int currentPathIndex;
@property (nonatomic, strong) CCAction *currentAnimAction;
@property (nonatomic, strong) CCAnimation *walkAnim;
@property (nonatomic, strong) CCAnimation *attackAnim;
@property (nonatomic, strong) ChipmunkBody *body;
@property (nonatomic, strong) ChipmunkShape *shape;

- (id)initWithLayer:(GameLayer *)layer;
- (void)update:(ccTime)delta;
- (void)targetWithPoint:(CGPoint)target;

@end
