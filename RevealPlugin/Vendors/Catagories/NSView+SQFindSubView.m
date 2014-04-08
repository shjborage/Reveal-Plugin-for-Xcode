//
//  NSView+SQFindSubView.m
//  RevealPlugin
//
//  Created by shjborage on 4/7/14.
//  Copyright (c) 2014 Saick. All rights reserved.
//

#import "NSView+SQFindSubView.h"

@implementation NSView (SQFindSubView)

- (NSView *)findSubView:(Class)cls
{
  if ([[self subviews] count] > 0) {
    for (NSView *subview in [self subviews]) {
//      NSLog(@"%@", NSStringFromClass([subview class]));
      if ([subview isKindOfClass:cls]) {
        return subview;
      } else {
        NSView *foundView = [subview findSubView:cls];
        if (foundView != nil)
          return foundView;
      }
    }
  }
  
  return nil;
}

@end
