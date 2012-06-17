//
//  SPStatusBar.h
//  Spring
//
//  Created by  on 2012/6/18.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "CCSprite.h"

@interface SPStatusBar : CCSprite {
  NSMutableArray* timeGauges_;
  NSMutableArray* crystals_;
  NSMutableArray* badges_;
}

- (void)setGaugeRate:(float)rate;
- (void)setEnableCrystal:(NSUInteger)number enable:(BOOL)enable;
- (void)setBadge:(NSUInteger)player0 player1:(NSUInteger)player1;
- (void)reset;

@end
