//
//  PathGraph.m
//  Forestia
//
//  Created by AdminMacLC04 on 10/31/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "PathGraph.h"
#import "CCTMXTiledMap.h"
#import "CCTMXLayer.h"
#import "PathNode.h"
#import "PathEdge.h"
#import "PathAStarNode.h"

@implementation PathGraph

- (id)initWithMap:(CCTMXTiledMap *)map tileLayer:(CCTMXLayer *)layer {
    self = [super init];
    
    if (self != nil) {
        CGSize s = layer.layerSize;
        
        // create the nodes
        _nodes = [NSMutableArray array];
        for (int col = 0; col < s.width; col++) {
            for (int row = 0; row < s.height; row++) {
                // get the tile
                uint32_t tileId = [layer tileGIDAt:ccp(col, s.height - row - 1)];
                NSDictionary* properties = [map propertiesForGID:tileId];
                NSString *walkable = [properties objectForKey:@"walkable"];
                
                // create a new node if the tile is walkable
                if ([walkable isEqualToString:@"true"]) {
                    [_nodes addObject:[[PathNode alloc] initWithCol:col row:row]];
                } else {
                    [_nodes addObject:[NSNull null]];
                }
            }
        }
        
        // create the edges
        for (PathNode *node in _nodes) {
            if (node != (id)[NSNull null]) {
                // for all the neighbors
                for (int x = -1; x < 2; x++) {
                    for (int y = -1; y < 2; y++) {
                        // skip if it's not an N4 neighbor
                        if (x * x + y * y != 1) {
                            continue;
                        }
                        // skip if we are out of the map
                        if (node.col + x < 0 || node.col + x >= s.width || node.row + y < 0 || node.row + y >= s.height) {
                            continue;
                        }
                        int index = (node.col + x) * s.height + (node.row + y);
                        if (_nodes[index] != [NSNull null]) {
                            PathEdge *edge = [[PathEdge alloc] initWithNode:_nodes[index] cost:1];
                            [node addEdge:edge];
                        }
                    }
                }
            }
        }
    }
    
    return self;
}

- (NSArray *)calcPathFrom:(PathNode *)nodeA to:(PathNode *)nodeB {
    NSMutableArray *openedList = [NSMutableArray array];
    NSMutableArray *closedList = [NSMutableArray array];
    PathAStarNode *lowestNode = nil;
    
    // add initial node to opened list
    [openedList addObject:[[PathAStarNode alloc] initWithNode:nodeA g:0 h:[self calcH:nodeA dest:nodeB] parent:nil]];
    
    while (lowestNode.node != nodeB || [openedList count] > 0) {
        // get node with lowest f
        lowestNode = [self nodeWithLowestF:openedList];
        
        // pass it from opened list to closed list
        [openedList removeObject:lowestNode];
        [closedList addObject:lowestNode];
        
        // process all neighbors
        for (PathEdge *edge in lowestNode.node.edges) {
            if ([self findAStarNodeForNode:edge.node inList:closedList] == nil) {
                PathAStarNode *neighborNode = [self findAStarNodeForNode:edge.node inList:openedList];
                if (neighborNode == nil) {
                    float estimated = [self calcH:edge.node dest:nodeB];
                    neighborNode = [[PathAStarNode alloc] initWithNode:edge.node g:lowestNode.g + edge.cost h:estimated parent:lowestNode];
                    [openedList addObject:neighborNode];
                } else {
                    if (lowestNode.g + edge.cost < neighborNode.g) {
                        neighborNode.g = lowestNode.g + edge.cost;
                        neighborNode.parent = lowestNode;
                    }
                }
            }
        }
    }
    
    // get the node path if we reached destination
    if (lowestNode.node == nodeB) {
        NSMutableArray *path = [NSMutableArray array];
        while (lowestNode.parent != nil) {
            [path addObject:lowestNode.node];
            lowestNode = lowestNode.parent;
        }
        NSArray *orderedPath = [[path reverseObjectEnumerator] allObjects];
        [self printPath:orderedPath];
        return orderedPath;
    } else {
        return nil;
    }
}

- (PathAStarNode *)nodeWithLowestF:(NSMutableArray *)list {
    PathAStarNode *foundNode = nil;
    float min = INFINITY;
    
    for (PathAStarNode *node in list) {
        if (node.g + node.h < min ) {
            foundNode = node;
            min = node.g + node.h;
        }
    }
    
    return foundNode;
}

- (float)calcH:(PathNode *)node dest:(PathNode *)dest {
    return abs(dest.col - node.col) + abs(dest.row - node.row);
}

- (PathAStarNode *)findAStarNodeForNode:(PathNode *)node inList:(NSMutableArray *)list {
    for (PathAStarNode *aStarNode in list) {
        if (aStarNode.node == node) {
            return aStarNode;
        }
    }
    return nil;
}

- (void)printPath:(NSArray *)path {
    NSLog(@"%@", path);
    for (PathNode *node in path) {
        
    }
}

@end
