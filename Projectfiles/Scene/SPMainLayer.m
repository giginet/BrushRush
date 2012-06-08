//
//  SPMainLayer.m
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPDrawing.h"
#import "SPMainLayer.h"
#import "CCDrawingPrimitives.h"
#import "SPDrawingManager.h"

@implementation SPMainLayer
@dynamic drawings;
@synthesize players;

- (id)init {
  self = [super init];
  if (self) {
    players = [NSMutableArray array];
    self.isTouchEnabled = YES;
    for (int i = 0; i < 2; ++i) {
      SPPlayer* player = [[SPPlayer alloc] initWithId:i];
      [self.players addObject:player];
      [self addChild:player];
    }
  }
  return self;
}

- (void)onEnter {
  [super onEnter];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch* touch in touches) {
    CGPoint point = [self convertTouchToNodeSpace:touch];
    for (SPPlayer* player in self.players) {
      if (!player.lastTouch && [player containsPoint:point]) {
        player.lastTouch = touch;
        SPDrawing* drawing = [[SPDrawing alloc] init];
        [[SPDrawingManager sharedManager] addDrawing:drawing];
        drawing.color = player.color;
        drawing.player = player;
        [drawing addPoint:[player convertToNodeSpace:point]];
      }
    }
  }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch* touch in touches) {
    CGPoint point = [self convertTouchToNodeSpace:touch];
    for (SPPlayer* player in self.players) {
      if ([player.lastTouch isEqual:touch]) {
        SPDrawing* drawing = [player.drawings lastObject];
        [drawing addPoint:[player convertToNodeSpace:point]];
      }
    }
  }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch* touch in touches) {
    for (SPPlayer* player in self.players) {
      if ([player.lastTouch isEqual:touch]) {
        SPDrawing* lastDrawing = player.lastDrawing;
        if([lastDrawing isClose]) {
          lastDrawing.type = SPDrawingTypeCount;
          [lastDrawing fire];
        } else {
          lastDrawing.type = SPDrawingTypeSlash;
          for (SPDrawing* other in [NSArray arrayWithArray:self.drawings]) {
            if ([other canCuttingBy:lastDrawing]) {
              NSLog(@"cut");
              [[SPDrawingManager sharedManager] removeDrawing:other];
            }
          }
          [[SPDrawingManager sharedManager] removeDrawing:lastDrawing];
        }
        player.lastTouch = nil;
      }
    }
  }
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch* touch in touches) {
    for (SPPlayer* player in self.players) {
      if ([player.lastTouch isEqual:touch]) {
        player.lastTouch = nil;
        [[SPDrawingManager sharedManager] removeDrawing:player.lastDrawing];
      }
    }
  }
}

- (NSArray*)drawings {
  SPDrawingManager* manager = [SPDrawingManager sharedManager];
  return manager.drawings;
}

- (void)draw {
  [super draw];
}

@end
