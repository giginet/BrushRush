//
//  SPDrawing.h
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "KWLayer.h"
#import "SPPlayer.h"

/**
 This is a class which manages drawn shape.
 It contains points of drawn polygons.
 */

typedef enum {
  SPDrawingTypeWriting,
  SPDrawingTypeSlash,
  SPDrawingTypeCount,
  SPDrawingTypeArea
} SPDrawingType;


@interface SPDrawing : CCNode {
  int size_;
  float area_;
  NSMutableArray* points_;
}

@property(readonly) CGRect boundingBox;
@property(readwrite) ccColor3B color;
@property(readwrite) SPDrawingType type;
@property(readonly, strong) NSArray* points;
@property(readwrite, weak) SPPlayer* player;

- (id)initWithPoints:(NSArray*)points;

/** calculate polyagon's area by containing points */
- (float)area;
- (float)length;

- (void)setPlayer:(SPPlayer *)player;
- (void)addPoint:(CGPoint)point;
- (void)fire;
- (SPDrawingType)isClose;

@end
