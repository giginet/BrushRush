//
//  SPPlayer.m
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPPlayer.h"
#import "SPItem.h"
#import "SPDrawingManager.h"
#import "define.h"
#import "ObjectAL.h"

@implementation SPPlayer
@synthesize win;
@synthesize identifier;
@dynamic color;
@synthesize drawings;
@synthesize lastTouch;
@dynamic lastDrawing;
@synthesize frame;
@synthesize item;

static NSMutableDictionary* players_;


+ (id)playerById:(NSUInteger)n {
  if (!players_ || [players_ objectForKey:[NSNumber numberWithInt:n]]) {
    return [[[self class] alloc] initWithId:n];
  }
  return [players_ objectForKey:[NSNumber numberWithInt:n]];
}

- (id)initWithId:(NSUInteger)n {
  self = [super initWithColor:ccc4(0, 0, 0, 0) 
                        width:PLAYER_WIDTH 
                       height:PLAYER_HEIGHT];
  if (self) {
    if (!players_) {
      players_ = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    self.rotation = 180 * n;
    win = 0;
    identifier = n;
    drawings = [NSMutableArray array];
    [players_ setObject:self forKey:[NSNumber numberWithInt:n]];
    int y = self.identifier == 0 ? FRAME_SIZE : FRAME_SIZE + PLAYER_HEIGHT + STATUSBAR_HEIGHT;
    self.position = ccp(FRAME_SIZE, y);
  }
  return self;
}

- (ccColor3B)color {
  return ccc3(255 * (1 - self.identifier), 0, 255 * self.identifier);
}

- (void)draw {
  [super draw];
  SPDrawingManager* manager = [SPDrawingManager sharedManager];
  for (SPDrawing* drawing in manager.drawings) {
    if (!(self.identifier != drawing.player.identifier && drawing.type == SPDrawingTypeWriting)) {
      [drawing draw];
    }
  }
  glColor4f(1, 1, 1, 1);
  for (SPItem* i in manager.items) {
    [i.texture drawAtPoint:i.position];
  }
}

- (SPDrawing*)lastDrawing {
  return [self.drawings lastObject];
}

- (CGPoint)center {
  return ccp(self.contentSize.width / 2, self.contentSize.height / 2);
}

- (void)getItem:(SPItem *)i {
  [[OALSimpleAudio sharedInstance] playEffect:@"item.caf"];
  [i useBy:self];
  self.item = i;
  item.owner = self;
  SPDrawingManager* manager = [SPDrawingManager sharedManager];
  [manager removeItem:i];
}

- (SPItem*)item {
  return item;
}

- (void)setItem:(SPItem *)i {
  item = i;
  [self.frame stopAllActions];
  if (i) {
    NSLog(@"%@", self.frame);
    [self.frame runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                                                             [CCFadeTo actionWithDuration:0.1 opacity:64],
                                                             [CCFadeTo actionWithDuration:0.1 opacity:255],
                                                             nil]]];
  }
}

@end
