//
//  SPDrawing.m
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPDrawing.h"
#import "CCDrawingPrimitives.h"

@implementation SPDrawing
@synthesize color;
@synthesize type;
@synthesize points;
@synthesize player;

- (id)init {
  self = [super init];
  if (self) {
    type = SPDrawingTypeWriting;
    points = [NSMutableArray array];
    color = ccc3(1, 0, 0);
  }
  return self;
}

- (id)initWithPoints:(NSArray *)points {
  self = [self init];
  if (self) {
  }
  return self;
}

- (float)area {
  return 0;
}

- (void)draw {
  int count = [points count];
  if (count <= 1) return;
  for (int i = 1; i < count; ++i) {
    CGPoint prev = [[points objectAtIndex:i - 1] CGPointValue];
    CGPoint point = [[points objectAtIndex:i] CGPointValue];
    glColor4f(self.color.r, self.color.g, self.color.b, 1);
    ccDrawLine(prev, point);
  }
}

- (void)setPlayer:(SPPlayer *)p {
  player = p;
  [p.drawings addObject:self];
}

- (void)addPoint:(CGPoint)point {
  [self.points addObject:[NSValue valueWithCGPoint:point]];
}

@end
