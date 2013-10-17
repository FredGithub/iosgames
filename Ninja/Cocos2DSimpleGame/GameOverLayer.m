//
//  GameOverLayer.m
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 11/13/12.
//  Copyright 2012 Razeware LLC. All rights reserved.
//

#import "GameOverLayer.h"
#import "GameLayer.h"

@implementation GameOverLayer

+ (CCScene *)sceneWithWon:(BOOL)won {
    CCScene *scene = [CCScene node];
    GameOverLayer *layer = [[GameOverLayer alloc] initWithWon:won];
    [scene addChild: layer];
    return scene;
}

- (id)initWithWon:(BOOL)won {
    self = [super initWithColor:ccc4(255, 255, 255, 255)];
    
    if (self != nil) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // setup the background
        CCSprite *background = [[CCSprite alloc] initWithFile:@"background.png"];
        background.position = ccp(winSize.width / 2, winSize.height / 2);
        [self addChild:background];
        
        // setup the popup message
        CCSprite *message;
        if (won) {
            message = [[CCSprite alloc] initWithFile:@"you_win.png"];
        } else {
            message = [[CCSprite alloc] initWithFile:@"game_over.png"];
        }
        message.position = ccp(winSize.width / 2, winSize.height / 2);
        [self addChild:message];
        
        [self runAction:
         [CCSequence actions:
          [CCDelayTime actionWithDuration:3],
          [CCCallBlockN actionWithBlock:^(CCNode *node) {
             [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
        }], nil]];
    }
    
    return self;
}

@end
