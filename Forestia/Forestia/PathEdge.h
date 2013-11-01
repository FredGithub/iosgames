//
//  PathEdge.h
//  Forestia
//
//  Created by AdminMacLC04 on 10/31/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PathNode.h"

@interface PathEdge : NSObject

@property (nonatomic, weak) PathNode *to;
@property (nonatomic) float cost;

@end
