//
//  PathDebugRenderer.h
//  Forestia
//
//  Created by AdminMacLC04 on 11/6/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "cocos2d.h"

#import "PathGraph.h"

@interface PathDebugRenderer : CCNode

@property (nonatomic, weak) PathGraph *graph;
@property (nonatomic) CGSize tileSize;

- (id)initWithGraph:(PathGraph *)graph tileSize:(CGSize)tileSize;
- (void)draw;

@end
