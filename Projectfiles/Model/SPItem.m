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
#define BLIND_TAG 100

@interface SPItem()
- (NSString*)textureName:(int)k;
- (NSString*)nameWithKind:(int)k;
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
  return [[SPItem alloc] initWithFile:@""];
}

- (id)initWithFile:(NSString *)filename {
  itemRoulette_ = [NSMutableArray array];
  for (int i = 0; i < SPItemKindNum; ++i) {
    [itemRoulette_ addObject:[NSNumber numberWithInt:i]];
  }
  itemRoulette_ = [NSMutableArray arrayWithArray:[itemRoulette_ shuffle]];
  kind = [[itemRoulette_ objectAtIndex:0] intValue];
  self = [super initWithFile:[self textureName:kind]];
  if (self) {
    rouletteIndex_ = 1;
    changeTimer = [KWTimer timerWithMax:2.0];
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
  rouletteIndex_ = (rouletteIndex_ + 1) % SPItemKindNum;
  self.kind = [[itemRoulette_ objectAtIndex:rouletteIndex_] intValue];
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

- (NSString*)textureName:(int)k { 
  return [NSString stringWithFormat:@"item_%@.png", self.name];
}

- (void)setKind:(SPItemKind)k {
  kind = k;
  [self setTexture:[[CCTextureCache sharedTextureCache] addImage:[self textureName:k]]];
}

- (NSString*)nameWithKind:(int)k {
  NSString* names[] = {@"accel", @"blind", @"brake", @"paint", @"snatch"};
  return names[(int)k];
}

- (NSString*)name {
  return [self nameWithKind:self.kind];
}

- (void)useBy:(SPPlayer *)user {
  int times[] = {7, 7, 5, 1, 1}; 
  if (self.kind == SPItemKindBlind) {
    if ([user getChildByTag:BLIND_TAG]) {
      [user removeChildByTag:BLIND_TAG cleanup:YES];
    }
    blindSound_ = [OALAudioTrack track];
    [blindSound_ preloadFile:@"blind.caf"];
    SPPlayer* enemy = [SPPlayer playerById:(user.identifier + 1) % 2];
    CCAnimation* anime = [CCAnimation animationWithFiles:[NSString stringWithFormat:@"blind%d_", user.identifier] frameCount:2 delay:1.0];
    CCSprite* sprite = [CCSprite spriteWithFile:@"blind0_0.png"];
    sprite.position = enemy.center;
    [sprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anime]]];
    if (![enemy getChildByTag:BLIND_TAG]) {
      [enemy addChild:sprite z:SPPlayerLayerBlind tag:BLIND_TAG];
    }
    [blindSound_ play];
  }
  [self.changeTimer stop];
  [self.useTimer set:times[(int)self.kind]];
  [self.useTimer play];
}

- (void)onCompleteUseTimer:(KWTimer *)timer {
  SPDrawingManager* manager = [SPDrawingManager sharedManager];
  SPPlayer* enemy = [SPPlayer playerById:(self.player.identifier + 1) % 2];
  switch (self.kind) {
    case SPItemKindAccel:
      [[OALSimpleAudio sharedInstance] playEffect:@"item_out.caf"];
      break;
    case SPItemKindBrake:
      [[OALSimpleAudio sharedInstance] playEffect:@"item_out.caf"];
      break;
    case SPItemKindBlind:
      [enemy removeChildByTag:BLIND_TAG cleanup:YES];
      [blindSound_ stop];
      [[OALSimpleAudio sharedInstance] playEffect:@"item_out.caf"];
      break;
    case SPItemKindPaint:
      [[OALSimpleAudio sharedInstance] playEffect:@"paint.caf"];
      [manager paintAt:self.position player:self.player];
      break;
    case SPItemKindSnatch:
      if (enemy.lastArea && [manager.drawings containsObject:enemy.lastArea]) {
        [[OALSimpleAudio sharedInstance] playEffect:@"snatch.caf"];
        [manager removeDrawing:enemy.lastArea];
        enemy.lastArea.player = self.player;
        [manager addDrawing:enemy.lastArea];
        player.lastArea = enemy.lastArea;
      } else {
        [[OALSimpleAudio sharedInstance] playEffect:@"item_out.caf"];
      }
      enemy.lastArea = nil;
      break;
    default:
      break;
  }
  self.player.item = nil;
  self.player = nil;
}

@end
