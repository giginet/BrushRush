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
@synthesize drawings;
@synthesize players;

- (id)init {
  self.backgroundColor = ccc4(255, 255, 255, 255);
  self = [super init];
  if (self) {
    drawings = [NSMutableArray array];
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

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  SPDrawing* drawing = [[SPDrawing alloc] init];
  [self.drawings addObject:drawing];
  CGPoint point = [self convertTouchToNodeSpace:touch];
  drawing.position = point;
  for (int i = 0; i < 2; ++i) {
    SPPlayer* player = [self.players objectAtIndex:i];
    if ([player containsPoint:point]) {
      [drawing setPlayer:player];
      [player addChild:drawing];
      break;
    }
  }
  return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
  SPDrawing* drawing = [self.drawings lastObject];
  CGPoint point = [self convertTouchToNodeSpace:touch];
  [drawing.points addObject:[NSValue valueWithCGPoint:[drawing convertToNodeSpace:point]]];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
}

- (void)draw {
  [super draw];
}

@end
