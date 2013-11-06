//
//  PathGraph.h
//  Forestia
//
//  Created by AdminMacLC04 on 10/31/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "cocos2d.h"

#import "PathNode.h"

@interface PathGraph : NSObject

@property (nonatomic, strong) NSMutableArray *nodes;

- (id)initWithMap:(CCTMXTiledMap *)map tileLayer:(CCTMXLayer *)layer;
- (PathNode *)nodeForIndex:(int)index;
- (NSArray *)calcPathFrom:(PathNode *)nodeA to:(PathNode *)nodeB;

@end
