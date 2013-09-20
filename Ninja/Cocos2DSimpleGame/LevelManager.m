//
//  LevelManager.m
//  Cocos2DSimpleGame
//
//  Created by AdminMacLC04 on 9/11/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "LevelManager.h"

@implementation LevelManager

+ (LevelManager*)sharedLevelManager {
    static LevelManager* sharedLevelManager = nil;
    
    if (sharedLevelManager == nil) {
        sharedLevelManager = [[LevelManager alloc] init];
    }
    
    return sharedLevelManager;	
}

- (id)init {
    self = [super init];
    
    if(self != nil){
        _level = 0;
    }
    
    return self;
}

@end
