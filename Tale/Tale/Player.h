//
//  Player.h
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "cocos2d.h"

#import "GameObject.h"
#import "GameLayer.h"

@interface Player : GameObject

- (id)initWithLayer:(GameLayer *)layer;
- (void)update:(ccTime)delta;

@end