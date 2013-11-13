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

+ (CCScene *)scene;

- (CGPoint)cellCoordForPosition:(CGPoint)pos;
- (int)cellIndexForPosition:(CGPoint)pos;

@end
