//
//  LevelManager.h
//  Cocos2DSimpleGame
//
//  Created by AdminMacLC04 on 9/11/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LevelManager : NSObject

@property int level;
@property int score;

+ (LevelManager*) sharedLevelManager;

@end
