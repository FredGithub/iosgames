//
//  DrawUtils.m
//  Forestia
//
//  Created by AdminMacLC04 on 11/6/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "DrawUtils.h"

void drawArrow(CGPoint start, CGPoint end, float size) {
    // get the arrow dir and normal
    CGPoint dir = ccpMult(ccpNormalize(ccpSub(end, start)), size);
    CGPoint nor = ccpMult(ccp(dir.y, -dir.x), 0.6f);
    
    // render the arrow segment
    ccDrawLine(start, end);
    
    // render the first side of the arrow
    CGPoint arrow = ccpAdd(ccpSub(end, dir), nor);
    ccDrawLine(end, arrow);
    
    // render the second side of the arrow
    arrow = ccpSub(ccpSub(end, dir), nor);
    ccDrawLine(end, arrow);
}
