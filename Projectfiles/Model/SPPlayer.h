//
//  SPPlayer.h
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "heqet.h"

@class SPDrawing;
@class SPItem;

typedef enum {
  SPPlayerLayerMain,
  SPPlayerLayerEffect,
  SPPlayerLayerBlind,
  SPPlayerLayerUI
} SPPlayerLayer;

@interface SPPlayer : CCLayerColor {
}

@property(readwrite) NSUInteger win;
@property(readonly) NSUInteger identifier;
@property(readonly, strong) NSMutableArray* drawings;
@property(readwrite, strong) UITouch* lastTouch;
@property(readonly, strong) SPDrawing* lastDrawing;
@property(readwrite, strong) CCSprite* frame;
@property(readwrite, strong) SPItem* item;
@property(readwrite, weak) SPDrawing* lastArea;
@property(readonly) OALAudioTrack* writingSound;
@property(readonly) OALAudioTrack* chargeSound;

+ (id)playerById:(NSUInteger)n;
- (id)initWithId:(NSUInteger)n;
- (CGPoint)center;
- (void)getItem:(SPItem*)item;
- (void)resetPlayerStatus;

@end
