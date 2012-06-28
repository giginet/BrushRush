//
//  SPMainLayer.m
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPDrawing.h"
#import "SPMainLayer.h"
#import "CCDrawingPrimitives.h"
#import "SPDrawingManager.h"
#import "define.h"

@interface SPMainLayer()
- (void)update:(ccTime)dt;
- (SPPlayer*)checkWinner;
- (void)startGame;
- (void)onGameTimerUpdate:(KWTimer*)timer;
- (void)onGameTimerOver:(KWTimer*)timer;
- (void)onReady;
- (void)onResult;
- (void)disableCurrentDrawing:(NSSet*)touches;
@end

@implementation SPMainLayer
@synthesize state;
@dynamic drawings;
@synthesize players;
@synthesize statusbar;
@synthesize gameTimer;
@synthesize itemTimer;
@synthesize music;

- (id)init {
  self = [super init];
  if (self) {
    players = [NSMutableArray array];
    self.isTouchEnabled = YES;
    CCDirector* director = [CCDirector sharedDirector];
    for (int i = 0; i < 2; ++i) {
      CCSprite* background = [CCSprite spriteWithFile:@"background.png"];
      background.position = ccp(director.screenCenter.x, (FRAME_SIZE + PLAYER_HEIGHT + STATUSBAR_HEIGHT) * i + (FRAME_SIZE + PLAYER_HEIGHT) / 2);
      [self addChild:background];      
    }
    for (int i = 0; i < 2; ++i) {
      SPPlayer* player = [[SPPlayer alloc] initWithId:i];
      [self.players addObject:player];
      [self addChild:player];
      CCSprite* frame = [CCSprite spriteWithFile:[NSString stringWithFormat:@"player%d.png", i]];
      frame.position = ccp(director.screenCenter.x, (FRAME_SIZE + PLAYER_HEIGHT + STATUSBAR_HEIGHT) * i + (FRAME_SIZE + PLAYER_HEIGHT) / 2);
      [self addChild:frame];
      player.frame = frame;
    }
    statusbar = [SPStatusBar spriteWithFile:@"status.png"];
    [self addChild:statusbar];
    gameTimer = [KWTimer timerWithMax:GAME_TIME];
    [gameTimer setOnUpdateListener:self selector:@selector(onGameTimerUpdate:)];
    [gameTimer setOnCompleteListener:self selector:@selector(onGameTimerOver:)];
    itemTimer = [KWTimer timerWithMax:[[KWRandom random] nextIntFrom:5 to:15]];
    [itemTimer setOnCompleteListenerWithBlock:^(id obj) {
      [[OALSimpleAudio sharedInstance] playEffect:@"item_in.caf"];
      SPItem* item = [SPItem item];
      KWRandom* rnd = [KWRandom random];
      item.position = ccp([rnd nextIntFrom:0 to:PLAYER_WIDTH], [rnd nextIntFrom:0 to:PLAYER_HEIGHT]);
      [[SPDrawingManager sharedManager] addItem:item];
      KWTimer* timer = (KWTimer*)obj;
      timer.max = [rnd nextIntFrom:5 to:15];
      [timer reset];
    }];
    [self scheduleUpdate];
    music = [KWLoopAudioTrack trackWithIntro:@"main_intro.caf" loop:@"main_loop.caf"];
    [self.music play];
    [self startGame];
  }
  return self;
}

- (void)onEnter {
  [super onEnter];
}

- (void)update:(ccTime)dt {
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.state != SPGameStateMatch) return;
  SPDrawingManager* manager = [SPDrawingManager sharedManager];
  for (UITouch* touch in touches) {
    CGPoint point = [self convertTouchToNodeSpace:touch];
    for (SPPlayer* player in self.players) {
      if (!player.lastTouch && [player containsPoint:point]) {
        BOOL used = NO;
        for (SPItem* item in [NSArray arrayWithArray:manager.items]) {
          CGRect box = CGRectMake(item.position.x, item.position.y, item.texture.contentSize.width, item.texture.contentSize.height);
          CGPoint local = [player convertToNodeSpace:point];
          if (CGRectContainsPoint(box, local)) {
            [player getItem:item];
            used = YES;
            break;
          }
        }
        if (!used) {
          player.lastTouch = touch;
          SPDrawing* drawing = [[SPDrawing alloc] init];
          [manager addDrawing:drawing];
          drawing.player = player;
          [drawing addPoint:[player convertToNodeSpace:point]];
        }
      }
    }
  }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.state == SPGameStateMatch) {
    for (UITouch* touch in touches) {
      CGPoint point = [self convertTouchToNodeSpace:touch];
      for (SPPlayer* player in self.players) {
        if ([player.lastTouch isEqual:touch]) {
          CGPoint local = [player convertToNodeSpace:point];
          if (local.x < 0 || local.x > PLAYER_WIDTH || local.y < 0 || local.y > PLAYER_HEIGHT) {
          [self disableCurrentDrawing:touches];
          }
          SPDrawing* drawing = [player.drawings lastObject];
          [drawing addPoint:[player convertToNodeSpace:point]];
        }
      }
    }
  } else {
    for (UITouch* touch in touches) {
      for (SPPlayer* player in self.players) {
        if ([player.lastTouch isEqual:touch]) {
          player.lastTouch = nil;
          [[SPDrawingManager sharedManager] removeDrawing:player.lastDrawing];
        }
      }
    }
  }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.state == SPGameStateMatch) {
    SPDrawingManager* manager = [SPDrawingManager sharedManager];
    for (UITouch* touch in touches) {
      for (SPPlayer* player in self.players) {
        if ([player.lastTouch isEqual:touch]) {
          SPDrawing* lastDrawing = player.lastDrawing;
          if([lastDrawing isClose]) {
            lastDrawing.type = SPDrawingTypeCharge;
            [lastDrawing fire];
          } else {
            lastDrawing.type = SPDrawingTypeSlash;
            [[OALSimpleAudio sharedInstance] playEffect:@"slash.caf"];
            for (SPDrawing* other in [NSArray arrayWithArray:self.drawings]) {
              if ([other canCuttingBy:lastDrawing]) {
                NSLog(@"cut");
                [manager removeDrawing:other];
                [[OALSimpleAudio sharedInstance] playEffect:@"slash.caf"];
              }
            }
            [manager removeDrawing:lastDrawing];
          }
          player.lastTouch = nil;
          //NSLog(@"%f x %f, %f, %f", player.lastDrawing.boundingBox.size.width, player.lastDrawing.boundingBox.size.height, player.lastDrawing.boundingBox.origin.x, player.lastDrawing.boundingBox.origin.y);
        }
      }
    }
  } else if (self.state == SPGameStateResult) {
    [self disableCurrentDrawing:touches];
    [self startGame];
  }
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch* touch in touches) {
    for (SPPlayer* player in self.players) {
      if ([player.lastTouch isEqual:touch]) {
        player.lastTouch = nil;
        [[SPDrawingManager sharedManager] removeDrawing:player.lastDrawing];
      }
    }
  }
}

- (NSArray*)drawings {
  SPDrawingManager* manager = [SPDrawingManager sharedManager];
  return manager.drawings;
}

- (void)draw {
  [super draw];
}

- (SPPlayer*)checkWinner {
  // Count pixels on CCRenderTexture.
  // ref http://iphone.moo.jp/app/?p=707
  int player0 = 0;
  int player1 = 0;
  SPDrawingManager* manager = [SPDrawingManager sharedManager];
  CCRenderTexture* texture = [manager renderTextureWithDrawings];
  NSData* raw = [texture getUIImageAsDataFromBuffer:kCCTexture2DPixelFormat_RGBA8888];
  UIImage* img = [UIImage imageWithData:raw];
  CGImageRef cgImage = [img CGImage];
  size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
  CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
  CFDataRef data = CGDataProviderCopyData(dataProvider);
  UInt8* pixels = (UInt8*)CFDataGetBytePtr(data);
  for (int y = 0 ; y < img.size.height; y++){
    for (int x = 0; x < img.size.width; x++){
      UInt8* buf = pixels + y * bytesPerRow + x * 4;
      UInt8 r, g, b;
      r = *(buf + 0);
      g = *(buf + 1);
      b = *(buf + 2);
      if (r == 255) {
        player0 += 1;
      } else if (b == 255) {
        player1 += 1;
      }
    }
  }
  NSLog(@"red = %d, blue = %d", player0, player1);
  if (player0 > player1) {
    return [self.players objectAtIndex:0];
  } else if(player0 < player1) {
    return [self.players objectAtIndex:1];
  }
  return nil;
}

- (void)startGame {
  self.state = SPGameStateReady;
  for (SPPlayer* player in self.players) {
    [player removeAllChildrenWithCleanup:YES];
  }
  for (int i = 0; i < 2; ++i) [self.statusbar setEnableCrystal:i enable:NO];
  [self.statusbar setGaugeRate:1.0];
  [[SPDrawingManager sharedManager] removeAllDrawings];
  [[SPDrawingManager sharedManager] removeAllItems];
  [self scheduleOnce:@selector(onReady) delay:0.5];
  self.music.volume = 0.25;
  [self.itemTimer play];
}

- (void)onReady {
   for (SPPlayer* player in self.players) { 
     CCSprite* label = [CCSprite spriteWithFile:@"ready.png"];
     [[OALSimpleAudio sharedInstance] playEffect:@"ready0.caf"];
     label.position = ccp(player.center.x, player.center.y + 60);
    [player addChild:label];
     __block CCSprite* go = [CCSprite spriteWithFile:@"go.png"];
     id scale = [CCScaleTo actionWithDuration:0.2 scale:1.0];
     id delay = [CCDelayTime actionWithDuration:1.8];
     id suicide = [CCCallBlockN actionWithBlock:^(CCNode* node) {
      [node.parent removeChild:node cleanup:YES];
     }];
     label.scale = 0.0;
     go.position = label.position;
     go.scale = 0.0;
     [go runAction:[CCSequence actions:
                    scale, 
                    [CCDelayTime actionWithDuration:0.4], 
                    [CCMoveTo actionWithDuration:1.0 position:ccp(2000, go.position.y)],
                    suicide, 
                    nil]];
    [label runAction:[CCSequence actions:
                      scale,
                      delay,
                      [CCCallBlockN actionWithBlock:^(CCNode* node){
     [[OALSimpleAudio sharedInstance] playEffect:@"go0.caf"];
      [node.parent addChild:go];
      [self.gameTimer play];
      self.state = SPGameStateMatch;
      self.music.volume = 0.5;
    }],
                      suicide,
                      nil]];
   } 
}

- (void)onGameTimerUpdate:(KWTimer*)timer {
  [self.statusbar setGaugeRate:timer.now / timer.max];
}

- (void)onGameTimerOver:(KWTimer *)timer {
  self.state = SPGameStateSet;
  SPDrawingManager* manager = [SPDrawingManager sharedManager];
  for (SPDrawing* drawing in manager.drawings) {
    [drawing stopCharge];
  }
  [[OALSimpleAudio sharedInstance] playEffect:@"gameset.caf"];
  for (SPPlayer* player in self.players) { 
    CCSprite* label = [CCSprite spriteWithFile:@"gameset.png"];
    label.position = ccp(player.center.x, player.center.y + 60);
    [player addChild:label];
    label.scale = 0.0;
    [label runAction:[CCSequence actions:
                      [CCScaleTo actionWithDuration:0.2 scale:1.0],
                      [CCDelayTime actionWithDuration:2.8],
                      [CCCallBlockN actionWithBlock:^(CCNode* node) {
      [node.parent removeChild:node cleanup:YES];
    }],
                      nil]];
  }
  [self scheduleOnce:@selector(onResult) delay:3];
}

- (void)onResult {
  SPPlayer* winner = [self checkWinner];
  for (SPPlayer* player in self.players) { 
    NSString* filename = @"lose";
    if (!winner) {
      filename = @"draw";
    } else {
      [statusbar setEnableCrystal:winner.identifier enable:YES];
      if (player.identifier == winner.identifier) {
        filename = @"win";
        player.win += 1;
      }
    }
    CCSprite* label = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", filename]];
    label.position = ccp(player.center.x, player.center.y + 60);
    [player addChild:label];
  }
  SPPlayer* player0 = [self.players objectAtIndex:0];
  SPPlayer* player1 = [self.players objectAtIndex:1];
  [self.statusbar setBadge:player0.win player1:player1.win];
  if (player0.win == 2 || player1.win == 2) {
    [self.music stop];
    music = [KWLoopAudioTrack trackWithIntro:@"result_intro.caf" loop:@"result_loop.caf"];
    self.state = SPGameStateEnd;
    __block CCDirector* director = [CCDirector sharedDirector];
    CCMenuItemImage* restart = [CCMenuItemImage itemFromNormalImage:@"restart.png" 
                                                      selectedImage:@"restart_selected.png" 
                                                      disabledImage:@"restart_selected.png" 
                                                              block:^(id sender){
                                                                [director replaceScene:[SPMainLayer nodeWithScene]];
                                                              }];
    CCMenuItemImage* title = [CCMenuItemImage itemFromNormalImage:@"title.png" 
                                                    selectedImage:@"title_selected.png" 
                                                    disabledImage:@"title_selected.png" 
                                                            block:^(id sender){
                                                            }];
    CCMenu* menu = [CCMenu menuWithItems:restart, title, nil];
    [menu alignItemsHorizontallyWithPadding:30];
    menu.position = ccp(player0.center.x, player0.center.y - 60);
    [[OALSimpleAudio sharedInstance] playEffect:@"fanfare1.caf"];
    __block SPMainLayer* layer = self;
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3.0f],
                     [CCCallBlockN actionWithBlock:^(CCNode* node){
      [layer.music play];
      [layer addChild:menu];
    }], 
                     nil]];
  } else {
    self.state = SPGameStateResult;
    [[OALSimpleAudio sharedInstance] playEffect:@"fanfare0.caf"];
     self.music.volume = 0.25;
  }
  [self.gameTimer stop];
  [self.itemTimer stop];
}

- (void)disableCurrentDrawing:(NSSet*)touches {
  for (UITouch* touch in touches) {
      for (SPPlayer* player in self.players) {
        if ([player.lastTouch isEqual:touch]) {
          player.lastTouch = nil;
          [[SPDrawingManager sharedManager] removeDrawing:player.lastDrawing];
        }
      }
  }
}

@end
