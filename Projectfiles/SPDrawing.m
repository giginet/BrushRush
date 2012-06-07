//
//  SPDrawing.m
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPDrawing.h"
#import "CCDrawingPrimitives.h"
#import "KWDrawingPrimitives.h"

@interface SPDrawing()
- (void)onEndCharge;
@end

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
  // http://advpro.co.jp/Devlop/?p=530
  int count = [self.points count];
  float area = 0;
  for (int i = 0; i < count; ++i) {
    CGPoint point = [[self.points objectAtIndex:i] CGPointValue];
    CGPoint next = [[self.points objectAtIndex:(i + 1) % count] CGPointValue];
    area += 1.0/2.0 * (point.x - next.x) * (point.y + next.y);
  }
  if (area < 0) area *= -1;
  return area;
}

- (float)length {
  float length = 0;
  int count = [points count];
  if (count <= 1) return 0;
  for (int i = 1; i < count; ++i) {
    CGPoint prev = [[points objectAtIndex:i - 1] CGPointValue];
    CGPoint point = [[points objectAtIndex:i] CGPointValue];
    length += hypotf(point.x - prev.x, point.y - prev.y);
  }
  return length;
}

- (void)draw {
  int count = [points count];
  if (count <= 1) return;
  glColor4f(self.color.r, self.color.g, self.color.b, 1);
  if (self.type == SPDrawingTypeArea) {
    CGPoint vertices[count];
    for (int i = 0; i < count; ++i) {
      vertices[i] = [[self.points objectAtIndex:i] CGPointValue];
    }
    ccFillPoly(vertices, count, YES);
  } else {
    for (int i = 1; i < count; ++i) {
      CGPoint prev = [[points objectAtIndex:i - 1] CGPointValue];
      CGPoint point = [[points objectAtIndex:i] CGPointValue];
      ccDrawLine(prev, point);
    }
  }
}

- (void)fire {
  [[CCScheduler sharedScheduler] scheduleSelector:@selector(onEndCharge) 
                                        forTarget:self 
                                         interval:self.length / 1000 * 2 
                                           paused:NO 
                                           repeat:0 
                                            delay:0];
}

- (SPPlayer*)player {
  return player;
}

- (void)setPlayer:(SPPlayer *)p {
  player = p;
  [p.drawings addObject:self];
}

- (void)addPoint:(CGPoint)point {
  [self.points addObject:[NSValue valueWithCGPoint:point]];
}

- (SPDrawingType)isClose {
  CGPoint begin = [[self.points objectAtIndex:0] CGPointValue];
  CGPoint end = [[self.points lastObject] CGPointValue];
  float distance = hypotf(begin.x - end.x, begin.y - end.y);
  float length = [self length];
  if (distance <= length * 0.15) {
    return YES;
  }
  return NO;
}

- (void)onEndCharge {
  self.type = SPDrawingTypeArea;
}

@end
