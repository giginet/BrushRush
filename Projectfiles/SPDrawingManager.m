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

@end
