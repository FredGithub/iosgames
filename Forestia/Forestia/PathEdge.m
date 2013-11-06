//
//  PathEdge.m
//  Forestia
//
//  Created by AdminMacLC04 on 10/31/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "PathEdge.h"

@implementation PathEdge

- (id)initWithNode:(PathNode *)node cost:(float)cost{
    self = [super init];
    
    if (self != nil) {
        _node = node;
        _cost = cost;
    }
    
    return self;
}

@end
