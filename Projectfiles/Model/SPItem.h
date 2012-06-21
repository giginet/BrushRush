//
//  SPItem.h
//  Spring
//
//  Created by  on 6/21/12.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "Heqet.h"
#import "CCSprite.h"

typedef enum {
  SPItemKindAccel,
  SPItemKindBlind,
  SPItemKindBrake,
  SPItemKindPaint,
  SPItemKindSnatch,
  SPItemKindNum
} SPItemKind;

@interface SPItem : CCSprite

@property(readwrite) SPItemKind kind;
@property(readonly, strong) NSString* name;
@property(readonly, strong) KWTimer* changeTimer;
@property(readonly, strong) KWVector* velocity;

+ (SPItem*)item;
- (id)initWithKind:(SPItemKind)k;
- (SPItemKind)changeRandom;
- (void)update:(ccTime)time;

@end
