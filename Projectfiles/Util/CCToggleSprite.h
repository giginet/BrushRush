//
//  CCToggleSprite.h
//  Spring
//
//  Created by  on 2012/6/18.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "CCSprite.h"

@interface CCToggleSprite : CCSprite

@property(readwrite) BOOL toggle;
@property(readwrite, strong) NSString* format;

- (id)initWithFormat:(NSString*)format;

@end
