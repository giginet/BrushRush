//
//  CCToggleSprite.m
//  Spring
//
//  Created by  on 2012/6/18.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "CCToggleSprite.h"

@implementation CCToggleSprite
@synthesize toggle;
@synthesize format;

- (id)initWithFormat:(NSString *)f {
  NSString* filename = [NSString stringWithFormat:f, @"disable"];
  self = [super initWithFile:filename];
  if (self) {
    toggle = NO;
    format = f;
  }
  return self;
}

- (BOOL)toggle {
  return toggle;
}

- (void)setToggle:(BOOL)t {
  toggle = t;
  [self setTexture:  [[CCTextureCache sharedTextureCache] 
                      addImage:[NSString stringWithFormat:self.format, self.toggle ? @"enable" : @"disable"]]];
}

@end
