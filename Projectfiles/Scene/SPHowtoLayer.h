//
//  SPHowtoLayer.h
//  Spring
//
//  Created by  on 2012/7/5.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "CCLayer.h"

@interface SPHowtoLayer : CCLayer {
  BOOL swiped_;
  CCLayerColor* howtoLayer_;
}

@property(readonly) NSUInteger number;

- (id)initWithNumber:(NSUInteger)number;
- (void)update:(ccTime)dt;

@end
