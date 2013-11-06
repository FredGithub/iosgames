//
//  PathAStarNode.h
//  Forestia
//
//  Created by AdminMacLC04 on 10/31/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "cocos2d.h"

#import "PathNode.h"

@interface PathAStarNode : NSObject

@property (nonatomic, weak) PathNode *node;

- (id)initWithNode:(PathNode *)node;

@end
