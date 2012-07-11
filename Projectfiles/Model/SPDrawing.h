//
//  SPDrawing.h
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "heqet.h"
#import "KWLayer.h"
#import "SPPlayer.h"
#import "ObjectAL.h"

/**
 This is a class which manages drawn shape.
 It contains points of drawn polygons.
 */

typedef enum {
  SPDrawingTypeWriting,
  SPDrawingTypeSlash,
  SPDrawingTypeCharge,
  SPDrawingTypeArea,
  SPDrawingTypeNone
} SPDrawingType;

typedef struct {
  int chargedEdgeIndex;
  float distanceFromEdge;
  CGPoint chargedPoint; 
} ChargeStatus;

@interface SPDrawing : CCNode {
  int size_;
  float area_;
  float lengthCache_;
  BOOL dirty_;
  ChargeStatus chargeStatus_;
  NSMutableArray* points_;
  NSMutableArray* chargeEffects_;
  OALAudioTrack* chargeSound_;
  CCTexture2D* brushTexture_;
}

@property(readonly) BOOL isCharging;
@property(readwrite) int chain;
@property(readonly) float angle;
@property(readonly) CGRect boundingBox;
@property(readonly) CGPoint gravityPoint;
@property(readwrite) ccColor3B color;
@property(readwrite) SPDrawingType type;
@property(readonly, strong) NSArray* points;
@property(readonly) KWTimer* chargeTimer;
@property(readwrite, weak) SPPlayer* player;
@property(readonly) OALAudioTrack* writingSound;

- (id)initWithPoints:(NSArray*)points;

/** calculate polyagon's area by containing points */
- (float)area;
- (float)length;

- (void)setPlayer:(SPPlayer *)player;
- (void)addPoint:(CGPoint)point;
- (void)fire;
- (SPDrawingType)detectType;
- (BOOL)canCuttingBy:(SPDrawing*)other;
- (void)expand:(float)rate;
- (ccTime)chargeTime;
- (void)stopCharge;
- (void)removeFromStage;
- (void)updateBoundingBox;

@end
