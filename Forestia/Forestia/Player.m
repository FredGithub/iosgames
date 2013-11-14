//
//  Player.m
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "Player.h"

#define PLAYER_STATE_IDLE 1
#define PLAYER_STATE_WALK 2
#define PLAYER_STATE_WAITING_FOR_ATTACK 3
#define PLAYER_STATE_ATTACK 4

@implementation Player

- (id)initWithLayer:(GameLayer *)layer {
    self = [super init];
    
    if (self != nil) {
        _layer = layer;
        _walkForce = 1000;
        _targetPoint = ccp(0, 0);
        _state = PLAYER_STATE_IDLE;
        _currentPath = nil;
        _currentAnimAction = nil;
        
        // build animations
        NSMutableArray *frames = [NSMutableArray array];
		for(int i = 1; i < 5; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"elf_walk_%04d.png", i]];
			[frames addObject:frame];
		}
        _walkAnim = [CCAnimation animationWithSpriteFrames:frames delay:0.1f];
        
        frames = [NSMutableArray array];
		for(int i = 1; i < 8; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"elf_attack_%04d.png", i]];
			[frames addObject:frame];
		}
        _attackAnim = [CCAnimation animationWithSpriteFrames:frames delay:0.2f];
        
        // setup physic body
        _body = [ChipmunkBody bodyWithMass:1 andMoment:INFINITY];
        _shape = [ChipmunkCircleShape circleWithBody:_body radius:18 offset:cpvzero];
        _shape.friction = 0.1f;
        [layer.space addBody:_body];
        [layer.space addShape:_shape];
        
        [self startIdleState];
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    [_body resetForces];
    
    if (_state == PLAYER_STATE_WALK) {
        // move towards target
        CGPoint dir = ccpSub(_targetPoint, _body.pos);
        if (ccpLengthSQ(dir) > 0) {
            dir = ccpNormalize(dir);
            [_body setAngle:ccpToAngle(dir)];
        }
        [_body applyForce:ccpMult(dir, _walkForce) offset:cpvzero];
        
        // pick next target if we reached the current target
        if (ccpFuzzyEqual(_body.pos, _targetPoint, 10)) {
            // if we have nodes left in our current path
            if (_currentPathIndex < [_currentPath count] - 1) {
                _currentPathIndex++;
                _targetPoint = [self currentPathTargetPoint];
                NSLog(@"%f %f", _targetPoint.x, _targetPoint.y);
            } else {
                NSLog(@"reached end of path");
                [self startIdleState];
            }
        }
    }
    
    // apply friction
    _body.vel = ccpMult(_body.vel, 0.9f);
}

- (void)updateAfterPhysics:(ccTime)delta {
    self.position = _body.pos;
    self.rotation = -ccpToAngle(_body.rot) * 180 / M_PI;
}

- (void)targetWithPoint:(CGPoint)target {
    // get the start and end nodes
    PathNode *startNode = [_layer.graph nodeForIndex:[_layer cellIndexForPosition:_body.pos]];
    PathNode *endNode = [_layer.graph nodeForIndex:[_layer cellIndexForPosition:target]];
    
    // stop if we start outside of graph
    if (startNode == nil || startNode == (id)[NSNull null]) {
        [self startIdleState];
        NSLog(@"starting out of graph");
        return;
    }
    
    // if destination is outside of the graph, create an isolated node
    if (endNode == nil || endNode == (id)[NSNull null]) {
        CGPoint endCell = [_layer cellCoordForPosition:target];
        endNode = [[PathNode alloc] initWithCol:endCell.x row:endCell.y];
    }
    
    // calculate the path
    NSArray *path = [_layer.graph calcPathFrom:startNode to:endNode];
    
    // start to follow the path
    [self startWalkState];
    _currentPath = path;
    _currentPathIndex = 0;
    _targetPoint = [self currentPathTargetPoint];
    NSLog(@"first point %f %f", _targetPoint.x, _targetPoint.y);
    
    /*_targetPoint = target;
    _currentPathIndex = [_currentPath count] - 1;
    [self startWalkState];*/
}

- (void)startIdleState {
    _state = PLAYER_STATE_IDLE;
    [self stopAnimation];
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"elf_idle.png"]];
}

- (void)startWalkState {
    _state = PLAYER_STATE_WALK;
    [self stopAnimation];
    _currentAnimAction = [self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_walkAnim]]];
}

- (void)stopAnimation {
    if (_currentAnimAction != nil) {
        [self stopAction:_currentAnimAction];
    }
}

- (CGPoint)currentPathTargetPoint {
    PathNode *node = _currentPath[_currentPathIndex];
    float x = node.col * _layer.map.tileSize.width + _layer.map.tileSize.width / 2;
    float y = node.row * _layer.map.tileSize.height + _layer.map.tileSize.height / 2;
    return ccp(x, y);
}

@end
