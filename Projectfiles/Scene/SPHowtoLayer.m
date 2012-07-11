//
//  SPHowtoLayer.m
//  Spring
//
//  Created by  on 2012/7/5.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPTitleLayer.h"
#import "SPHowtoLayer.h"

@interface SPHowtoLayer()
- (void)pushNextScene:(NSUInteger)n;
@end

@implementation SPHowtoLayer
@synthesize number;

#define HOWTO_COUNT 12

- (id)init {
  self = [self initWithNumber:0];
  return self;
}

- (id)initWithNumber:(NSUInteger)n {
  self = [super init];
  if (self) {
    CCDirector* director = [CCDirector sharedDirector];
    CCSprite* background = [CCSprite spriteWithFile:@"title_background.png"];
    background.position = director.screenCenter;
    [self addChild:background];
    
    howtoLayer_ = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 127)];
    CCSprite* sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"howto%d.png", n]];
    sprite.position = director.screenCenter;
    [howtoLayer_ addChild:sprite];
    number = n;
    [self addChild:howtoLayer_];
    [self scheduleUpdate];
    swiped_ = NO;
    KKInput* input = [KKInput sharedInput];
    input.gestureSwipeEnabled = NO;
  }
  return self;
}

- (void)update:(ccTime)dt {
  KKInput* input = [KKInput sharedInput];
  input.gestureSwipeEnabled = YES;
  if (input.gesturesAvailable) {
    KKSwipeGestureDirection dir = input.gestureSwipeDirection;
    if (dir) {
      if (dir == KKSwipeGestureDirectionLeft) {
        swiped_ = YES;
        if (number == 0) {
          CCTransitionFade* transition = [CCTransitionFade transitionWithDuration:0.5f scene:[SPTitleLayer nodeWithScene]];
          [[CCDirector sharedDirector] replaceScene:transition];
        
        } else {
          [self pushNextScene:self.number - 1];
        }
      } else if (dir == KKSwipeGestureDirectionRight) {
        swiped_ = YES;
        if (number <= HOWTO_COUNT - 1) {
          [self pushNextScene:self.number + 1];
        } else {
          CCTransitionFade* transition = [CCTransitionFade transitionWithDuration:0.5f scene:[SPTitleLayer nodeWithScene]];
          [[CCDirector sharedDirector] replaceScene:transition];
        }
      }
    }
  }
}

- (void)pushNextScene:(NSUInteger)n {
  swiped_ = NO;
  CCScene* scene = [CCScene node];
  SPHowtoLayer* next = [[SPHowtoLayer alloc] initWithNumber:self.number + 1];
  [scene addChild:next];
  CCTransitionPageTurn* transition = [CCTransitionPageTurn transitionWithDuration:0.5f scene:scene];
  [[CCDirector sharedDirector] replaceScene:transition];
}
 
@end
