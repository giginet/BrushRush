//
//  SPPlayer.m
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPPlayer.h"

@implementation SPPlayer
@synthesize identifier;
@synthesize drawings;

static NSMutableDictionary* players_;

+ (id)playerById:(NSUInteger)n {
  if (!players_ || [players_ objectForKey:[NSNumber numberWithInt:n]]) {
    return [[[self class] alloc] initWithId:n];
  }
  return [players_ objectForKey:[NSNumber numberWithInt:n]];
}

- (id)initWithId:(NSUInteger)n {
  self = [super init];
  if (self) {
    if (!players_) {
      players_ = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    identifier = n;
    drawings = [NSMutableArray array];
    [players_ setObject:self forKey:[NSNumber numberWithInt:n]];
  }
  return self;
}

@end
