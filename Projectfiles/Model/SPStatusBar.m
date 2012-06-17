//
//  SPStatusBar.m
//  Spring
//
//  Created by  on 2012/6/18.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "KWGauge.h"
#import "SPStatusBar.h"
#define OFFSET 64

@implementation SPStatusBar

- (id)initWithFile:(NSString *)filename {
  self = [super initWithFile:@"status.png"];
  if (self) {
    CCDirector* director = [CCDirector sharedDirector];
    self.position = director.screenCenter;
    timeGauges_ = [NSMutableArray array];
    for (int i = 0; i < 2; ++i) {
      KWGauge* gauge = [KWGauge gaugeWithFile:@"gauge.png"];
      [gauge alignHolizontally];
      float width = 295;
      float k = i == 0 ? 1.0 : -1.0;
      gauge.scaleX = k * -1;
      gauge.position = ccp(director.screenCenter.x + (float)k * width / 2.0, self.contentSize.height / 2);
      [self addChild:gauge];
      [timeGauges_ addObject:gauge];
      
      CCSprite* crystal = [CCSprite spriteWithFile:[NSString stringWithFormat:@"crystal%d_disable.png", i]];
      int x = i == 0 ? OFFSET : director.screenSize.width - OFFSET;
      crystal.position = ccp(x, self.contentSize.height / 2);
      [self addChild:crystal];
      [crystals_ addObject:crystal];
    }
  }
  return self;
}

@end
