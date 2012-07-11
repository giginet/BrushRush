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


// 高速化のためにチャージ状態を構造体として保存しておくけどめちゃくちゃ可読性悪いのでコメント
// chargedEdgeIndex チャージが完了した点の手前の頂点のindex値
// distanceFromEdge 手前の頂点からチャージ完了地点までの距離
// distanceSumToEdge 0番目の点から、チャージ完了地点の手前の頂点までの距離の総和
// chargedPoint チャージ完了した点
typedef struct {
  int chargedEdgeIndex;
  float distanceFromEdge;
  float distanceSumToEdge;
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
  CCTexture2D* brushTexture_;
}

@property(readonly) BOOL isCharging;
@property(readwrite) BOOL isPaint;
@property(readwrite) int chain;
@property(readonly) float angle;
@property(readonly) CGRect boundingBox;
@property(readonly) CGPoint gravityPoint;
@property(readwrite) ccColor3B color;
@property(readwrite) SPDrawingType type;
@property(readonly, strong) NSArray* points;
@property(readonly) KWTimer* chargeTimer;
@property(readwrite, weak) SPPlayer* player;

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
