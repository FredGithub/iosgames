//
//  Projectile.m
//  Cocos2DSimpleGame
//
//  Created by AdminMacLC04 on 9/19/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Projectile.h"

@implementation Projectile

+ (id)createProjectileWithLayer:(GameLayer *)layer type:(int)type {
    Projectile *projectile = nil;
    if (type == 0) {
        projectile = [[Projectile alloc] initWithLayer:layer type:type file:@"projectile.png"];
    } else if (type == 1) {
        projectile = [[Projectile alloc] initWithLayer:layer type:type file:@"heart.png"];
    }
    return projectile;
}

- (id)initWithLayer:(GameLayer *)layer type:(int)type file:(NSString *)file {
    self = [super initWithFile:file];
    
    if (self != nil) {
        _layer = layer;
        _type = type;
    }
    
    return self;
}

- (void)update:(ccTime)delta {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    self.position = ccp(self.position.x + self.speed.x * delta, self.position.y + self.speed.y * delta);
    
    if (self.position.x > winSize.width + self.contentSize.width/2 || self.position.y < -self.contentSize.height/2
        || self.position.y > winSize.height + self.contentSize.height/2) {
        _layer.combo = 0;
        [_layer resetCombo];
        self.active = false;
    }
}

@end
