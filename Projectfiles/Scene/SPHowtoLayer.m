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
- (void)pressPrev:(id)sender;
- (void)pressNext:(id)sender;
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
    CCMenuItem* left = [CCMenuItemImage itemFromNormalImage:@"left.png" 
                                              selectedImage:@"left_selected.png" 
                                              disabledImage:@"left_selected.png" target:self selector:@selector(pressPrev:)];
    CCMenuItem* right = [CCMenuItemImage itemFromNormalImage:@"right.png" 
                                               selectedImage:@"right_selected.png" 
                                               disabledImage:@"right_selected.png" target:self selector:@selector(pressNext:)];
    left.scale = 1.5;
    right.scale = 1.5;
    CCMenu* menu = [CCMenu menuWithItems:left, right, nil];
    menu.position = ccpAdd(director.screenCenter, ccp(0, -440));
    [menu alignItemsHorizontallyWithPadding:640];
    [self addChild:menu];
  }
  return self;
}

- (void)onEnter {
  [super onEnter];
}

- (void)pushNextScene:(NSUInteger)n transition:(BOOL)transition {
  swiped_ = NO;
  CCScene* scene = [CCScene node];
  SPHowtoLayer* next = [[SPHowtoLayer alloc] initWithNumber:n];
  [scene addChild:next];
  [[OALSimpleAudio sharedInstance] playEffect:@"paper.caf"];
  if (transition) {
    CCTransitionPageTurn* transition = [CCTransitionPageTurn transitionWithDuration:0.5f scene:scene];
    [[CCDirector sharedDirector] replaceScene:transition];
  } else {
    [[CCDirector sharedDirector] replaceScene:scene];
  }
}

- (void)pressNext:(id)sender {
  if (number < HOWTO_COUNT - 1) {
    [self pushNextScene:self.number + 1 transition:YES];
  } else {
    CCTransitionFade* transition = [CCTransitionFade transitionWithDuration:0.5f scene:[SPTitleLayer nodeWithScene]];
    [[CCDirector sharedDirector] replaceScene:transition];
    [[OALSimpleAudio sharedInstance] stopBg];
  }
}

- (void)pressPrev:(id)sender {
  if (number == 0) {
    CCTransitionFade* transition = [CCTransitionFade transitionWithDuration:0.5f scene:[SPTitleLayer nodeWithScene]];
    [[CCDirector sharedDirector] replaceScene:transition];
    [[OALSimpleAudio sharedInstance] stopBg];
  } else {
    [self pushNextScene:self.number - 1 transition:NO];
  }
}
 
@end
