//
//  SPStatusBar.m
//  Spring
//
//  Created by  on 2012/6/18.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "KWGauge.h"
#import "SPStatusBar.h"
#import "CCToggleSprite.h"
#define OFFSET 64

@implementation SPStatusBar

- (id)initWithFile:(NSString *)filename {
  self = [super initWithFile:@"status.png"];
  if (self) {
    CCDirector* director = [CCDirector sharedDirector];
    self.position = director.screenCenter;
    timeGauges_ = [NSMutableArray array];
    crystals_ = [NSMutableArray array];
    badges_ = [NSMutableArray array];
    for (int i = 0; i < 2; ++i) {
      KWGauge* gauge = [KWGauge gaugeWithFile:@"gauge.png"];
      [gauge alignHolizontally];
      float width = 295;
      float k = i == 0 ? 1.0 : -1.0;
      gauge.scaleX = k;
      gauge.position = ccp(director.screenCenter.x + (float)k * width / 2.0, self.contentSize.height / 2);
      [self addChild:gauge];
      [timeGauges_ addObject:gauge];
      
      CCToggleSprite* crystal = [[CCToggleSprite alloc] initWithFormat:[NSString stringWithFormat:@"crystal%d_%@.png", i, @"%@"]]; 
      int x = i == 0 ? OFFSET : director.screenSize.width - OFFSET;
      crystal.position = ccp(x, self.contentSize.height / 2);
      [self addChild:crystal];
      [crystals_ addObject:crystal];
    }
    
    for (int i = 0; i < 4; ++i) {
      int player = i / 2;
      CCToggleSprite* badge = [[CCToggleSprite alloc] initWithFormat:[NSString stringWithFormat:@"win%d_%@.png", player, @"%@"]];
      int xs[] = {-240, -210, 240, 210};
      int ys[] = {-36, -36, 36, 36};
      badge.position = ccpAdd(ccp(self.contentSize.width / 2, self.contentSize.height / 2), ccp(xs[i], ys[i]));
      [self addChild:badge];
      [badges_ addObject:badge];
    }
  }
  return self;
}

- (void)setGaugeRate:(float)rate {
  if (rate < 0 || rate > 1.0) return;
  for (KWGauge* gauge in timeGauges_) {
    gauge.rate = rate;
  }
}

- (void)setEnableCrystal:(NSUInteger)number enable:(BOOL)enable {
  CCToggleSprite* crystal = [crystals_ objectAtIndex:number];
  /*[crystal runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                                                        [CCFadeTo actionWithDuration:0.1 opacity:127],
                                                        [CCFadeTo actionWithDuration:0.1 opacity:255],
                                                        nil]]];*/
  crystal.toggle = enable;
}

- (void)setBadge:(NSUInteger)player0 player1:(NSUInteger)player1 {
  for (CCToggleSprite* sprite in badges_) {
    sprite.toggle = NO;
  }
  CCToggleSprite* b00 = [badges_ objectAtIndex:0];
  CCToggleSprite* b01 = [badges_ objectAtIndex:1];
  CCToggleSprite* b10 = [badges_ objectAtIndex:2];
  CCToggleSprite* b11 = [badges_ objectAtIndex:3];
  if (player0 >= 2) {
    b01.toggle = YES;
  }
  if (player0 >= 1) {
    b00.toggle = YES;
  }
  if (player1 >= 2) {
    b11.toggle = YES;
  }
  if (player1 >= 1) {
    b10.toggle = YES;
  }
}

@end
