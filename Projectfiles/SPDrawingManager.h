//
//  SPDrawingManager.h
//  Spring
//
//  Created by  on 2012/6/7.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPDrawing.h"

@interface SPDrawingManager : NSObject {
  NSMutableArray* drawings_;
}

@property(readonly, strong) NSArray* drawings;

+ (id)sharedManager;

- (void)addDrawing:(SPDrawing*)drawing;
- (void)removeDrawing:(SPDrawing*)drawing;
- (float)areaWithPlayer:(SPPlayer*)player;
- (void)mergeWithIntersectsDrawing:(SPDrawing*)drawing;

@end
