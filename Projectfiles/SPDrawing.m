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

typedef enum {
  SPRotationStraight,
  SPRotationClockwise,
  SPRotationAntiClockwise
} SPRotation;

@interface SPDrawing()
- (void)onEndCharge;
- (SPRotation)rotationDirectionByPoint:(CGPoint)p0 point1:(CGPoint)p1 point2:(CGPoint)p2;
- (BOOL)intersectsLines:(CGPoint)p0b endPoint:(CGPoint)p0e beginPoint:(CGPoint)p1b endPoint:(CGPoint)p1e;
@end

@implementation SPDrawing
@synthesize boundingBox;
@synthesize color;
@synthesize type;
@synthesize points = points_;
@synthesize player;
@dynamic gravityPoint;

- (id)init {
  self = [super init];
  if (self) {
    type = SPDrawingTypeWriting;
    points_ = [NSMutableArray array];
    color = ccc3(1, 0, 0);
    boundingBox = CGRectMake(0, 0, 0, 0);
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
  int count = [self.points count];
  if (count <= 1) return 0;
  for (int i = 1; i < count; ++i) {
    CGPoint prev = [[self.points objectAtIndex:i - 1] CGPointValue];
    CGPoint point = [[self.points objectAtIndex:i] CGPointValue];
    length += hypotf(point.x - prev.x, point.y - prev.y);
  }
  return length;
}

- (void)draw {
  int count = [self.points count];
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
      CGPoint prev = [[self.points objectAtIndex:i - 1] CGPointValue];
      CGPoint point = [[self.points objectAtIndex:i] CGPointValue];
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
  [points_ addObject:[NSValue valueWithCGPoint:point]];
  if ([points_ count] == 0) {
    boundingBox.origin = point;
  } else {
    if (point.x < self.boundingBox.origin.x) {
      boundingBox.origin.x = point.x; 
    } else if(point.x > self.boundingBox.origin.x + self.boundingBox.size.width) {
      boundingBox.size.width = point.x - self.boundingBox.origin.x;
    }
    if (point.y < self.boundingBox.origin.y) {
      boundingBox.origin.y = point.y;
    } else if(point.y > self.boundingBox.origin.y + self.boundingBox.size.height) {
      boundingBox.size.height = point.y - self.boundingBox.origin.y;
    }
  }
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

- (CGPoint)gravityPoint {
  __block float sumx = 0;
  __block float sumy = 0;
  [self.points mapUsingBlock:^(id value, NSUInteger idx){
    CGPoint p = [value CGPointValue];
    sumx += p.x;
    sumy += p.y;
    return value;
  }];
  int count = [self.points count];
  return ccp(sumx / count, sumy / count);
}

- (BOOL)containsPoint:(CGPoint)point {
  int count = [self.points count];
  int intersects = 0;
  const CGPoint pe = CGPointMake(-1000, -1000);
  for (int i = 0; i < count; ++i) {
    CGPoint p = [[self.points objectAtIndex:i] CGPointValue];
    CGPoint n = [[self.points objectAtIndex:(i + 1) % count] CGPointValue];
    if ([self intersectsLines:p endPoint:n beginPoint:point endPoint:pe]) {
      intersects += 1;
    }
  }
  return intersects % 2 == 1;
}

- (SPRotation)rotationDirectionByPoint:(CGPoint)p0 point1:(CGPoint)p1 point2:(CGPoint)p2 {
  float a = (p1.x - p0.x) * (p2.y - p0.y);
  float b = (p2.x - p0.x) * (p1.y - p0.y);
  if(a < b) {
    return SPRotationClockwise;
  } else if(a > b) {
    return SPRotationAntiClockwise;
  }
  return SPRotationStraight;
}

- (BOOL)intersectsLines:(CGPoint)p0b endPoint:(CGPoint)p0e beginPoint:(CGPoint)p1b endPoint:(CGPoint)p1e {
  return ([self rotationDirectionByPoint:p0b point1:p0e point2:p1b] != [self rotationDirectionByPoint:p0b point1:p0e point2:p1e]
          && [self rotationDirectionByPoint:p1b point1:p1e point2:p0b] != [self rotationDirectionByPoint:p1b point1:p1e point2:p0e]);
}

@end
