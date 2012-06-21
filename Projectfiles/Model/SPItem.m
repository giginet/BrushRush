//
//  SPItem.m
//  Spring
//
//  Created by  on 6/21/12.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPItem.h"

@interface SPItem()
- (void)onCompleteChangeTimer:(KWTimer*)timer;
@end

@implementation SPItem
@synthesize kind;
@dynamic name;
@synthesize changeTimer;
@synthesize velocity;

+ (SPItem*)item {
  KWRandom* rnd = [KWRandom random];
  return [[SPItem alloc] initWithKind:[rnd nextInt] % SPItemKindNum];
}

- (id)initWithKind:(SPItemKind)k {
  self = [super init];
  if (self) {
    self.kind = k;
    changeTimer = [KWTimer timerWithMax:1.0];
    [self.changeTimer setOnCompleteListener:self 
                                   selector:@selector(onCompleteChangeTimer:)];
    self.changeTimer.looping = YES;
    velocity = [KWVector vectorAtRandom];
    [self scheduleUpdate];
  }
  return self;
}

- (SPItemKind)changeRandom {
  KWRandom* rnd = [KWRandom random];
  self.kind = (SPItemKind)((self.kind + [rnd nextInt] % (SPItemKindNum - 1)) % SPItemKindNum);
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
}

- (void)setKind:(SPItemKind)k {
  kind = k;
  [self setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"item_%@.png", self.name]]];
}

- (NSString*)name {
  NSString* names[] = {@"accel", @"blind", @"brake", @"paint", @"snatch"};
  return names[(int)self.kind];
}

@end
