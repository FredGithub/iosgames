//
//  DrawUtils.m
//  Forestia
//
//  Created by AdminMacLC04 on 11/6/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "Utils.h"

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

void drawArrowShrinked(CGPoint start, CGPoint end, float size, float shrink) {
    CGPoint mid = ccpMult(ccpAdd(start, end), 0.5f);
    start = ccpAdd(mid, ccpMult(ccpSub(start, mid), shrink));
    end = ccpAdd(mid, ccpMult(ccpSub(end, mid), shrink));
    drawArrow(start, end, size);
}

float angleMove(float rotation, float targetRotation) {
    float angleMove = fmodf(targetRotation - rotation, 2 * M_PI);
    if (angleMove > M_PI) {
        angleMove -= 2 * M_PI;
    } else if (angleMove < -M_PI) {
        angleMove += 2 * M_PI;
    }
    return angleMove;
}

float angleMoveDeg(float rotation, float targetRotation) {
    float angleMove = fmodf(targetRotation - rotation, 360);
    if (angleMove > 180) {
        angleMove -= 360;
    } else if (angleMove < -180) {
        angleMove += 360;
    }
    return angleMove;
}
