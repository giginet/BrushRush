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
- (SPPlayer*)checkWinner;
- (void)onGameTimerUpdate:(KWTimer*)timer;
- (void)onGameTimerOver:(KWTimer*)timer;
- (void)onResult;
@end

@implementation SPMainLayer
@dynamic drawings;
@synthesize players;
@synthesize statusbar;
@synthesize gameTimer;

- (id)init {
  self = [super init];
  if (self) {
    players = [NSMutableArray array];
    self.isTouchEnabled = YES;
    CCDirector* director = [CCDirector sharedDirector];
    for (int i = 0; i < 2; ++i) {
      CCSprite* sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"player%d.png", i]];
      sprite.position = ccp(director.screenCenter.x, (FRAME_SIZE + PLAYER_HEIGHT + STATUSBAR_HEIGHT) * i + (FRAME_SIZE + PLAYER_HEIGHT) / 2);
      [self addChild:sprite];
    }
    statusbar = [SPStatusBar spriteWithFile:@"status.png"];
    [self addChild:statusbar];
    for (int i = 0; i < 2; ++i) {
      SPPlayer* player = [[SPPlayer alloc] initWithId:i];
      [self.players addObject:player];
      [self addChild:player];
    }
   
    gameTimer = [KWTimer timerWithMax:GAME_TIME];
    [gameTimer setOnUpdateListener:self selector:@selector(onGameTimerUpdate:)];
    [gameTimer setOnCompleteListener:self selector:@selector(onGameTimerOver:)];
    [gameTimer play];
  }
  return self;
}

- (void)onEnter {
  [super onEnter];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch* touch in touches) {
    CGPoint point = [self convertTouchToNodeSpace:touch];
    for (SPPlayer* player in self.players) {
      if (!player.lastTouch && [player containsPoint:point]) {
        player.lastTouch = touch;
        SPDrawing* drawing = [[SPDrawing alloc] init];
        [[SPDrawingManager sharedManager] addDrawing:drawing];
        drawing.color = player.color;
        drawing.player = player;
        [drawing addPoint:[player convertToNodeSpace:point]];
      }
    }
  }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch* touch in touches) {
    CGPoint point = [self convertTouchToNodeSpace:touch];
    for (SPPlayer* player in self.players) {
      if ([player.lastTouch isEqual:touch]) {
        SPDrawing* drawing = [player.drawings lastObject];
        [drawing addPoint:[player convertToNodeSpace:point]];
      }
    }
  }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
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
          for (SPDrawing* other in [NSArray arrayWithArray:self.drawings]) {
            if ([other canCuttingBy:lastDrawing]) {
              NSLog(@"cut");
              [manager removeDrawing:other];
            }
          }
          [manager removeDrawing:lastDrawing];
        }
        player.lastTouch = nil;
        //NSLog(@"%f x %f, %f, %f", player.lastDrawing.boundingBox.size.width, player.lastDrawing.boundingBox.size.height, player.lastDrawing.boundingBox.origin.x, player.lastDrawing.boundingBox.origin.y);
      }
    }
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

- (void)onGameTimerUpdate:(KWTimer*)timer {
  [self.statusbar setGaugeRate:timer.now / timer.max];
}

- (void)onGameTimerOver:(KWTimer *)timer {
  for (int i = 0; i < 2; ++i) { 
    SPPlayer* player = [self.players objectAtIndex:i];
    CCLabelTTF* label = [CCLabelTTF labelWithString:@"Game Set" fontName:@"Helvetica" fontSize:96];
    label.position = ccp(player.center.x, player.center.y + 60);
    [player addChild:label];
  }
}

- (void)onResult {
}

@end
