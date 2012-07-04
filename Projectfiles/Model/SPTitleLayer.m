//
//  SPTitleLayer.m
//  Spring
//
//  Created by  on 2012/7/5.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPTitleLayer.h"
#import "SPMainLayer.h"

@implementation SPTitleLayer

- (id)init {
  self = [super init];
  if (self) {
    CCDirector* director = [CCDirector sharedDirector];
    CCSprite* background = [CCSprite spriteWithFile:@"title_background.png"];
    background.position = director.screenCenter;
    [self addChild:background];
    
    CCSprite* logo = [CCSprite spriteWithFile:@"logo.png"];
    logo.position = ccp(director.screenCenter.x, 800);
    [self addChild:logo];
    
    CCSprite* tail = [CCSprite spriteWithFile:@"title_tail.png"];
    tail.position = ccp(530, 150);
    tail.anchorPoint = ccp(0.3, 0.25);
    [self addChild:tail];
    [tail runAction:[CCRepeatForever actionWithAction:
                     [CCSequence actions:
                      [CCEaseSineInOut actionWithAction:[CCRotateTo actionWithDuration:1.0 angle:30]],
                      [CCEaseSineInOut actionWithAction:[CCRotateTo actionWithDuration:1.0 angle:-10]],
                      nil]]];
    
    CCSprite* sign = [CCSprite spriteWithFile:@"titlemenu_background.png"];
    sign.position = ccp(450, 300);
    [self addChild:sign];
    
    CCMenuItem* play = [CCMenuItemImage itemFromNormalImage:@"play.png" 
                                              selectedImage:@"play_selected.png" 
                                              disabledImage:@"play_selected.png" 
                                                      block:^(id sender){
                                                        CCTransitionFade* transition = [CCTransitionFade transitionWithDuration:0.5f scene:[SPMainLayer nodeWithScene]];
                                                        [director replaceScene:transition];
                                                      }];
    CCMenuItem* howto = [CCMenuItemImage itemFromNormalImage:@"howto.png" 
                                               selectedImage:@"howto_selected.png" 
                                               disabledImage:@"howto_selected.png" 
                                                       block:^(id sender){
                                                       }];
    CCMenu* menu = [CCMenu menuWithItems:play, howto, nil];
    [menu alignItemsVerticallyWithPadding:55];
    menu.position = ccp(director.screenCenter.x, 385);
    [self addChild:menu];
    
  }
  return self;
}

@end
