//
//  PathEdge.h
//  Forestia
//
//  Created by AdminMacLC04 on 10/31/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "cocos2d.h"

#import "PathNode.h"

@interface PathEdge : NSObject

@property (nonatomic, weak) PathNode *node;
@property (nonatomic) float cost;

- (id)initWithNode:(PathNode *)node cost:(float)cost;

@end
