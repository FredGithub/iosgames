//
//  HelloWorldLayer.h
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright AdminMacLC04 2013. All rights reserved.
//

#import "cocos2d.h"

@class Player;

@interface GameLayer : CCLayerColor {
    CCTMXTiledMap *_tileMap;
    CCTMXLayer *_background;
    Player *_player;
    NSMutableArray *_enemies;
    CCSpriteBatchNode *_enemyBatch;
    
    BOOL _mouseDown;
    CGPoint _mousePos;
}

@property float time;

+ (CCScene *)scene;

@end
