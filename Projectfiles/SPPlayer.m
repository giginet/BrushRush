//
//  SPPlayer.m
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPPlayer.h"
#import "SPDrawingManager.h"
#import "define.h"

@implementation SPPlayer
@synthesize identifier;
@dynamic color;
@synthesize drawings;
@synthesize lastTouch;
@dynamic lastDrawing;

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
    [drawing draw];
  }
}

- (SPDrawing*)lastDrawing {
  return [self.drawings lastObject];
}

@end
