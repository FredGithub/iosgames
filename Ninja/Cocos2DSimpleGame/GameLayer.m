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
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        // init game constants
        _monstersGoals = [NSArray arrayWithObjects:@(500), @(10), @(15), @(20), @(30), nil];
        _weaponReloadTimes = [NSArray arrayWithObjects:@(350), @(500), nil];
        
        // setup the background
        CCSprite *background = [[CCSprite alloc] initWithFile:@"background.png"];
        background.position = ccp(winSize.width / 2, winSize.height / 2);
        [self addChild:background];
        
        // create the player
        _player = [CCSprite spriteWithFile:@"tower_body.png"];
        _player.position = ccp(_player.contentSize.width / 2, winSize.height / 2);
        _playerCannon = [CCSprite spriteWithFile:@"tower_cannon.png"];
        _playerCannon.anchorPoint = ccp(-0.5f, 0.5f);
        _playerCannon.position = ccp(_player.contentSize.width / 2, _player.contentSize.height / 2);
        [_player addChild:_playerCannon];
        [self addChild:_player];
        
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
        _combo = 1;
        
        // setup the sprite sheets
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"enemies.plist"];
        _enemyBatch = [CCSpriteBatchNode batchNodeWithFile:@"enemies.png"];
        [self addChild:_enemyBatch];
        
        // create the UI
        CCMenuItem *nextLevelItem = [CCMenuItemImage itemWithNormalImage:@"heart.png" selectedImage:@"heart.png" target:self selector:@selector(clickNextLevel:)];
        nextLevelItem.position = ccp(winSize.width - nextLevelItem.contentSize.width / 2, nextLevelItem.contentSize.height / 2);
        
        CCMenu *menu = [CCMenu menuWithItems:nextLevelItem, nil];
        menu.position = ccp(0, 0);
        [self addChild:menu];
        
        _monstersLabel = [CCLabelTTF labelWithString:@"" fontName:@"Helvetica" fontSize:15 dimensions:CGSizeMake(150, 20) hAlignment:kCCTextAlignmentLeft];
        _monstersLabel.color = ccc3(0, 0, 0);
        _monstersLabel.position = ccp(_monstersLabel.dimensions.width / 2 + 10, winSize.height - _monstersLabel.dimensions.height / 2 - 10);
        [self addChild:_monstersLabel];
        [self refreshMonstersUI];
        
        _levelLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Level %d", [LevelManager sharedLevelManager].level + 1] fontName:@"Helvetica" fontSize:15 dimensions:CGSizeMake(150, 20) hAlignment:kCCTextAlignmentRight];
        _levelLabel.color = ccc3(0, 0, 0);
        _levelLabel.position = ccp(winSize.width - _levelLabel.dimensions.width / 2 - 10, winSize.height - _levelLabel.dimensions.height / 2 - 10);
        [self addChild:_levelLabel];
        
        _scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Helvetica" fontSize:15 dimensions:CGSizeMake(150, 20) hAlignment:kCCTextAlignmentRight];
        _scoreLabel.color = ccc3(0, 0, 0);
        _scoreLabel.position = ccp(winSize.width - _scoreLabel.dimensions.width / 2 - 10, winSize.height - _scoreLabel.dimensions.height / 2 - 30);
        [self addChild:_scoreLabel];
        [self refreshScoreUI];
        
        _comboLabel = [CCLabelTTF labelWithString:@"" fontName:@"Helvetica" fontSize:12 dimensions:CGSizeMake(150, 20) hAlignment:kCCTextAlignmentCenter];
        _comboLabel.color = ccc3(0, 0, 0);
        _comboLabel.position = ccp(winSize.width / 2, winSize.height - _monstersLabel.contentSize.height / 2 - 40);
        [self addChild:_comboLabel];
        
        _lifeSprites = [[NSMutableArray alloc] init];
        for(int i=0; i<3; i++){
            CCSprite *life = [CCSprite spriteWithFile:@"heart.png"];
            life.position = ccp(winSize.width / 2 + (i - 1)*(life.contentSize.width + 5), winSize.height - life.contentSize.height / 2 - 10);
            [self addChild:life];
            [_lifeSprites addObject:life];
        }
        [self refreshLifesUI];
        
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
    // get the monster type
    int ran = arc4random()%7;
    int type;
    if (ran < 3) {
        type = 0;
    } else if (ran < 6) {
        type = 2;
    } else {
        type = 1;
    }
    type = 2;
    
    Enemy *enemy = [Enemy createEnemyWithLayer:self type:type];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int minY = enemy.contentSize.height / 2;
    int maxY = winSize.height - enemy.contentSize.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    enemy.position = ccp(winSize.width + enemy.contentSize.width / 2, actualY);
    enemy.tag = 1;
    [_monsters addObject:enemy];
    [_enemyBatch addChild:enemy];
}

- (void)addBonusWithPosition:(CGPoint)pos {
    int type = arc4random()%2;
    Bonus *bonus = [Bonus createBonusWithLayer:self type:type];
    bonus.position = pos;
    bonus.tag = 3;
    [_bonuses addObject:bonus];
    [self addChild:bonus];
}

- (void)gameLogic:(ccTime)dt {
    [self addMonster];
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _mousePos = [self convertTouchToNodeSpace:touch];
    float angle = ccpAngleSigned(ccp(1, 0), ccpSub(_mousePos, _player.position));
    _playerCannon.rotation = -angle * 180 / M_PI;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _mousePos = [self convertTouchToNodeSpace:touch];
    _mouseDown = YES;
    float angle = ccpAngleSigned(ccp(1, 0), ccpSub(_mousePos, _player.position));
    _playerCannon.rotation = -angle * 180 / M_PI;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _mousePos = [self convertTouchToNodeSpace:touch];
    _mouseDown = NO;
}

- (void)update:(ccTime)dt {
    _time += dt;
    
    // handle shoot
    if (_mouseDown) {
        
        // if the weapon is reloaded
        if ((_time - _lastShootTime) * 1000 >= [_weaponReloadTimes[_currentWeapon] intValue]) {
            _lastShootTime = _time;
            CGPoint cannonPos = [_playerCannon convertToWorldSpace:ccp(_playerCannon.contentSize.width, _playerCannon.contentSize.height / 2)];
            float shootAngle = ccpAngleSigned(ccp(1, 0), ccpSub(_mousePos, _player.position));
            
            // spawn the bullets
            if (_currentWeapon == 0) {
                CGPoint dir = ccpNormalize(ccpSub(_mousePos, _player.position));
                Projectile *projectile = [Projectile createProjectileWithLayer:self type:_currentWeapon];
                projectile.position = cannonPos;
                projectile.speed = ccpMult(dir, 500);
                projectile.tag = 2;
                [_projectiles addObject:projectile];
                [self addChild:projectile];
            } else if (_currentWeapon == 1) {
                for(int i = -1; i < 2; i++) {
                    float angle = shootAngle + i * 0.2f;
                    Projectile *projectile = [Projectile createProjectileWithLayer:self type:_currentWeapon];
                    projectile.position = cannonPos;
                    projectile.speed = ccp(cosf(angle) * 500, sinf(angle) * 500);
                    projectile.tag = 2;
                    [_projectiles addObject:projectile];
                    [self addChild:projectile];
                }
            }
            
            // explosion particles
            CCParticleSystem *explosion = [[CCParticleExplosion alloc] initWithTotalParticles:10];
            explosion.position = cannonPos;
            explosion.texture = [[CCTextureCache sharedTextureCache] addImage: @"particle2.png"];
            explosion.startSize = 4;
            explosion.endSize = 3;
            explosion.posVar = ccp(0, 0);
            explosion.gravity = ccp(0, 0);
            explosion.startColor = ccc4f(0.5f, 0.5f, 0.5f, 0.8f);
            explosion.startColorVar = ccc4f(0, 0, 0, 0);
            explosion.endColor = ccc4f(0.5f, 0.5f, 0.5f, 0);
            explosion.endColorVar = ccc4f(0, 0, 0, 0);
            explosion.life = 0.3f;
            explosion.lifeVar = 0;
            explosion.angle = shootAngle * 180 / M_PI;
            explosion.angleVar = 50;
            explosion.autoRemoveOnFinish = YES;
            [self addChild:explosion];
            
            // play weapon sound
            [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
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
                [enemy damage:100];
                _combo++;
                [self refreshComboUI];
            }
        }
        
        // collision with bonuses
        for (Bonus *bonus in _bonuses) {
            if (CGRectIntersectsRect(projectile.boundingBox, bonus.boundingBox)) {
                projectile.active = false;
                bonus.active = false;
                [self addScore:200];
                if (bonus.type == 0) {
                    if (_lifes < 3) {
                        _lifes++;
                        [self refreshLifesUI];
                    }
                } else if (bonus.type == 1) {
                    _currentWeapon = 1;
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
            [self removeChild:gameObject cleanup:YES];
        } else if ([gameObject isKindOfClass:[Enemy class]]) {
            [_monsters removeObject:gameObject];
            [_enemyBatch removeChild:gameObject cleanup:YES];
        } else if ([gameObject isKindOfClass:[Bonus class]]) {
            [_bonuses removeObject:gameObject];
            [self removeChild:gameObject cleanup:YES];
        }
    }
}

- (void)looseLife {
    _lifes--;
    [self refreshLifesUI];
    
    // handle loosing
    if (_lifes < 0) {
        CCScene *gameOverScene = [GameOverLayer sceneWithWon:NO];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
    }
}

- (void)monsterKilled:(Enemy *)enemy {
    // add bonus if necessary
    if (enemy.type == 1) {
        [self addBonusWithPosition:enemy.position];
    }
    
    _monstersDestroyed++;
    [self refreshMonstersUI];
    [self addScore:500 * (enemy.type + 1) * _combo];
    
    // handle winning
    if (_monstersDestroyed >= _levelObjective) {
        [self win];
    }
}

- (void)resetCombo {
    _combo = 1;
    [self refreshComboUI];
}

/* Private methods */

- (void)refreshLifesUI {
    for (int i=0; i<3; i++) {
        if (_lifes > i) {
            [_lifeSprites[i] setTexture:[[CCTextureCache sharedTextureCache] addImage:@"heart.png"]];
        } else {
            [_lifeSprites[i] setTexture:[[CCTextureCache sharedTextureCache] addImage:@"heart_empty.png"]];
        }
    }
}

- (void)refreshComboUI {
    if (_combo > 1) {
        [_comboLabel setString:[NSString stringWithFormat:@"Combo x%d", _combo]];
    } else {
        [_comboLabel setString:@""];
    }
}

- (void)refreshMonstersUI {
    [_monstersLabel setString:[NSString stringWithFormat:@"Monsters %d/%d", _monstersDestroyed, _levelObjective]];
}

- (void)addScore:(int)value {
    [LevelManager sharedLevelManager].score += value;
    [self refreshScoreUI];
}

- (void)refreshScoreUI {
    [_scoreLabel setString:[NSString stringWithFormat:@"%d", [LevelManager sharedLevelManager].score]];
}

- (void)clickNextLevel:(id)sender {
    [self win];
}

- (void)win {
    [LevelManager sharedLevelManager].level++;
    CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
    [[CCDirector sharedDirector] replaceScene:gameOverScene];
}

@end
