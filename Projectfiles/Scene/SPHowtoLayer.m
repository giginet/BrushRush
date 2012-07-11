//
//  SPHowtoLayer.m
//  Spring
//
//  Created by  on 2012/7/5.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPTitleLayer.h"
#import "SPHowtoLayer.h"
#import "OALSimpleAudio.h"

@interface SPHowtoLayer()
- (void)pushNextScene:(NSUInteger)n transition:(BOOL)transition;
@end

@implementation SPHowtoLayer
@synthesize number;

#define HOWTO_COUNT 13

- (id)init {
  self = [self initWithNumber:0];
  if (self) {
    [[OALSimpleAudio sharedInstance] playBg:@"howto.caf" loop:-1];
  }
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
  }
  return self;
}

- (void)onEnter {
  [super onEnter];
}

- (void)update:(ccTime)dt {
  KKInput* input = [KKInput sharedInput];
  input.gestureSwipeEnabled = YES;
  if (input.gesturesAvailable) {
    KKSwipeGestureDirection dir = input.gestureSwipeDirection;
    if (dir  && input.gestureSwipeRecognizedThisFrame) {
      if (dir == KKSwipeGestureDirectionRight) {
        if (number == 0) {
          CCTransitionFade* transition = [CCTransitionFade transitionWithDuration:0.5f scene:[SPTitleLayer nodeWithScene]];
          [[CCDirector sharedDirector] replaceScene:transition];
          [[OALSimpleAudio sharedInstance] stopBg];
        } else {
          [self pushNextScene:self.number - 1 transition:NO];
        }
      } else if (dir == KKSwipeGestureDirectionLeft) {
        if (number < HOWTO_COUNT - 1) {
          [self pushNextScene:self.number + 1 transition:YES];
        } else {
          CCTransitionFade* transition = [CCTransitionFade transitionWithDuration:0.5f scene:[SPTitleLayer nodeWithScene]];
          [[CCDirector sharedDirector] replaceScene:transition];
          [[OALSimpleAudio sharedInstance] stopBg];
        }
      }
    }
  }
}

- (void)pushNextScene:(NSUInteger)n transition:(BOOL)transition {
  swiped_ = NO;
  CCScene* scene = [CCScene node];
  SPHowtoLayer* next = [[SPHowtoLayer alloc] initWithNumber:n];
  [scene addChild:next];
  if (transition) {
    CCTransitionPageTurn* transition = [CCTransitionPageTurn transitionWithDuration:0.5f scene:scene];
    [[CCDirector sharedDirector] replaceScene:transition];
    [[OALSimpleAudio sharedInstance] playEffect:@"paper.caf"];
  } else {
    [[CCDirector sharedDirector] replaceScene:scene];
  }
}
 
@end
