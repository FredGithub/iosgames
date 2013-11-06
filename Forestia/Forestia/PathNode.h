//
//  PathNode.h
//  Forestia
//
//  Created by AdminMacLC04 on 10/31/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "cocos2d.h"

@class PathEdge;

@interface PathNode : NSObject

@property (nonatomic) int col;
@property (nonatomic) int row;
@property (nonatomic, strong) NSMutableArray *edges;

- (id)initWithCol:(int)col row:(int)row;
- (void)addEdge:(PathEdge *)edge;

@end
