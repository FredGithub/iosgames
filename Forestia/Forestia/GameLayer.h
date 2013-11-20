//
//  HelloWorldLayer.h
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright AdminMacLC04 2013. All rights reserved.
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"

#import "PathGraph.h"
#import "DebugRenderer.h"

#define COLLISION_TERRAIN_ONLY 1
#define COLLISION_TERRAIN 2
#define COLLISION_PLAYER 4
#define COLLISION_PLAYER_BULLET 8
#define COLLISION_ENEMY_BULLET 16

@class Player;

@interface GameLayer : CCLayerColor

@property (nonatomic, strong) CCTMXTiledMap *map;
@property (nonatomic, strong) CCTMXLayer *background;
@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) NSMutableArray *enemies;
@property (nonatomic, strong) CCSpriteBatchNode *gameBatch;
@property (nonatomic, strong) PathGraph *graph;
@property (nonatomic) BOOL mouseDown;
@property (nonatomic) CGPoint mousePos;
@property (nonatomic) float time;
@property (nonatomic, strong) ChipmunkSpace *space;
@property (nonatomic, strong) DebugRenderer *debugRenderer;

+ (CCScene *)scene;

- (CGPoint)cellCoordForPosition:(CGPoint)pos;
- (int)cellIndexForPosition:(CGPoint)pos;
- (NSArray *)pathFrom:(CGPoint)start to:(CGPoint)end;

@end
