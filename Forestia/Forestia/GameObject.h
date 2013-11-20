//
//  GameObject.h
//  Cocos2DSimpleGame
//
//  Created by AdminMacLC04 on 9/19/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "cocos2d.h"

@interface GameObject : CCSprite

@property bool active;

- (id)init;
- (id)initWithFile:(NSString *)filename;
- (id)initWithSpriteFrameName:(NSString *)spriteFrameName;
- (void)update:(ccTime)delta;
- (void)updateAfterPhysics:(ccTime)delta;

@end
