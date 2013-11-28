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

#define UNIT_STATE_IDLE 1
#define UNIT_STATE_WALK 2
#define UNIT_STATE_CHASE 3
#define UNIT_STATE_WAITING_FOR_ATTACK 4
#define UNIT_STATE_ATTACK 5

@interface Unit : GameObject

@property (nonatomic, weak) GameLayer *layer;

@property (nonatomic) int state;
@property (nonatomic) CGPoint targetPoint;
@property (nonatomic, weak) Unit *targetUnit;
@property (nonatomic, strong) NSArray *currentPath;
@property (nonatomic) int currentPathIndex;
@property (nonatomic) float lastPathTime;

@property (nonatomic) float walkForce;
@property (nonatomic) int attackRange;
@property (nonatomic) float reloadTime;
@property (nonatomic) float lastAttackTime;
@property (nonatomic) float damage;
@property (nonatomic) BOOL attackApplied;
@property (nonatomic) float attackDelay;
@property (nonatomic) float maxLife;
@property (nonatomic) float life;

@property (nonatomic, strong) CCAction *currentAnimAction;
@property (nonatomic, strong) CCAnimation *idleAnim;
@property (nonatomic, strong) CCAnimation *walkAnim;
@property (nonatomic, strong) CCAnimation *attackAnim;

@property (nonatomic, weak) CCSprite *selection;

@property (nonatomic, strong) ChipmunkBody *body;
@property (nonatomic, strong) ChipmunkCircleShape *shape;

- (id)initWithLayer:(GameLayer *)layer radius:(float)radius mass:(float)mass;
- (void)targetWithPoint:(CGPoint)target;
- (void)damageWithAmount:(float)amount;
- (void)startIdleState;
- (void)startWalkState;
- (void)startChaseState;
- (void)startWaitingForAttackState;
- (void)startAttackState;
- (void)showSelection;
- (void)hideSelection;

@end
