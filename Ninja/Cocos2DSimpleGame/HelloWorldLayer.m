//
//  HelloWorldLayer.m
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 11/13/12.
//  Copyright Razeware LLC 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"
#import "GameOverLayer.h"
#import "LevelManager.h"
#import "Ghost.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    HelloWorldLayer *layer = [HelloWorldLayer node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

- (void) initWithUI {
    
}

- (void)addMonster {
    int rand = arc4random()%2;
    NSLog(@"%d", rand);
    Ghost *ghost = [[Ghost alloc] initWithLayer:self file:@"monster.png" speed:2 type:rand];
    
    // Determine where to spawn the monster along the Y axis
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int minY = ghost.contentSize.height / 2;
    int maxY = winSize.height - ghost.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    ghost.position = ccp(winSize.width + ghost.contentSize.width/2, actualY);
    [self addChild:ghost];
    
    ghost.tag = 1;
    [_monsters addObject:ghost];
}

- (void)addBonus {
    CCSprite *bonus = [CCSprite spriteWithFile:@"heart.png"];
    bonus.scale = 0.5;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int minY = bonus.contentSize.height / 2;
    int maxY = winSize.height - bonus.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    bonus.position = ccp(winSize.width + bonus.contentSize.width/2, actualY);
    [self addChild:bonus];
    
    CCMoveTo * actionMove = [CCMoveTo actionWithDuration:6 position:ccp(-bonus.contentSize.width/2, actualY)];
    CCCallBlockN * actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [_bonuses removeObject:node];
        [node removeFromParentAndCleanup:YES];
    }];
    [bonus runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
    bonus.tag = 3;
    [_bonuses addObject:bonus];
}

- (void)gameLogic:(ccTime)dt {
    float bonusPercentage = 0.1;
    float rand = arc4random_uniform(100)/100.0;
    if(rand > bonusPercentage){
        [self addMonster];
    }else{
        [self addBonus];
    }
}

- (void)looseLife {
    _lifes--;
    if (_lifes == 0) {
        CCScene *gameOverScene = [GameOverLayer sceneWithWon:NO];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
    } else {
        _lifes--;
        [self refreshLives];
    }
}
 
- (id)init {
    self = [super initWithColor:ccc4(255,255,255,255)];
    
    if (self != nil) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCSprite *player = [CCSprite spriteWithFile:@"player.png"];
        player.position = ccp(player.contentSize.width/2, winSize.height/2);
        [self addChild:player];
        
        _monstersGoals = [NSArray arrayWithObjects:@(5), @(10), @(15), @(20), @(30), nil];
        
        _lifes = 3;
        _lifeSprites = [[NSMutableArray alloc] init];
        for(int i=0; i<3; i++){
            CCSprite *life = [CCSprite spriteWithFile:@"heart.png"];
            life.position = ccp(winSize.width/2 + (i - 1)*(life.contentSize.width + 5), winSize.height - life.contentSize.height/2 - 10);
            [self addChild:life];
            [_lifeSprites addObject:life];
        }
        [self refreshLives];
        
        _monstersLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Monsters %d/%d", _monstersDestroyed, [self levelObjective]] fontName:@"Helvetica" fontSize:15];
        _monstersLabel.color = ccc3(0, 0, 0);
        _monstersLabel.position = ccp(_monstersLabel.contentSize.width/2 + 10, winSize.height - _monstersLabel.contentSize.height/2 - 10);
        [self addChild:_monstersLabel];
        
        _levelLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Level %d", [LevelManager sharedLevelManager].level + 1] fontName:@"Helvetica" fontSize:15];
        _levelLabel.color = ccc3(0, 0, 0);
        _levelLabel.position = ccp(winSize.width - _levelLabel.contentSize.width/2 - 10, winSize.height - _monstersLabel.contentSize.height/2 - 10);
        [self addChild:_levelLabel];
        
        _comboLabel = [CCLabelTTF labelWithString:@"" fontName:@"Helvetica" fontSize:12];
        _comboLabel.color = ccc3(0, 0, 0);
        _comboLabel.position = ccp(winSize.width/2, winSize.height - _monstersLabel.contentSize.height/2 - 40);
        [self addChild:_comboLabel];
    
        [self schedule:@selector(gameLogic:) interval:1.0];
        
        [self setTouchEnabled:YES];
        
        _monsters = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
        _bonuses = [[NSMutableArray alloc] init];

        [self schedule:@selector(update:)];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
    }
    
    return self;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    // Set up initial location of projectile
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *projectile = [CCSprite spriteWithFile:@"projectile.png"
                                               rect:CGRectMake(0, 0, 20, 20)];
    projectile.position = ccp(20, winSize.height/2);
    
    // Determine offset of location to projectile
    CGPoint offset = ccpSub(location, projectile.position);
    
    // Bail out if you are shooting down or backwards
    if (offset.x <= 0) return;
    
    // Ok to add now - we've double checked position
    [self addChild:projectile];
    
    int realX = winSize.width + (projectile.contentSize.width/2);
    float ratio = (float) offset.y / (float) offset.x;
    int realY = (realX * ratio) + projectile.position.y;
    CGPoint realDest = ccp(realX, realY);
    
    // Determine the length of how far you're shooting
    int offRealX = realX - projectile.position.x;
    int offRealY = realY - projectile.position.y;
    float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
    float velocity = 480/1; // 480pixels/1sec
    float realMoveDuration = length/velocity;
    
    // Move projectile to actual endpoint
    [projectile runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
      [CCCallBlockN actionWithBlock:^(CCNode *node) {
         [_projectiles removeObject:node];
         [node removeFromParentAndCleanup:YES];
         [self setCombo:0];
    }],
      nil]];
    
    projectile.tag = 2;
    [_projectiles addObject:projectile];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
}

- (void)update:(ccTime)dt {
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    for (CCSprite *projectile in _projectiles) {
        
        NSMutableArray *monstersToDelete = [[NSMutableArray alloc] init];
        for (CCSprite *monster in _monsters) {
            if (CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox)) {
                [monstersToDelete addObject:monster];
            }
        }
        
        for (CCSprite *monster in monstersToDelete) {
            [_monsters removeObject:monster];
            [self removeChild:monster cleanup:YES];
            _monstersDestroyed++;
            [self setCombo:_combo + 1];
            [_monstersLabel setString:[NSString stringWithFormat:@"Monsters %d/%d", _monstersDestroyed, [self levelObjective]]];
            if (_monstersDestroyed >= [self levelObjective]) {
                [LevelManager sharedLevelManager].level++;
                CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
                [[CCDirector sharedDirector] replaceScene:gameOverScene];
            }
        }
        
        NSMutableArray *bonusesToDelete = [[NSMutableArray alloc] init];
        for (CCSprite *bonus in _bonuses) {
            if (CGRectIntersectsRect(projectile.boundingBox, bonus.boundingBox)) {
                [bonusesToDelete addObject:bonus];
            }
        }
        
        for (CCSprite *bonus in bonusesToDelete) {
            [_bonuses removeObject:bonus];
            [self removeChild:bonus cleanup:YES];
            if(_lifes < 3){
                _lifes++;
                [self refreshLives];
            }
        }
        
        if (monstersToDelete.count > 0 || bonusesToDelete.count > 0) {
            [projectilesToDelete addObject:projectile];
        }
    }
    
    for (CCSprite *projectile in projectilesToDelete) {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    
    NSMutableArray *monstersToDelete = [[NSMutableArray alloc] init];
    for (Ghost *ghost in _monsters) {
        [ghost update:dt];
        if (!ghost.active) {
            [monstersToDelete addObject:ghost];
        }
    }
    
    for (CCSprite *monster in monstersToDelete) {
        [_monsters removeObject:monster];
        [self removeChild:monster cleanup:YES];
    }
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    _monsters = nil;
    _projectiles = nil;
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] dismissModalViewControllerAnimated:YES];
}

-(int) levelObjective
{
    int level = [LevelManager sharedLevelManager].level;
    if(level >= [_monstersGoals count]){
        level = [_monstersGoals count] - 1;
    }
    return [_monstersGoals[level] intValue];
}

-(void) refreshLives
{
    for(int i=0; i<3; i++){
        if(_lifes > i){
            [_lifeSprites[i] setTexture:[[CCTextureCache sharedTextureCache] addImage:@"heart.png"]];
        }else{
            [_lifeSprites[i] setTexture:[[CCTextureCache sharedTextureCache] addImage:@"heartempty.png"]];
        }
    }
}

-(void) setCombo:(int) combo
{
    _combo = combo;
    if(_combo > 0) {
        [_comboLabel setString:[NSString stringWithFormat:@"Combo x%d", _combo]];
    }else{
        [_comboLabel setString:@""];
    }
}

@end
