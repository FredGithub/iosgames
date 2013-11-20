//
//  GameObject.m
//  Cocos2DSimpleGame
//
//  Created by AdminMacLC04 on 9/19/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "GameObject.h"

@implementation GameObject

- (id)init {
    self = [super init];
    
    if (self != nil) {
        _active = true;
    }
    
    return self;
}

- (id)initWithFile:(NSString *)filename {
    self = [super initWithFile:filename];
    
    if (self != nil) {
        _active = true;
    }
    
    return self;
}

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName {
    self = [super initWithSpriteFrameName:spriteFrameName];
    
    if (self != nil) {
        _active = true;
    }
    
    return self;
}

- (void)update:(ccTime)delta {
}

- (void)updateAfterPhysics:(ccTime)delta {
}

@end
