//
//  HelloWorldLayer.m
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright AdminMacLC04 2013. All rights reserved.
//

#import "GameLayer.h"
#import "GameObject.h"
#import "Player.h"
#import "ChipmunkAutoGeometry.h"
#import "Vector.h"
#import "Enemy.h"
#import "Projectile.h"
#import "GameOverLayer.h"

@implementation GameLayer

+ (CCScene *)scene {
    CCScene *scene = [CCScene node];
    
    CCLayer *hudLayer = [[CCLayer alloc] init];
    [scene addChild:hudLayer z:1];
    
    GameLayer *layer = [[GameLayer alloc] initWithHudLayer:hudLayer];
    [scene addChild: layer];
    
    return scene;
}

- (id)initWithHudLayer:(CCLayer *)hudLayer {
    self = [super initWithColor:ccc4(255,255,255,255)];
    
    if (self != nil) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        _hudLayer = hudLayer;
        
        // setup the sprite sheet
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"game.plist"];
        
        // create the ui
        CCSprite *uiBar = [CCSprite spriteWithSpriteFrameName:@"uibar.png"];
        uiBar.position = ccp(5 + uiBar.contentSize.width / 2, winSize.height - 5 - uiBar.contentSize.height / 2);
        [hudLayer addChild:uiBar];
        
        _lifeBar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithSpriteFrameName:@"lifebar.png"]];
        _lifeBar.type = kCCProgressTimerTypeBar;
        _lifeBar.barChangeRate = ccp(1, 0);
        _lifeBar.midpoint = ccp(0, 0.5f);
        _lifeBar.position = ccp(62 + _lifeBar.contentSize.width / 2, winSize.height - 20 - _lifeBar.contentSize.height);
        [hudLayer addChild:_lifeBar];
        
        // load the map
        _map = [CCTMXTiledMap tiledMapWithTMXFile:@"map0.tmx"];
        [self addChild:_map];
        _background = [_map layerNamed:@"background"];
        
        // init physics
        _space = [[ChipmunkSpace alloc] init];
        
        // create terrain static bodies
        [self createTerrainGeometry];
        
        // load the object layer
        CCTMXObjectGroup *objectGroup = [_map objectGroupNamed:@"objects"];
        NSAssert(objectGroup != nil, @"the map needs an object layer");
        
        // init the graph
        _graph = [[PathGraph alloc] initWithMap:_map tileLayer:_background];
        
        // setup the sprite batch
        _gameBatch = [CCSpriteBatchNode batchNodeWithFile:@"game.png"];
        [self addChild:_gameBatch];
        
        // add enemies
        _enemies = [[NSMutableArray alloc] init];
        for (NSDictionary *obj in [objectGroup objects]) {
            if ([obj[@"name"] isEqualToString:@"enemy"]) {
                Enemy *enemy = [[Enemy alloc] initWithLayer:self];
                enemy.body.pos = ccp([obj[@"x"] integerValue], [obj[@"y"] integerValue]);
                [_gameBatch addChild:enemy];
                [_enemies addObject:enemy];
            }
        }
        
        // create the player at spawn point
        _player = [[Player alloc] initWithLayer:self];
        NSDictionary *spawn = [objectGroup objectNamed:@"spawn"];
        _player.body.pos = ccp([spawn[@"x"] integerValue], [spawn[@"y"] integerValue]);
        [_gameBatch addChild:_player];
        
        _projectiles = [NSMutableArray array];
        
        // add the debug nodes
        CCPhysicsDebugNode *physicsDebugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
        physicsDebugNode.visible = NO;
        [self addChild:physicsDebugNode];
        
        _debugRenderer = [[DebugRenderer alloc] initWithGraph:_graph tileSize:_map.tileSize];
        _debugRenderer.drawGraph = NO;
        _debugRenderer.drawPoints = NO;
        [self addChild:_debugRenderer];

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
    
    // find closest hit ennemy
    float minDist = INFINITY;
    Enemy *closestHitEnemy = nil;
    for (Enemy *enemy in _enemies) {
        float dist = ccpDistance(enemy.body.pos, _mousePos);
        if (dist < enemy.shape.radius + 20 && dist < minDist) {
            minDist = dist;
            closestHitEnemy = enemy;
        }
    }
    
    if (closestHitEnemy != nil) {
        [_player inputWithEnemy:closestHitEnemy];
    } else {
        [_player inputWithPoint:_mousePos];
    }
}

- (void)update:(ccTime)dt {
    _time += dt;
    
    NSMutableArray *inactive = [[NSMutableArray alloc] init];
    
    // update all game objects
    [_player update:dt];
    for (Enemy *enemy in _enemies) {
        [enemy update:dt];
    }
    for (Projectile *projectile in _projectiles) {
        [projectile update:dt];
    }
    
    // update physics
    [_space step:dt];
    
    // update after physics
    [_player updateAfterPhysics:dt];
    if (!_player.active) {
        [self lose];
    }
    for (Enemy *enemy in _enemies) {
        [enemy updateAfterPhysics:dt];
        if (!enemy.active) {
            [inactive addObject:enemy];
        }
    }
    for (Projectile *projectile in _projectiles) {
        [projectile updateAfterPhysics:dt];
        if (!projectile.active) {
            [inactive addObject:projectile];
        }
    }
    
    // center camera on player
    [self setViewPointCenter:_player.position];
    
    // remove inactive game objects
    for (GameObject *gameObject in inactive) {
        if ([gameObject isKindOfClass:[Enemy class]]) {
            [_enemies removeObject:gameObject];
            [_gameBatch removeChild:gameObject cleanup:YES];
            // TODO: remove from space
        } else if ([gameObject isKindOfClass:[Projectile class]]) {
            [_projectiles removeObject:gameObject];
            [_gameBatch removeChild:gameObject cleanup:YES];
        }
    }
    
    // handle winning
    if ([_enemies count] == 0) {
        [self win];
    }
}

- (CGPoint)cellCoordForPosition:(CGPoint)pos {
    int col = pos.x / _map.tileSize.width;
    int row = pos.y / _map.tileSize.height;
    return ccp(col, row);
}

- (int)cellIndexForPosition:(CGPoint)pos {
    int col = pos.x / _map.tileSize.width;
    int row = pos.y / _map.tileSize.height;
    return col * _map.mapSize.height + row;
}

- (NSArray *)pathFrom:(CGPoint)start to:(CGPoint)end {
    // get the start and end nodes
    PathNode *startNode = [_graph nodeForIndex:[self cellIndexForPosition:start]];
    PathNode *endNode = [_graph nodeForIndex:[self cellIndexForPosition:end]];
    BOOL destInGraph = YES;
    
    // stop if we start outside of graph
    if (startNode == nil || startNode == (id)[NSNull null]) {
        NSLog(@"starting out of graph");
        return nil;
    }
    
    // if destination is outside of the graph, create an isolated node
    if (endNode == nil || endNode == (id)[NSNull null]) {
        CGPoint endCell = [self cellCoordForPosition:end];
        endNode = [[PathNode alloc] initWithCol:endCell.x row:endCell.y];
        destInGraph = NO;
    }
    
    // calculate the node path
    NSArray *path = [_graph calcPathFrom:startNode to:endNode];
    
    // get the simplified vector path
    NSMutableArray *vecPath = [NSMutableArray array];
    Vector *init = [[Vector alloc] initWithX:start.x y:start.y];
    Vector *current = nil;
    Vector *prev = nil;
    for (int i = 0; i < [path count]; i++) {
        PathNode *node = path[i];
        float x = node.col * _map.tileSize.width + _map.tileSize.width / 2;
        float y = node.row * _map.tileSize.height + _map.tileSize.height / 2;
        prev = current;
        current = [[Vector alloc] initWithX:x y:y];
        NSArray *hitObjects = [_space segmentQueryAllFrom:ccp(init.x, init.y) to:ccp(current.x, current.y) layers:COLLISION_TERRAIN_ONLY group:CP_NO_GROUP];
        BOOL hit = [hitObjects count] > 0;
        if (hit) {
            [vecPath addObject:prev];
            init = prev;
        }
    }
    
    // add final node
    if (destInGraph) {
        [vecPath addObject:[[Vector alloc] initWithX:end.x y:end.y]];
    } else {
        [vecPath addObject:current];
    }
    
    return vecPath;
}

- (void)addProjectile:(Projectile *)projectile {
    [_projectiles addObject:projectile];
    [_gameBatch addChild:projectile];
}

/* Private methods */

- (void)setViewPointCenter:(CGPoint)position {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    int x = MAX(position.x, winSize.width / 2);
    int y = MAX(position.y, winSize.height / 2);
    x = MIN(x, (_map.mapSize.width * _map.tileSize.width) - winSize.width / 2);
    y = MIN(y, (_map.mapSize.height * _map.tileSize.height) - winSize.height / 2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width / 2, winSize.height / 2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
}

- (void)createTerrainGeometry {
    int tileCountW = _background.layerSize.width;
    int tileCountH = _background.layerSize.height;
    
    // create the sampler
    ChipmunkBlockSampler *sampler = [[ChipmunkBlockSampler alloc] initWithBlock:^(cpVect point){
        point = cpBBClampVect(cpBBNew(0.5, 0.5, tileCountW - 0.5, tileCountH - 0.5), point);
        int x = point.x;
        int y = point.y;
        y = tileCountH - 1 - y;
        NSDictionary *properties = [_map propertiesForGID:[_background tileGIDAt:ccp(x, y)]];
        BOOL walkable = [[properties valueForKey:@"walkable"] isEqualToString:@"true"];
        return (walkable ? 0.0f : 1.0f);
    }];
    
    // execute marching algorithm
    cpBB sampleRect = cpBBNew(-0.5, -0.5, tileCountW + 0.5, tileCountH + 0.5);
    ChipmunkPolylineSet *polylines = [sampler march:sampleRect xSamples:tileCountW + 2 ySamples:tileCountH + 2 hard:TRUE];
    cpFloat s = _map.tileSize.height;
    
    // add polylines to space
    for(ChipmunkPolyline * line in polylines) {
        ChipmunkPolyline * simplified = [line simplifyCurves:0.0f];
        for(int i = 0; i < simplified.count - 1; i++) {
            cpVect a = cpvmult(simplified.verts[i], s);
            cpVect b = cpvmult(simplified.verts[i + 1], s);
            ChipmunkShape *seg = [_space add:[ChipmunkSegmentShape segmentWithBody:_space.staticBody from:a to:b radius:1.0f]];
            seg.friction = 1.0;
            seg.layers = COLLISION_TERRAIN_ONLY | COLLISION_TERRAIN;
        }
    }
    
    // add left wall
    ChipmunkShape *segLeft = [ChipmunkSegmentShape segmentWithBody:_space.staticBody from:cpv(0, 0) to:cpv(0, tileCountH * s) radius:1.0f];
    segLeft.layers = COLLISION_TERRAIN_ONLY | COLLISION_TERRAIN;
    [_space add:segLeft];
    
    // add top wall
    ChipmunkShape *segTop = [ChipmunkSegmentShape segmentWithBody:_space.staticBody from:cpv(0, tileCountH * s) to:cpv(tileCountW * s, tileCountH * s) radius:1.0f];
    segTop.layers = COLLISION_TERRAIN_ONLY | COLLISION_TERRAIN;
    [_space add:segTop];
    
    // add right wall
    ChipmunkShape *segRight = [ChipmunkSegmentShape segmentWithBody:_space.staticBody from:cpv(tileCountW * s, tileCountH * s) to:cpv(tileCountW * s, 0) radius:1.0f];
    segRight.layers = COLLISION_TERRAIN_ONLY | COLLISION_TERRAIN;
    [_space add:segRight];
    
    // add bottom wall
    ChipmunkShape *segBottom = [ChipmunkSegmentShape segmentWithBody:_space.staticBody from:cpv(tileCountW * s, 0) to:cpv(0, 0) radius:1.0f];
    segBottom.layers = COLLISION_TERRAIN_ONLY | COLLISION_TERRAIN;
    [_space add:segBottom];
}

- (void)win {
    CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:gameOverScene]];
}

- (void)lose {
    CCScene *gameOverScene = [GameOverLayer sceneWithWon:NO];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:gameOverScene]];
}

@end
