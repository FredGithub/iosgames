//
//  HelloWorldLayer.m
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright AdminMacLC04 2013. All rights reserved.
//

#import "GameLayer.h"
#import "AppDelegate.h"
#import "GameObject.h"
#import "Player.h"
#import "PathDebugRenderer.h"

@implementation GameLayer

+ (CCScene *)scene {
    CCScene *scene = [CCScene node];
    GameLayer *layer = [GameLayer node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

- (id)init {
    self = [super initWithColor:ccc4(255,255,255,255)];
    
    if (self != nil) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        // load the map
        _tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"map0.tmx"];
        [self addChild:_tileMap];
        _background = [_tileMap layerNamed:@"background"];
        
        // load the object layer
        CCTMXObjectGroup *objectGroup = [_tileMap objectGroupNamed:@"objects"];
        NSAssert(objectGroup != nil, @"the map needs an object layer");
        
        // init the graph and the debug renderer
        _graph = [[PathGraph alloc] initWithMap:_tileMap tileLayer:_background];
        PathDebugRenderer *renderer = [[PathDebugRenderer alloc] initWithGraph:_graph tileSize:_tileMap.tileSize];
        [self addChild:renderer];
        
        // create the player
        _player = [[Player alloc] initWithLayer:self];
        [self addChild:_player];
        
        // position the player at spawn point
        NSDictionary *spawnPoint = [objectGroup objectNamed:@"spawn"];
        int x = [spawnPoint[@"x"] integerValue];
        int y = [spawnPoint[@"y"] integerValue];
        _player.position = ccp(x, y);
        
        // init the game object arrays
        _enemies = [[NSMutableArray alloc] init];
        
        // set the intervals
        [self schedule:@selector(update:)];
        
        // enable touch
        [self setTouchEnabled:YES];
    }
    
    return self;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _mousePos = [self convertTouchToNodeSpace:touch];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _mousePos = [self convertTouchToNodeSpace:touch];
    _mouseDown = YES;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _mousePos = [self convertTouchToNodeSpace:touch];
    _mouseDown = NO;
    
    [_player targetWithPoint:_mousePos];
}

- (void)update:(ccTime)dt {
    _time += dt;
    
    NSMutableArray *inactive = [[NSMutableArray alloc] init];
    
    // update player
    [_player update:dt];
    
    // center camera on player
    [self setViewPointCenter:_player.position];
    
    // update enemies
    for (GameObject *enemy in _enemies) {
        [enemy update:dt];
        
        if (!enemy.active) {
            [inactive addObject:enemy];
        }
    }
    
    // remove inactive game objects
    for (GameObject *gameObject in inactive) {
        if ([gameObject isKindOfClass:[GameObject class]]) {
            [_enemies removeObject:gameObject];
            [self removeChild:gameObject cleanup:YES];
        }
    }
}

/* Private methods */

- (void)setViewPointCenter:(CGPoint)position {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    int x = MAX(position.x, winSize.width / 2);
    int y = MAX(position.y, winSize.height / 2);
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width) - winSize.width / 2);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height) - winSize.height / 2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width / 2, winSize.height / 2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
}

- (void)win {
    //CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
    //[[CCDirector sharedDirector] replaceScene:gameOverScene];
}

@end
