//
//  SPItem.h
//  Spring
//
//  Created by  on 6/21/12.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "Heqet.h"
#import "CCSprite.h"
#import "SPPlayer.h"

typedef enum {
  SPItemKindAccel,
  SPItemKindBlind,
  SPItemKindBrake,
  SPItemKindPaint,
  SPItemKindSnatch,
  SPItemKindNum
} SPItemKind;

@interface SPItem : CCSprite {
  OALAudioTrack* blindSound_;
}

@property(readwrite) SPItemKind kind;
@property(readonly, strong) NSString* name;
@property(readonly, strong) KWTimer* changeTimer;
@property(readonly, strong) KWTimer* useTimer;
@property(readonly, strong) KWVector* velocity;
@property(readwrite, weak) SPPlayer* player;

+ (SPItem*)item;
- (id)initWithKind:(SPItemKind)k;
- (SPItemKind)changeRandom;
- (void)update:(ccTime)time;
- (void)useBy:(SPPlayer*)player;

@end
