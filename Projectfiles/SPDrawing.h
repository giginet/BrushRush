//
//  SPDrawing.h
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "KWLayer.h"

/**
 This is a class which manages drawn shape.
 It contains points of drawn polygons.
 */

typedef enum {
  SPDrawingTypeWriting,
  SPDrawingTypeSlash,
  SPDrawingTypeArea
} SPDrawingType;


@interface SPDrawing : CCNode {
  int size_;
  float area_;
}

@property(readwrite) ccColor3B color;
@property(readwrite) SPDrawingType type;
@property(readwrite, strong) NSMutableArray* points;

- (id)initWithPoints:(NSArray*)points;

/** calculate polyagon's area by containing points */
- (float)area;

@end
