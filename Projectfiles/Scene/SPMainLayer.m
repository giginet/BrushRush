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

@interface SPMainLayer()
- (SPPlayer*)checkWinner;
@end

@implementation SPMainLayer
@dynamic drawings;
@synthesize players;

- (id)init {
  self = [super init];
  if (self) {
    players = [NSMutableArray array];
    self.isTouchEnabled = YES;
    CCDirector* director = [CCDirector sharedDirector];
    CCSprite* background = [CCSprite spriteWithFile:@"ipadimage.png"];
    background.position = director.screenCenter;
    [self addChild:background];
    for (int i = 0; i < 2; ++i) {
      SPPlayer* player = [[SPPlayer alloc] initWithId:i];
      [self.players addObject:player];
      [self addChild:player];
    }
    __block SPMainLayer* layer = self;
    CCMenuItem* button = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Check" fontName:@"Helvetica" fontSize:24] 
                                                  block:^(id sender){
                                                    SPPlayer* player = [layer checkWinner];
                                                    if (player) {
                                                      NSLog(@"%d Win", player.identifier);
                                                    } else {
                                                      NSLog(@"Draw");
                                                    }
                                                  }];
    CCMenu* menu = [CCMenu menuWithItems:button, nil];
    menu.position = director.screenCenter;
    [self addChild:menu];
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
          lastDrawing.type = SPDrawingTypeCount;
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
      if (b == 255) {
        player0 += 1;
      } else if (r == 255) {
        player1 += 1;
      }
    }
  }
  NSLog(@"blue = %d, red = %d", player0, player1);
  if (player0 > player1) {
    return [self.players objectAtIndex:0];
  } else if(player0 < player1) {
    return [self.players objectAtIndex:1];
  }
  return nil;
}

@end
