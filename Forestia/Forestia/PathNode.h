//
//  PathNode.h
//  Forestia
//
//  Created by AdminMacLC04 on 10/31/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathNode : NSObject

@property int col;
@property int row;
@property (nonatomic, strong) NSMutableArray *edges;

- (id)initWithCol:(int)col row:(int)row;

@end
