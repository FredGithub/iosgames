//
//  PathGraph.m
//  Forestia
//
//  Created by AdminMacLC04 on 10/31/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "PathGraph.h"
#import "PathNode.h"
#import "PathEdge.h"
#import "CCTMXTiledMap.h"
#import "CCTMXLayer.h"

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

- (NSMutableArray *)calcPathFrom:(PathNode *)nodeA to:(PathNode *)nodeB {
    NSMutableArray *path = [NSMutableArray array];
    NSMutableArray *openList = [NSMutableArray array];
    PathNode *lowestNode = nil;
    
    [openList addObject:nodeA];
    
    while (lowestNode != nodeB || [openList count] > 0) {
        lowestNode = [self nodeWithLowestF];
    }
    
    return path;
}

- (PathNode *)nodeWithLowestF {
    return nil;
}

- (float)calcH:(PathNode *)node destination:(PathNode *)dest {
    return 0;
}

@end
