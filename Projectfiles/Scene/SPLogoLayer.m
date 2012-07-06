//
//  SPLogoLayer.m
//  Spring
//
//  Created by  on 2012/7/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "SPLogoLayer.h"
#import "SPTitleLayer.h"

@implementation SPLogoLayer

- (id)init {
  return [super initWithNext:[SPTitleLayer class]];
}

@end
