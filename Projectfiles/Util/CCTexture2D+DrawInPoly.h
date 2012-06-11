//
//  CCTexture2D+DrawInPoly.h
//  Spring
//
//  Created by  on 2012/6/11.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "CCTexture2D.h"

@interface CCTexture2D (DrawInPoly)

- (void)drawInPoly:(CGPoint*)poli numberOfPoints:(NSUInteger)number boundingBox:(CGRect)boundingBox;

@end
