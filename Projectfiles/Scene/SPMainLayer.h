//
//  SPMainLayer.h
//  Spring
//
//  Created by  on 2012/6/6.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "KWLayer.h"
#import "heqet.h"
#import "SPStatusBar.h"

@interface SPMainLayer : CCLayer {
}

@property(readonly, strong) NSArray* drawings;
@property(readonly, strong) NSMutableArray* players;
@property(readonly) SPStatusBar* statusbar;
@property(readonly) KWTimer* gameTimer;

@end
