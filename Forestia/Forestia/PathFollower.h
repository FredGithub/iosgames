//
//  PathFollower.h
//  Forestia
//
//  Created by AdminMacLC04 on 11/20/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "cocos2d.h"

#import "GameObject.h"
#import "GameLayer.h"

@interface PathFollower : GameObject

@property (nonatomic, weak) GameLayer *layer;
@property (nonatomic) float walkForce;
@property (nonatomic) CGPoint targetPoint;
@property (nonatomic, strong) NSArray *currentPath;
@property (nonatomic) int currentPathIndex;
@property (nonatomic, strong) ChipmunkBody *body;
@property (nonatomic, strong) ChipmunkCircleShape *shape;

- (id)initWithLayer:(GameLayer *)layer radius:(float)radius;
- (void)targetWithPoint:(CGPoint)target;

@end
