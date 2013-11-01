//
//  PathNode.m
//  Forestia
//
//  Created by AdminMacLC04 on 10/31/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "PathNode.h"

@implementation PathNode

- (id)initWithCol:(int)col row:(int)row {
    self = [super init];
    
    if (self != nil) {
        _col = col;
        _row = row;
    }
    
    return self;
}

@end
