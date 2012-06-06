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

- (id)init {
  self.backgroundColor = ccc4(255, 255, 255, 255);
  self = [super init];
  if (self) {
    drawings_ = [NSMutableArray array];
    self.isTouchEnabled = YES;
  }
  return self;
}

- (void)onEnter {
  [super onEnter];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  SPDrawing* drawing = [[SPDrawing alloc] init];
  [drawings_ addObject:drawing];
  CGPoint point = [self convertTouchToNodeSpace:touch];
  drawing.position = point;
  [self addChild:drawing];
  return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
  SPDrawing* drawing = [drawings_ lastObject];
  CGPoint point = [self convertTouchToNodeSpace:touch];
  [drawing.points addObject:[NSValue valueWithCGPoint:[drawing convertToNodeSpace:point]]];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
}

- (void)draw {
  [super draw];
}

@end
