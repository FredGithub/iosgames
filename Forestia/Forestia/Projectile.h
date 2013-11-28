//
//  Projectile.h
//  Forestia
//
//  Created by AdminMacLC04 on 11/28/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "cocos2d.h"

#import "GameObject.h"
#import "GameLayer.h"
#import "Unit.h"

@interface Projectile : GameObject

@property (nonatomic, weak) Unit *target;
@property (nonatomic) float speed;
@property (nonatomic) float damage;

- (id)initWithLayer:(GameLayer *)layer target:(Unit *)target damage:(float)damage;

@end
