//
//  SPItem.m
//  Spring
//
//  Created by  on 6/21/12.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPItem.h"
#import "SPDrawingManager.h"
#import "define.h"

@interface SPItem()
- (void)onCompleteChangeTimer:(KWTimer*)timer;
- (void)onCompleteUseTimer:(KWTimer *)timer;
@end

@implementation SPItem
@synthesize kind;
@dynamic name;
@synthesize changeTimer;
@synthesize useTimer;
@synthesize velocity;
@synthesize player;

+ (SPItem*)item {
  KWRandom* rnd = [KWRandom random];
  int kind = [rnd nextInt] % SPItemKindNum;
  return [[SPItem alloc] initWithKind:kind];
}

- (id)initWithKind:(SPItemKind)k {
  self = [super init];
  if (self) {
    kind = k;
    changeTimer = [KWTimer timerWithMax:1.0];
    [self.changeTimer setOnCompleteListener:self 
                                   selector:@selector(onCompleteChangeTimer:)];
    self.changeTimer.looping = YES;
    useTimer = [KWTimer timer];
    velocity = [KWVector vectorAtRandom];
    [velocity resize:3];
    [self.changeTimer play];
    [self.useTimer setOnCompleteListener:self selector:@selector(onCompleteUseTimer:)];
  }
  return self;
}

- (SPItemKind)changeRandom {
  KWRandom* rnd = [KWRandom random];
  self.kind = ([rnd nextIntFrom:0 to:SPItemKindNum - 1] + self.kind) % SPItemKindNum;
  return self.kind;
  }

- (void)onEnter {
  [super onEnter];
  [self.changeTimer play];
}

- (void)onCompleteChangeTimer:(KWTimer *)timer {
  [self changeRandom];
}

- (SPItemKind)kind {
  return kind;
}

- (void)update:(ccTime)time {
  self.position = ccpAdd(self.position, self.velocity.point);
  if (self.position.x > PLAYER_WIDTH - self.texture.contentSize.width) {
    velocity = [self.velocity reflect:[KWVector vectorWithPoint:ccp(-1, 0)]];
    self.position = ccp(PLAYER_WIDTH - self.texture.contentSize.width, self.position.y);
  } else if (self.position.x < 0) {
    velocity = [self.velocity reflect:[KWVector vectorWithPoint:ccp(1, 0)]];
    self.position = ccp(0, self.position.y);
  }
  if (self.position.y > PLAYER_HEIGHT - self.texture.contentSize.height) {
    velocity = [self.velocity reflect:[KWVector vectorWithPoint:ccp(0, -1)]];
    self.position = ccp(self.position.x, PLAYER_HEIGHT - self.texture.contentSize.height);
  } else if (self.position.y < 0) {
    velocity = [self.velocity reflect:[KWVector vectorWithPoint:ccp(0, 1)]];
    self.position = ccp(self.position.x, 0);
  }
}

- (void)setKind:(SPItemKind)k {
  kind = k;
  [self setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"item_%@.png", self.name]]];
}

- (NSString*)name {
  NSString* names[] = {@"accel", @"blind", @"brake", @"paint", @"snatch"};
  return names[(int)kind];
}

- (void)useBy:(SPPlayer *)player {
  int times[] = {7, 7, 7, 1, 1};
  switch (self.kind) {
    case SPItemKindAccel:
      break;
    case SPItemKindBrake:
      break;
    case SPItemKindBlind:
      break;
    case SPItemKindPaint:
      break;
    case SPItemKindSnatch:
      break;
    default:
      break;
  }
  [self.changeTimer stop];
  [self.useTimer set:times[(int)self.kind]];
  [self.useTimer play];
}

- (void)onCompleteUseTimer:(KWTimer *)timer {
  SPDrawingManager* manager = [SPDrawingManager sharedManager];
  switch (self.kind) {
    case SPItemKindAccel:
      break;
    case SPItemKindBrake:
      break;
    case SPItemKindBlind:
      break;
    case SPItemKindPaint:
      [manager paintAt:self.position player:self.player];
      break;
    case SPItemKindSnatch:
      for(SPDrawing* drawing in [manager.drawings reverseObjectEnumerator]) {
        if (![drawing.player isEqual:self.player]) {
          drawing.player = self.player;
          break;
        }
      }
      break;
    default:
      break;
  }
  self.player.item = nil;
  self.player = nil;
}

@end
