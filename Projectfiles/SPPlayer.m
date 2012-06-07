//
//  SPPlayer.m
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPPlayer.h"
#import "SPDrawingManager.h"

@implementation SPPlayer
@synthesize identifier;
@dynamic color;
@synthesize drawings;
@synthesize lastTouch;

static NSMutableDictionary* players_;

+ (id)playerById:(NSUInteger)n {
  if (!players_ || [players_ objectForKey:[NSNumber numberWithInt:n]]) {
    return [[[self class] alloc] initWithId:n];
  }
  return [players_ objectForKey:[NSNumber numberWithInt:n]];
}

- (id)initWithId:(NSUInteger)n {
  CCDirector* director = [CCDirector sharedDirector];
  self = [super initWithColor:ccc4(239 + 16 * n, 229 + 16 * (1 - n), 255, 255) 
                        width:director.screenSize.width 
                       height:director.screenSize.height / 2];
  if (self) {
    if (!players_) {
      players_ = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    self.rotation = 180 * n;
    identifier = n;
    drawings = [NSMutableArray array];
    [players_ setObject:self forKey:[NSNumber numberWithInt:n]];
    self.position = ccp(0, director.screenSize.height / 2 * n);
  }
  return self;
}

- (ccColor3B)color {
  return ccc3(255 * self.identifier, 0, 255 * (1 - self.identifier));
}

- (void)draw {
  [super draw];
  SPDrawingManager* manager = [SPDrawingManager sharedManager];
  for (SPDrawing* drawing in manager.drawings) {
    [drawing draw];
  }
}

@end
