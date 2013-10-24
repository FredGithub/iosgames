//
//  HelloWorldLayer.m
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright AdminMacLC04 2013. All rights reserved.
//

#import "GameLayer.h"
#import "AppDelegate.h"
#import "GameObject.h"

@implementation GameLayer

+ (CCScene *)scene {
    CCScene *scene = [CCScene node];
    GameLayer *layer = [GameLayer node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

- (id)init {
    self = [super initWithColor:ccc4(255,255,255,255)];
    
    if (self != nil) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        // set the intervals
        [self schedule:@selector(update:)];
        
        // enable touch
        [self setTouchEnabled:YES];
    }
    
    return self;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _mousePos = [self convertTouchToNodeSpace:touch];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _mousePos = [self convertTouchToNodeSpace:touch];
    _mouseDown = YES;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _mousePos = [self convertTouchToNodeSpace:touch];
    _mouseDown = NO;
}

- (void)update:(ccTime)dt {
    _time += dt;
    
    NSMutableArray *inactive = [[NSMutableArray alloc] init];
    
    // update enemies
    for (GameObject *enemy in _enemies) {
        [enemy update:dt];
        
        if (!enemy.active) {
            [inactive addObject:enemy];
        }
    }
    
    // remove inactive game objects
    for (GameObject *gameObject in inactive) {
        if ([gameObject isKindOfClass:[GameObject class]]) {
            [_enemies removeObject:gameObject];
            [self removeChild:gameObject cleanup:YES];
        }
    }
}

/* Private methods */

- (void)win {
    //CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
    //[[CCDirector sharedDirector] replaceScene:gameOverScene];
}

@end
