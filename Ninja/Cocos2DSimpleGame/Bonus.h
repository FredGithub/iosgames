//
//  Bonus.h
//  Cocos2DSimpleGame
//
//  Created by AdminMacLC04 on 9/19/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "cocos2d.h"

#import "GameObject.h"
#import "GameLayer.h"

@interface Bonus : GameObject

@property int type;

+ (id)createBonusWithLayer:(GameLayer *)layer type:(int)type;

- (id)initWithLayer:(GameLayer *)layer type:(int)type file:(NSString *)file;

@end
