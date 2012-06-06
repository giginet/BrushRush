//
//  SPMainLayer.m
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPMainLayer.h"
#import "CCDrawingPrimitives.h"

@implementation SPMainLayer

- (id)init {
  self.backgroundColor = ccc4(255, 255, 255, 255);
  self = [super init];
  if (self) {
    self.isTouchEnabled = YES;
  }
  return self;
}

- (void)onEnter {
  [super onEnter];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint point = [self convertTouchToNodeSpace:touch];
  if ([points_ count] > 1) {
    CGPoint prev = [[points_ lastObject] CGPointValue];
    ccDrawLine(prev, point);
  }
  [points_ addObject:[NSValue valueWithCGPoint:point]];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  [points_ removeAllObjects];
}

- (void)draw {
  [super draw];
}

@end
