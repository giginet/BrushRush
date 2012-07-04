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
#import "CCTexture2D+DrawInPoly.h"
#import "SPDrawingManager.h"
#import "OALSimpleAudio.h"
#define DRAW_TEXTURE YES
#define BRUSH_TEXTURE NO

typedef enum {
  SPRotationStraight,
  SPRotationClockwise,
  SPRotationAntiClockwise
} SPRotation;

@interface SPDrawing()
- (void)onUpdateCharge:(KWTimer*)timer;
- (void)onEndCharge;
- (SPRotation)rotationDirectionByPoint:(CGPoint)p0 point1:(CGPoint)p1 point2:(CGPoint)p2;
- (BOOL)intersectsLines:(CGPoint)p0b endPoint:(CGPoint)p0e beginPoint:(CGPoint)p1b endPoint:(CGPoint)p1e;
@end

@implementation SPDrawing
@dynamic isCharging;
@synthesize chain;
@synthesize boundingBox;
@synthesize color;
@synthesize type;
@synthesize points = points_;
@synthesize chargeTimer;
@synthesize player;
@dynamic gravityPoint;
@synthesize writingSound;

- (id)init {
  self = [super init];
  if (self) {
    type = SPDrawingTypeWriting;
    self.chain = 1;
    points_ = [NSMutableArray array];
    color = ccc3(1, 0, 0);
    boundingBox = CGRectMake(0, 0, 0, 0);
    lengthCache_ = 0;
    dirty_ = NO;
    chargeSound_ = [OALAudioTrack track];
    [chargeSound_ preloadFile:[NSString stringWithFormat:@"charge%d.caf", player.identifier]];
    chargeEffect_ = [CCParticleSystemQuad particleWithFile:@"charge.plist"];
    writingSound = [OALAudioTrack track];
    [writingSound preloadFile:@"write.caf"];
    brushTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"brush.png"];
  }
  return self;
}

- (id)initWithPoints:(NSArray *)points {
  self = [self init];
  if (self) {
    points_ = [NSMutableArray arrayWithArray:points];
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
  if (!dirty_) return lengthCache_;
  float length = 0;
  int count = [self.points count];
  if (count <= 1) return 0;
  for (int i = 1; i < count; ++i) {
    CGPoint prev = [[self.points objectAtIndex:i - 1] CGPointValue];
    CGPoint point = [[self.points objectAtIndex:i] CGPointValue];
    length += hypotf(point.x - prev.x, point.y - prev.y);
  }
  lengthCache_ = length;
  dirty_ = NO;
  return length;
}

- (void)draw {
  int count = [self.points count];
  if (count <= 1) return;
  if (self.type == SPDrawingTypeArea) {
    CGPoint vertices[count];
    for (int i = 0; i < count; ++i) {
      vertices[i] = [[self.points objectAtIndex:i] CGPointValue];
    }
    if (DRAW_TEXTURE) {
      glColor4f(1, 1, 1, 1);
      const CCSprite* area = [CCSprite spriteWithFile:[NSString stringWithFormat:@"paint%d.png", self.player.identifier]];
      [area.texture drawInPoly:vertices numberOfPoints:count boundingBox:self.boundingBox];
    } else {
      glColor4f(self.color.r, self.color.g, self.color.b, 1);
      ccFillPoly(vertices, count, YES);
    }
  } else {
    float length = self.length;
    float rate = 1.0 - (self.chargeTimer.now / self.chargeTimer.max);
    float charged = length * rate;
    float dis = 0;
    for (int i = 1; i < count; ++i) {
      CGPoint prev = [[self.points objectAtIndex:i - 1] CGPointValue];
      CGPoint point = [[self.points objectAtIndex:i] CGPointValue];
      dis += ccpDistance(prev, point);
      if (dis <= charged) {
        glColor4f(self.color.r, self.color.g, self.color.b, 1);
      } else {
        glColor4f(self.color.r, 0.4, self.color.b, 1);
      }
      if (BRUSH_TEXTURE) {
        const int radius = 4.5;
        KWVector* vector = [KWVector vectorWithPoint:ccpSub(point, prev)];
        int count = ceil(vector.length / radius);
        for (int i = 0; i < count; ++i) {
          CGPoint p = ccpAdd(prev, [[vector resize:radius] scale:i].point);
          [brushTexture_ drawAtPoint:p];
        }
      } else {
        const int radius = 4.5;
        KWVector* vector = [KWVector vectorWithPoint:ccpSub(point, prev)];
        int count = ceil(vector.length / radius);
        for (int i = 0; i < count; ++i) {
          CGPoint p = ccpAdd(prev, [[vector resize:radius] scale:i].point);
          ccFillCircle(p, radius, 0, 5, YES);
        }
      }
    }
  }
}

- (void)fire {
  chargeSound_.pan = -1 + player.identifier * 2;
  [chargeSound_ playFile:[NSString stringWithFormat:@"charge%d.caf", player.identifier] loops:-1];
  SPDrawingManager* manager = [SPDrawingManager sharedManager];
  int maxChain = 0;
  for (SPDrawing* drawing in manager.drawings) {
    if (CGRectIntersectsRect(drawing.boundingBox, self.boundingBox) && maxChain < drawing.chain && drawing.type == SPDrawingTypeCharge && ![self isEqual:drawing]) {
      maxChain = drawing.chain + 1;
    }
  }
  self.chain = MAX(maxChain, 1);
  if (self.chain > 1) {
    NSLog(@"chain %d ", self.chain);
  }
  chargeTimer = [KWTimer timerWithMax:[self chargeTime]];
  [self.chargeTimer setOnCompleteListener:self selector:@selector(onEndCharge)];
  [self.chargeTimer setOnUpdateListener:self selector:@selector(onUpdateCharge:)];
  [self.chargeTimer play];
  chargeEffect_.position = [[self.points objectAtIndex:0] CGPointValue];
  chargeEffect_.rotation = 180 * player.identifier;
  [self.player addChild:chargeEffect_];
}

- (SPPlayer*)player {
  return player;
}

- (void)setPlayer:(SPPlayer *)p {
  [player.drawings removeObject:self];
  player = p;
  [p.drawings addObject:self];
  self.color = p.color;
}

- (void)addPoint:(CGPoint)point {
  [points_ addObject:[NSValue valueWithCGPoint:point]];
  if ([points_ count] == 1) {
    boundingBox = CGRectMake(point.x, point.y, 0, 0);
  } else {
    CGPoint begin = ccp(boundingBox.origin.x, boundingBox.origin.y);
    CGPoint end = ccpAdd(begin, ccp(boundingBox.size.width, boundingBox.size.height));
    if (point.x < begin.x) {
      begin.x = point.x;
    } else if(point.x > end.x) {
      end.x = point.x;
    }
    if (point.y < begin.y) {
      begin.y = point.y;
    } else if(point.y > end.y) {
      end.y = point.y;
    }
    boundingBox = CGRectMake(begin.x, begin.y, end.x - begin.x, end.y - begin.y);
  }
  dirty_ = YES;
}

- (SPDrawingType)detectType {
  CGPoint begin = [[self.points objectAtIndex:0] CGPointValue];
  CGPoint end = [[self.points lastObject] CGPointValue];
  float distance = ccpDistance(begin, end);
  float length = [self length];
  float diagonal = hypotf(self.boundingBox.size.width, self.boundingBox.size.height);
  if (length > 100 && (distance < 50 || distance <= length * 0.2) && distance <= 100) {
    return SPDrawingTypeCharge;
  } else if (length < diagonal * 1.5){
    return SPDrawingTypeSlash;
  }
  return SPDrawingTypeNone;
}

- (void)onUpdateCharge:(KWTimer*)timer {
  float length = self.length;
  float rate = 1.0 - (self.chargeTimer.now / self.chargeTimer.max);
  float charged = length * rate;
  float disSum = 0;
  int count = [self.points count];
  for (int i = 0; i < count - 1; ++i) {
    KWVector* point = [KWVector vectorWithPoint:[[self.points objectAtIndex:i] CGPointValue]];
    KWVector* next = [KWVector vectorWithPoint:[[self.points objectAtIndex:i + 1] CGPointValue]];
    float dis = ccpDistance(point.point, next.point);
    if (disSum + dis >= charged) {
      KWVector* newPoint = [point add:[[next sub:point] resize:charged - disSum]];
      chargeEffect_.position = newPoint.point;
      break;
    }
    disSum += dis;
  }
}

- (void)onEndCharge {
  [chargeSound_ stop];
  SPDrawingManager* manager = [SPDrawingManager sharedManager];
  [self expand:pow(2, (float)(self.chain - 1) / 4.0)];
  self.type = SPDrawingTypeArea;
  if ([manager.drawings containsObject:self]) {
    [[OALSimpleAudio sharedInstance] playEffect:@"complete.caf"];
  }
  [self.player removeChild:chargeEffect_ cleanup:YES];
  //SPDrawingManager* manager = [SPDrawingManager sharedManager];
  //[manager mergeWithIntersectsDrawing:player.lastDrawing];
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

- (BOOL)canCuttingBy:(SPDrawing *)other {
  if (![self.player isEqual:other.player] && 
      self.type == SPDrawingTypeCharge && 
      other.type == SPDrawingTypeSlash) {
    CGPoint origin = self.boundingBox.origin;
    CGPoint end = ccpAdd(origin, ccp(self.boundingBox.size.width, self.boundingBox.size.height));
    float diagonal = ccpDistance(origin, end);
    if ([self containsPoint:other.gravityPoint] && other.length > diagonal / 2) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)isCharging {
  return self.type == SPDrawingTypeCharge;
}

- (ccTime)chargeTime {
  float time = self.length / 1000 * 2;
  if (self.player.item) {
    if (self.player.item.kind == SPItemKindAccel) {
      time /= 1.5;
    } else if (self.player.item.kind == SPItemKindBrake) {
      time *= 2;
    }
  }
  return time;
}

- (void)expand:(float)rate {
  KWVector* gp = [KWVector vectorWithPoint:self.gravityPoint];
  NSMutableArray* newPoints = [NSMutableArray array];
  for (NSValue* value in self.points) {
    KWVector* v = [KWVector vectorWithPoint:[value CGPointValue]];
    KWVector* sub = [v sub:gp];
    KWVector* newPoint = [gp add:[sub scale:rate]];
    [newPoints addObject:[NSValue valueWithCGPoint:newPoint.point]];
  }
  points_ = newPoints;
}

- (void)stopCharge {
  [chargeSound_ stop];
  [chargeTimer pause];
}

- (void)removeFromStage {
  SPDrawingManager* manager = [SPDrawingManager sharedManager];
  [chargeEffect_.parent removeChild:chargeEffect_ cleanup:YES];
  [manager removeDrawing:self];
}

@end
