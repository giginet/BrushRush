//
//  CCTexture2D+DrawInPoly.m
//  Spring
//
//  Created by  on 2012/6/11.
//  Copyright (c) 2012 Kawaz. All rights reserved.
//

#import "CCTexture2D+DrawInPoly.h"

@implementation CCTexture2D (DrawInPoly)

- (void) drawInPoly:(CGPoint *)poli numberOfPoints:(NSUInteger)number boundingBox:(CGRect)boundingBox {
  CGPoint coordinates[number];
  int w = ceil(boundingBox.size.width / self.contentSize.width);
  int h = ceil(boundingBox.size.height / self.contentSize.height);
  for (int i = 0; i < (int)number; ++i) {
    CGPoint coordinate = ccpSub(poli[i], boundingBox.origin);
    coordinate.x = w - (coordinate.x / boundingBox.size.width * w);
    coordinate.y = h - (coordinate.y / boundingBox.size.height * h);
    coordinates[i] = coordinate;
  }
  
  glBindTexture(GL_TEXTURE_2D, name_);
  
  // Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
  // Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_TEXTURE_COORD_ARRAY
  // Unneeded states: GL_COLOR_ARRAY
  /*glDisableClientState(GL_COLOR_ARRAY);
  
  glVertexPointer(2, GL_FLOAT, 0, vertices);
  glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  
  // restore state
  glEnableClientState(GL_COLOR_ARRAY);
  
  */
  glDisableClientState(GL_COLOR_ARRAY);
  //glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
  glVertexPointer(2, GL_FLOAT, 0, poli);
  glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  
  glDrawArrays(GL_TRIANGLE_FAN, 0, number);

  glEnableClientState(GL_COLOR_ARRAY);
}

@end