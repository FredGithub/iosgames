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
@property (nonatomic) float g;
@property (nonatomic) float h;
@property (nonatomic, weak) PathAStarNode *parent;

- (id)initWithNode:(PathNode *)node g:(float)g h:(float)h parent:(PathAStarNode *)parent;

@end
