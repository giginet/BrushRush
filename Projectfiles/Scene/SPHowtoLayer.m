//
//  SPHowtoLayer.m
//  Spring
//
//  Created by  on 2012/7/5.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPHowtoLayer.h"

@implementation SPHowtoLayer

- (id)init {
  self = [super init];
  if (self) {
    CCDirector* director = [CCDirector sharedDirector];
    CCSprite* background = [CCSprite spriteWithFile:@"title_background.png"];
    background.position = director.screenCenter;
    [self addChild:background];
  }
  return self;
}

@end
