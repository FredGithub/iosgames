//
//  DebugPoint.m
//  Forestia
//
//  Created by AdminMacLC04 on 11/14/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "Vector.h"

@implementation Vector

- (id)initWithX:(float)x y:(float)y {
    self = [super init];
    
    if (self != nil) {
        _x = x;
        _y = y;
    }
    
    return self;
}
@end
