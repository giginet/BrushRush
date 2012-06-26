//
//  SPDrawingManager.m
//  Spring
//
//  Created by  on 2012/6/7.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPDrawingManager.h"
#import "KWDrawingPrimitives.h"
#import "define.h"

@implementation SPDrawingManager
@synthesize drawings = drawings_;
@synthesize items = items_;

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
    items_ = [NSMutableArray array];
    [[CCScheduler sharedScheduler] scheduleUpdateForTarget:self priority:0 paused:NO];
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

- (void)removeAllDrawings {
  for (SPDrawing* drawing in [NSArray arrayWithArray:self.drawings]) {
    [self removeDrawing:drawing];
  }
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

- (CCRenderTexture*)renderTextureWithDrawings {
  CCRenderTexture* texture = [[CCRenderTexture alloc] initWithWidth:PLAYER_WIDTH 
                                                             height:PLAYER_HEIGHT 
                                                        pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
  [texture begin];
  for (SPDrawing* drawing in self.drawings) {
    if (drawing.type != SPDrawingTypeArea) continue;
    int count = [drawing.points count];
    CGPoint vertices[count];
    for (int i = 0; i < count; ++i) {
      vertices[i] = [[drawing.points objectAtIndex:i] CGPointValue];
    }
    glColor4f(drawing.color.r, drawing.color.g, drawing.color.b, 1);
    ccFillPoly(vertices, count, YES);
  }
  [texture end];
  return texture;
}

- (void)update:(ccTime)dt {
  for (SPItem* item in self.items) {
    [item update:dt];
  }
}

- (void)addItem:(SPItem *)item {
  [items_ addObject:item];
}

- (void)removeItem:(SPItem *)item {
  [items_ removeObject:item];
}

- (void)removeAllItems {
  [items_ removeAllObjects];
}

- (void)paintAt:(CGPoint)point player:(SPPlayer *)player {
  KWRandom* rnd = [KWRandom random];
  SPDrawing* drawing = [[SPDrawing alloc] init];
  for (int i = 0; i < 30; ++i) {
    int deg = i * 12;
    float radius = [rnd nextIntFrom:50 to:150];
    KWVector* v = [KWVector vectorWithPoint:CGPointMake(1, 0)];
    CGPoint p = ccpAdd(point, [[[v resize:radius] rotate:deg] point]);
    [drawing addPoint:p];
  }
  drawing.player = player;
  drawing.type = SPDrawingTypeArea;
  [self addDrawing:drawing];
}

@end
