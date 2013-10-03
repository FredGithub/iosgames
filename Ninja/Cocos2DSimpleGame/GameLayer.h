//
//  HelloWorldLayer.h
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 11/13/12.
//  Copyright Razeware LLC 2012. All rights reserved.
//

#import "cocos2d.h"

@interface GameLayer : CCLayerColor {
    NSMutableArray *_monsters;
    NSMutableArray *_projectiles;
    NSMutableArray *_bonuses;
    int _monstersDestroyed;
    int _levelObjective;
    int _currentWeapon;
    NSMutableArray *_lifeSprites;
    NSArray *_monstersGoals;
    NSArray *_weaponReloadTimes;
    CCLabelTTF *_monstersLabel;
    CCLabelTTF *_levelLabel;
    CCLabelTTF *_comboLabel;
}

@property int lifes;
@property int combo;

+ (CCScene *)scene;

- (void) refreshLives;
- (void) refreshCombo;

@end
