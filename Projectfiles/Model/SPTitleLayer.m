//
//  SPTitleLayer.m
//  Spring
//
//  Created by  on 2012/7/5.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPTitleLayer.h"
#import "SPMainLayer.h"

@interface SPTitleLayer()
- (CCNode*)logo;
@end

@implementation SPTitleLayer

- (id)init {
  self = [super init];
  if (self) {
    CCDirector* director = [CCDirector sharedDirector];
    CCSprite* background = [CCSprite spriteWithFile:@"title_background.png"];
    background.position = director.screenCenter;
    [self addChild:background];
    
    CCNode* logo = [self logo];
    logo.position = ccp(director.screenCenter.x - 632 / 2, 800 - 446 / 2);
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
    
    CCLabelTTF* credit = [CCLabelTTF labelWithString:@"copyright Ⓒ2009-2012 Kawaz All right reserved." fontName:@"Helvetica" fontSize:16];
    credit.position = ccp(director.screenCenter.x, 60);
    [self addChild:credit];
    
  }
  return self;
}

- (CCNode*)logo {
  const float delay = 0.5;
  const float line = 0.3;
  const float flower = 0.3;
  const float logo = 0.5;
  
  CCNode* node = [CCNode node];
  CCSprite* chara = [CCSprite spriteWithFile:@"logo_character.png"];
  chara.position = ccp(207, 218);
  [node addChild:chara];
  
  CCSprite* bl = [CCSprite spriteWithFile:@"logo_blue_line.png"];
  bl.position = ccp(120, 288);
  bl.anchorPoint = ccp(0, 0.5);
  [node addChild:bl];
  bl.scaleX = 0.0;
  [bl runAction:[CCSequence actions:
                 [CCDelayTime actionWithDuration:delay], 
                 [CCScaleTo actionWithDuration:line scaleX:1.0 scaleY:1.0],
                 nil]];
  
  CCSprite* rl = [CCSprite spriteWithFile:@"logo_red_line.png"];
  rl.position = ccp(624, 138);
  rl.anchorPoint = ccp(1.0, 0.5);
  [node addChild:rl];
  rl.scaleX = 0.0;
  [rl runAction:[CCSequence actions:
                 [CCDelayTime actionWithDuration:delay], 
                 [CCScaleTo actionWithDuration:line scaleX:1.0 scaleY:1.0],
                 nil]];
  
  CCSprite* text = [CCSprite spriteWithFile:@"logo_text.png"];
  text.position = ccp(356, 229);
  [node addChild:text];
  text.opacity = 0.0;
  [text runAction:[CCSequence actions:
                 [CCDelayTime actionWithDuration:delay + line + flower], 
                 [CCFadeIn actionWithDuration:logo],
                 nil]];
  
  CCSprite* bf = [CCSprite spriteWithFile:@"logo_blue_flower.png"];
  bf.position = ccp(434, 387);
  [node addChild:bf];
  bf.scale = 0.0;
  [bf runAction:[CCSequence actions:
                 [CCDelayTime actionWithDuration:delay + line], 
                 [CCScaleTo actionWithDuration:flower scale:1.0],
                 nil]];
  
  
  CCSprite* rf = [CCSprite spriteWithFile:@"logo_red_flower.png"];
  rf.position = ccp(235, 62);
  [node addChild:rf];
  rf.scale = 0.0;
  [rf runAction:[CCSequence actions:
                 [CCDelayTime actionWithDuration:delay + line], 
                 [CCScaleTo actionWithDuration:flower scale:1.0],
                 nil]];
  
  
  return node;
}

@end
