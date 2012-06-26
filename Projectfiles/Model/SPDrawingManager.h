//
//  SPDrawingManager.h
//  Spring
//
//  Created by  on 2012/6/7.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPDrawing.h"
#import "SPItem.h"

@interface SPDrawingManager : NSObject {
  NSMutableArray* drawings_;
  NSMutableArray* items_;
}

@property(readonly, strong) NSArray* drawings;
@property(readonly, strong) NSArray* items;

+ (id)sharedManager;

- (void)addDrawing:(SPDrawing*)drawing;
- (void)removeDrawing:(SPDrawing*)drawing;
- (void)removeAllDrawings;
- (float)areaWithPlayer:(SPPlayer*)player;
- (void)mergeWithIntersectsDrawing:(SPDrawing*)drawing;
- (CCRenderTexture*)renderTextureWithDrawings;
- (void)update:(ccTime)dt;
- (void)addItem:(SPItem*)item;
- (void)removeItem:(SPItem*)item;
- (void)removeAllItems;
- (void)paintAt:(CGPoint)point player:(SPPlayer*)player;

@end
