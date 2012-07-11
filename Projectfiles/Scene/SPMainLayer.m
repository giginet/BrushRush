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
#import "SPTitleLayer.h"
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
    [[SPDrawingManager sharedManager] removeAllDrawings];
    [[SPDrawingManager sharedManager] removeAllItems];
    gameCount_ = 0;
  }
  return self;
}

- (void)onEnterTransitionDidFinish {
  [[CCTextureCache sharedTextureCache] removeUnusedTextures];
  [super onEnterTransitionDidFinish];
  [self.music play];
  [self startGame];
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
          CGRect box = CGRectMake(item.position.x - item.texture.contentSize.width / 2, 
                                  item.position.y - item.texture.contentSize.height / 2, 
                                  item.texture.contentSize.width * 2, 
                                  item.texture.contentSize.height * 2);
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
          player.lastDrawing = drawing;
        }
      }
    }
  }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.state == SPGameStateMatch) {
    for (SPPlayer* player in self.players) {
      if (!player.lastTouch) continue;
      if ([touches containsObject:player.lastTouch]) {
        CGPoint point = [self convertTouchToNodeSpace:player.lastTouch];
        SPPlayer* enemy = [SPPlayer playerById:(player.identifier + 1) % 2];
        CGRect enemyRect = CGRectMake(enemy.position.x, enemy.position.y, PLAYER_WIDTH, PLAYER_HEIGHT);
        if (CGRectContainsPoint(enemyRect, point)) {
          [self disableCurrentDrawing:touches];
        }
        SPDrawing* drawing = [player lastDrawing];
        if (WRITING_SOUND && drawing && !player.writingSound.playing) {
          [player.writingSound play];
         }
        if (drawing.length < 3000) {
          [drawing addPoint:[player convertToNodeSpace:point]];
        } else {
          [self disableCurrentDrawing:touches];
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
    for (SPPlayer* player in self.players) {
      if (!player.lastTouch) continue;
      if ([touches containsObject:player.lastTouch]) {
        SPDrawing* lastDrawing = player.lastDrawing;
        SPDrawingType detectedType = [lastDrawing detectType];
        if (detectedType == SPDrawingTypeCharge) {
          lastDrawing.type = SPDrawingTypeCharge;
          [lastDrawing fire];
        } else if (detectedType == SPDrawingTypeSlash) {
          lastDrawing.type = SPDrawingTypeSlash;
          [[OALSimpleAudio sharedInstance] playEffect:@"slash.caf"];
          for (SPDrawing* other in [NSArray arrayWithArray:self.drawings]) {
            if ([other canCuttingBy:lastDrawing]) {
              [[OALSimpleAudio sharedInstance] playEffect:@"break.caf"];
              
              float fps = 1.0 / [[KKStartupConfig config] maxFrameRate];
              int width = contentSize_.width;
              float scale = other.boundingBox.size.width / width;
              for (SPPlayer* p in self.players) {
                CCSprite* cutEffect = [CCSprite spriteWithFile:[NSString stringWithFormat:@"break%d_0.png", other.player.identifier]];
                cutEffect.scale = scale * 4;
                CCAnimation* animation = [CCAnimation animationWithFiles:[NSString stringWithFormat:@"break%d_", other.player.identifier] frameCount:7 delay:fps * 4];
                [cutEffect runAction:[CCSequence actions:
                                      [CCAnimate actionWithAnimation:animation],
                                      [CCSuicide action],
                                      nil]];
                cutEffect.position = other.gravityPoint;
                CCParticleSystemQuad* slashEffect = [CCParticleSystemQuad particleWithFile:@"cut.plist"];
                slashEffect.position = other.gravityPoint;
                slashEffect.rotation = -1 * ((int)(player.lastDrawing.angle + 360) % 360 + 180);
                slashEffect.scaleX = -1;
                [p addChild:cutEffect z:SPPlayerLayerEffect];
                [p addChild:slashEffect];
              }
              [other removeFromStage];
            }
          }
          [manager removeDrawing:lastDrawing];
        } else if (detectedType == SPDrawingTypeNone) {
          [manager removeDrawing:lastDrawing];
        }
        player.lastTouch = nil;
        player.lastDrawing = nil;
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
      if (!player.lastTouch) continue;
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
     if (player.identifier == 0) {
       [[OALSimpleAudio sharedInstance] playEffect:[NSString stringWithFormat:@"ready%d.caf", gameCount_ % 2]];
     }
     label.position = ccp(player.center.x, player.center.y + 60);
    [player addChild:label];
     __block CCSprite* go = [CCSprite spriteWithFile:@"go.png"];
     id scale = [CCScaleTo actionWithDuration:0.2 scale:1.0];
     id delay = [CCDelayTime actionWithDuration:1.8];
     id suicide = [CCSuicide action];
     label.scale = 0.0;
     go.position = label.position;
     go.scale = 0.0;
     __block int identifier = player.identifier;
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
      if (identifier == 0) {
        [[OALSimpleAudio sharedInstance] playEffect:[NSString stringWithFormat:[NSString stringWithFormat:@"go%d.caf", gameCount_ % 2]]];
      }
      [node.parent addChild:go z:SPPlayerLayerUI];
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
  [[OALSimpleAudio sharedInstance] playEffect:@"gameset0.caf"];
  for (SPPlayer* player in self.players) { 
    CCSprite* label = [CCSprite spriteWithFile:@"gameset.png"];
    label.position = ccp(player.center.x, player.center.y + 60);
    [player addChild:label z:SPPlayerLayerUI];
    label.scale = 0.0;
    [label runAction:[CCSequence actions:
                      [CCScaleTo actionWithDuration:0.2 scale:1.0],
                      [CCDelayTime actionWithDuration:2.8],
                      [CCSuicide action],
                      nil]];
  }
  [self scheduleOnce:@selector(onResult) delay:3];
}

- (void)onResult {
  ++gameCount_;
  [[CCTextureCache sharedTextureCache] removeUnusedTextures];
  SPPlayer* winner = [self checkWinner];
  NSMutableArray* labels = [NSMutableArray array];
  for (SPPlayer* player in self.players) { 
    [player resetPlayerStatus];
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
    __block CCSprite* label = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", filename]];
    label.position = ccp(player.center.x, player.center.y + 60);
    [player addChild:label z:SPPlayerLayerUI];
    [labels addObject:label];
  }
  SPPlayer* player0 = [self.players objectAtIndex:0];
  SPPlayer* player1 = [self.players objectAtIndex:1];
  [self.statusbar setBadge:player0.win player1:player1.win];
  if (player0.win == 2 || player1.win == 2) {
    [self.music stop];
    music = [KWLoopAudioTrack trackWithIntro:@"result_intro.caf" loop:@"result_loop.caf"];
    self.state = SPGameStateEnd;
    __block CCDirector* director = [CCDirector sharedDirector];
    CCSprite* sign = [CCSprite spriteWithFile:@"sign.png"];
    sign.position = ccp(director.screenCenter.x, 130);
    CCMenuItemImage* restart = [CCMenuItemImage itemFromNormalImage:@"restart.png" 
                                                      selectedImage:@"restart_selected.png" 
                                                      disabledImage:@"restart_selected.png" 
                                                              block:^(id sender){
                                                                [[OALSimpleAudio sharedInstance] playEffect:@"decide.caf"];
                                                                CCTransitionFade* transition = [CCTransitionFade transitionWithDuration:1.0 scene:[SPMainLayer nodeWithScene]];
                                                                [director replaceScene:transition];
                                                              }];
    CCMenuItemImage* title = [CCMenuItemImage itemFromNormalImage:@"title.png" 
                                                    selectedImage:@"title_selected.png" 
                                                    disabledImage:@"title_selected.png" 
                                                            block:^(id sender){
                                                              [[OALSimpleAudio sharedInstance] playEffect:@"decide.caf"];
                                                              CCTransitionFade* transition = [CCTransitionFade transitionWithDuration:1.0 scene:[SPTitleLayer nodeWithScene]];
                                                              [director replaceScene:transition];
                                                            }];
    CCMenu* menu = [CCMenu menuWithItems:restart, title, nil];
    [menu alignItemsVerticallyWithPadding:65];
    menu.position = ccp(sign.position.x, self.position.y + 170);
    [[OALSimpleAudio sharedInstance] playEffect:@"fanfare1.caf"];
    __block SPMainLayer* layer = self;
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:5.0f],
                     [CCCallBlockN actionWithBlock:^(CCNode* node){
      CCSprite* label = [labels objectAtIndex:0];
      [label runAction:[CCSequence actions:[CCMoveBy actionWithDuration:0.25 position:ccp(0, 75)],
                        [CCCallBlockN actionWithBlock:^(CCNode* node){
        [self addChild:sign z:SPPlayerLayerUI];
        [layer addChild:menu z:SPPlayerLayerUI];
      }], nil]];
      [layer.music play];
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
