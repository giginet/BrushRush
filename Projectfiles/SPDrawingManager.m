//
//  SPDrawingManager.m
//  Spring
//
//  Created by  on 2012/6/7.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPDrawingManager.h"

@implementation SPDrawingManager
@synthesize drawings = drawings_;

+ (id)sharedManager {
  static id sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[[self class] alloc] init];
  });
  return sharedInstance;
}

- (id)init {
  self = [super init];
  if (self) {
    drawings_ = [NSMutableArray array];
  }
  return self;
}

- (void)addDrawing:(SPDrawing *)drawing {
  [drawings_ addObject:drawing];
}

- (void)removeDrawing:(SPDrawing *)drawing {
  [drawings_ removeObject:drawing];
  [drawing.player.drawings removeObject:self];
}

- (float)areaWithPlayer:(SPPlayer *)player {
  float area = 0;
  for (SPDrawing* drawing in player.drawings) {
    area += drawing.area;
  }
  return area;
}

- (void)mergeWithIntersectsDrawing:(SPDrawing *)drawing {
  BOOL intersected = NO;
  do {
    intersected = NO;
    for (SPDrawing* other in [NSArray arrayWithArray:self.drawings]) {
      if (![drawing isEqual:other] && [drawing.player isEqual:other.player] && CGRectIntersectsRect(drawing.boundingBox, other.boundingBox)) {
        for (NSValue* value in other.points) {
          [drawing addPoint:[value CGPointValue]];
        }
        [self removeDrawing:other];
        intersected = YES;
      }
      return;
    }
  } while (intersected);
}

@end
