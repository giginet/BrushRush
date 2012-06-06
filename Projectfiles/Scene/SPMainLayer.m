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
        [player addChild:drawing];
        [player.drawings addObject:drawing];
        drawing.position = [player convertToNodeSpace:point];
        [drawing addPoint:[drawing convertToNodeSpace:point]];
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
        [drawing addPoint:[drawing convertToNodeSpace:point]];
      }
    }
  }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch* touch in touches) {
    for (SPPlayer* player in self.players) {
      if ([player.lastTouch isEqual:touch]) {
        player.lastTouch = nil;
      }
    }
  }
}

- (NSArray*)drawings {
  NSMutableArray* array = [NSMutableArray array];
  for (SPPlayer* player in self.players) {
    [array addObjectsFromArray:player.drawings];
  }
  return array;
}

@end
