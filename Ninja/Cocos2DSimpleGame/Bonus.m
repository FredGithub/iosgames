//
//  Bonus.m
//  Cocos2DSimpleGame
//
//  Created by AdminMacLC04 on 9/19/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Bonus.h"

@implementation Bonus

+ (id)createBonusWithLayer:(GameLayer *)layer type:(int)type {
    Bonus *bonus = nil;
    if (type == 0) {
        bonus = [[Bonus alloc] initWithLayer:layer type:type file:@"bonus_heart.png"];
    } else if (type == 1) {
        bonus = [[Bonus alloc] initWithLayer:layer type:type file:@"bonus_bullet.png"];
    }
    return bonus;
}

- (id)initWithLayer:(GameLayer *)layer type:(int)type file:(NSString *)file {
    self = [super initWithFile:file];
    
    if (self != nil) {
        _type = type;
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    if (self.position.x < -self.contentSize.width/2) {
        self.active = false;
    }
}

@end
