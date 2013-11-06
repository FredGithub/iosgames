//
//  PathAStarNode.m
//  Forestia
//
//  Created by AdminMacLC04 on 10/31/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "PathAStarNode.h"

@implementation PathAStarNode

- (id)initWithNode:(PathNode *)node {
    self = [super init];
    
    if (self != nil) {
        _node = node;
    }
    
    return self;
}

@end
