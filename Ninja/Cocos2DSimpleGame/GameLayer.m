//
//  HelloWorldLayer.m
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 11/13/12.
//  Copyright Razeware LLC 2012. All rights reserved.
//

#import "GameLayer.h"
#import "SimpleAudioEngine.h"
#import "GameOverLayer.h"
#import "LevelManager.h"
#import "Enemy.h"
#import "Bonus.h"
#import "Projectile.h"

#import "AppDelegate.h"

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
        // init game constants
        _monstersGoals = [NSArray arrayWithObjects:@(500), @(10), @(15), @(20), @(30), nil];
        _weaponReloadTimes = [NSArray arrayWithObjects:@(100), @(500), nil];
        
        // create the player
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCSprite *player = [CCSprite spriteWithFile:@"player.png"];
        player.position = ccp(player.contentSize.width/2, winSize.height/2);
        [self addChild:player];
        
        // init the game object arrays
        _monsters = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
        _bonuses = [[NSMutableArray alloc] init];
        
        // setup the level
        int level = [LevelManager sharedLevelManager].level;
        if (level >= [_monstersGoals count]) {
            level = [_monstersGoals count] - 1;
        }
        _levelObjective = [_monstersGoals[level] intValue];
        _lifes = 3;
        _currentWeapon = 0;
        _time = 0;
        _lastShootTime = -1000;
        _mouseDown = NO;
        _mousePos = ccp(0, 0);
        
        // create the UI
        _monstersLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Monsters %d/%d", _monstersDestroyed, _levelObjective] fontName:@"Helvetica" fontSize:15];
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
        
        _lifeSprites = [[NSMutableArray alloc] init];
        for(int i=0; i<3; i++){
            CCSprite *life = [CCSprite spriteWithFile:@"heart.png"];
            life.position = ccp(winSize.width/2 + (i - 1)*(life.contentSize.width + 5), winSize.height - life.contentSize.height/2 - 10);
            [self addChild:life];
            [_lifeSprites addObject:life];
        }
        [self refreshLives];
        
        // set the intervals
        [self schedule:@selector(gameLogic:) interval:1.0];
        [self schedule:@selector(update:)];
        
        // enable touch
        [self setTouchEnabled:YES];
        
        // play the music
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
    }
    
    return self;
}

- (void)addMonster {
    Enemy *enemy = [Enemy createEnemyWithLayer:self type:arc4random()%2];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int minY = enemy.contentSize.height / 2;
    int maxY = winSize.height - enemy.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    enemy.position = ccp(winSize.width + enemy.contentSize.width/2, actualY);
    enemy.tag = 1;
    [_monsters addObject:enemy];
    [self addChild:enemy];
}

- (void)addBonus {
    Bonus *bonus = [Bonus createBonusWithLayer:self type:arc4random()%2];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int minY = bonus.contentSize.height / 2;
    int maxY = winSize.height - bonus.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    bonus.position = ccp(winSize.width + bonus.contentSize.width/2, actualY);
    bonus.tag = 3;
    [_bonuses addObject:bonus];
    [self addChild:bonus];
}

- (void)gameLogic:(ccTime)dt {
    float bonusPercentage = 0.1f;
    float rand = arc4random_uniform(100)/100.0f;
    if (rand > bonusPercentage) {
        [self addMonster];
    } else {
        [self addBonus];
    }
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
}

- (void)update:(ccTime)dt {
    _time += dt;
    
    // handle shoot
    if (_mouseDown && _mousePos.x > 20) {
        
        // if the weapon is reloaded
        if ((_time - _lastShootTime) * 1000 >= [_weaponReloadTimes[_currentWeapon+1] intValue]) {
            if (_currentWeapon == 0) {
                Projectile *projectile = [Projectile createProjectileWithLayer:self type:_currentWeapon];
                CGSize winSize = [[CCDirector sharedDirector] winSize];
                projectile.position = ccp(20, winSize.height/2);
                projectile.speed = ccpMult(ccpNormalize(ccpSub(_mousePos, projectile.position)), 500);
                projectile.tag = 2;
                
                [_projectiles addObject:projectile];
                [self addChild:projectile];
                
                [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
            } else if (_currentWeapon == 1) {
                Projectile *projectile = [Projectile createProjectileWithLayer:self type:_currentWeapon];
                CGSize winSize = [[CCDirector sharedDirector] winSize];
                projectile.position = ccp(20, winSize.height/2);
                projectile.speed = ccpMult(ccpNormalize(ccpSub(_mousePos, projectile.position)), 500);
                projectile.tag = 2;
                
                [_projectiles addObject:projectile];
                [self addChild:projectile];
                
                [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
            }
            _lastShootTime = _time;
        }
    }
    
    NSMutableArray *inactive = [[NSMutableArray alloc] init];
    
    // update projectiles
    for (GameObject *projectile in _projectiles) {
        [projectile update:dt];
        
        // collisions with ennemies
        for (Enemy *enemy in _monsters) {
            if (CGRectIntersectsRect(projectile.boundingBox, enemy.boundingBox)) {
                projectile.active = false;
                enemy.active = false;
                _monstersDestroyed++;
                _combo++;
                [self refreshCombo];
                [_monstersLabel setString:[NSString stringWithFormat:@"Monsters %d/%d", _monstersDestroyed, _levelObjective]];
            }
        }
        
        // collision with bonuses
        for (Bonus *bonus in _bonuses) {
            if (CGRectIntersectsRect(projectile.boundingBox, bonus.boundingBox)) {
                projectile.active = false;
                bonus.active = false;
                if (bonus.type == 0) {
                    if (_lifes < 3) {
                        _lifes++;
                        [self refreshLives];
                    }
                } else if (bonus.type == 1) {
                    NSLog(@"SHOTGUN");
                }
            }
        }
        
        if (!projectile.active) {
            [inactive addObject:projectile];
        }
    }
    
    // update ennemies
    for (Enemy *enemy in _monsters) {
        [enemy update:dt];
        
        if (!enemy.active) {
            [inactive addObject:enemy];
        }
    }
    
    // update bonuses
    for (GameObject *bonus in _bonuses) {
        [bonus update:dt];
        
        if (!bonus.active) {
            [inactive addObject:bonus];
        }
    }
    
    // remove inactive game objects
    for (GameObject *gameObject in inactive) {
        if ([gameObject isKindOfClass:[Projectile class]]) {
            [_projectiles removeObject:gameObject];
        } else if ([gameObject isKindOfClass:[Enemy class]]) {
            [_monsters removeObject:gameObject];
        } else if ([gameObject isKindOfClass:[Bonus class]]) {
            [_bonuses removeObject:gameObject];
        }
        [self removeChild:gameObject cleanup:YES];
    }
    
    // handle winning
    if (_monstersDestroyed >= _levelObjective) {
        [LevelManager sharedLevelManager].level++;
        CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
    }
    
    // handle loosing
    if (_lifes < 0) {
        CCScene *gameOverScene = [GameOverLayer sceneWithWon:NO];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
    }
}

- (void)refreshLives {
    for (int i=0; i<3; i++) {
        if (_lifes > i) {
            [_lifeSprites[i] setTexture:[[CCTextureCache sharedTextureCache] addImage:@"heart.png"]];
        } else {
            [_lifeSprites[i] setTexture:[[CCTextureCache sharedTextureCache] addImage:@"heartempty.png"]];
        }
    }
}

- (void)refreshCombo {
    if (_combo > 0) {
        [_comboLabel setString:[NSString stringWithFormat:@"Combo x%d", _combo]];
    } else {
        [_comboLabel setString:@""];
    }
}

@end
