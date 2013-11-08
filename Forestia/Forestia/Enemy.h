//
//  Enemy.h
//  Forestia
//
//  Created by AdminMacLC04 on 11/7/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "GameObject.h"
#import "GameLayer.h"

@interface Enemy : GameObject

@property (nonatomic, weak) GameLayer *layer;
@property (nonatomic) float speed;
@property (nonatomic) CGPoint targetPoint;
@property (nonatomic) int state;
@property (nonatomic, strong) NSArray *currentPath;
@property (nonatomic) int currentPathIndex;
@property (nonatomic, strong) CCAction *currentAnimAction;
@property (nonatomic, strong) CCAnimation *walkAnim;
@property (nonatomic, strong) CCAnimation *attackAnim;

- (id)initWithLayer:(GameLayer *)layer;
- (void)update:(ccTime)delta;

@end
