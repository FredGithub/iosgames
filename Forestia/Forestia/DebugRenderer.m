//
//  PathDebugRenderer.m
//  Forestia
//
//  Created by AdminMacLC04 on 11/6/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "DebugRenderer.h"
#import "PathNode.h"
#import "PathEdge.h"
#import "DrawUtils.h"
#import "Vector.h"

@implementation DebugRenderer

- (id)initWithGraph:(PathGraph *)graph tileSize:(CGSize)tileSize {
    self = [super init];
    
    if (self != nil) {
        _graph = graph;
        _tileSize = tileSize;
        _points = [NSMutableArray array];
        _drawGraph = YES;
    }
    
    return self;
}

- (void)draw {
    [super draw];
    
    if (_drawGraph) {
        ccDrawColor4B(255, 255, 255, 255);
        glLineWidth(2);
        for (PathNode *node in _graph.nodes) {
            if (node != (id)[NSNull null]) {
                for (PathEdge *edge in node.edges) {
                    CGPoint p1 = ccp(node.col * _tileSize.width + _tileSize.width / 2, node.row * _tileSize.height + _tileSize.height / 2);
                    CGPoint p2 = ccp(edge.node.col * _tileSize.width + _tileSize.width / 2, edge.node.row * _tileSize.height + _tileSize.height / 2);
                    drawArrowShrinked(p1, p2, 6, 0.6f);
                }
            }
        }
    }
    
    ccDrawColor4B(255, 0, 0, 255);
    for (Vector *point in _points) {
        ccDrawPoint(ccp(point.x, point.y));
        ccDrawSolidCircle(ccp(point.x, point.y), 5, 10);
    }
    
    [_points removeAllObjects];
}

@end
