//
//  PathGraph.m
//  Forestia
//
//  Created by AdminMacLC04 on 10/31/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "PathGraph.h"
#import "PathNode.h"
#import "CCTMXTiledMap.h"
#import "CCTMXLayer.h"

@implementation PathGraph

- (id)initWithMap:(CCTMXTiledMap *)map tileLayer:(CCTMXLayer *)layer {
    self = [super init];
    
    if (self != nil) {
        int width = layer.layerSize.width;
        int height = layer.layerSize.height;
        
        // init nodes
        _nodes = [NSMutableArray array];
        for (int col = 0; col < width; col++) {
            for (int row = 0; row < height; row++) {
                // get the tile
                uint32_t tileId = [layer tileGIDAt:CGPointMake(col, row)];
                NSDictionary* properties = [map propertiesForGID:tileId];
                NSString *walkable = [properties objectForKey:@"walkable"];
                
                if ([walkable isEqualToString:@"true"]) {
                    [_nodes addObject:[[PathNode alloc] initWithCol:col row:row]];
                } else {
                    [_nodes addObject:[NSNull null]];
                }
            }
        }
        
        // set the edges
        for (PathNode *node in _nodes) {
            int index = node.col * height + node.row;
            
            // for all the neighbours
            for (int x = -1; x < 2; x++) {
                for (int y = -1; y < 2; y++) {
                    int index = (node.col + x) * height + (node.row + y);
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
    
}

- (float)calcH:(PathNode *)node destination:(PathNode *)dest {
    return 0;
}

@end
