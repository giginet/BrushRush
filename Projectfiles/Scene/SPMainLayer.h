//
//  SPMainLayer.h
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "KWLayer.h"
#import "heqet.h"
#import "SPStatusBar.h"
#import "KWLoopAudioTrack.h"

typedef enum {
  SPGameStateReady,
  SPGameStateMatch,
  SPGameStateSet,
  SPGameStateResult,
  SPGameStateEnd
} SPGameState;

@interface SPMainLayer : CCLayer {
  int gameCount_;
}

@property(readwrite) SPGameState state;
@property(readonly, strong) NSArray* drawings;
@property(readonly, strong) NSMutableArray* players;
@property(readonly, strong) SPStatusBar* statusbar;
@property(readonly, strong) KWTimer* gameTimer;
@property(readonly, strong) KWTimer* itemTimer;
@property(readonly, strong) KWLoopAudioTrack* music;

@end
