//
//  IDEBuildTask+RPPlugin.m
//  RevealPlugin
//
//  Created by shjborage on 4/2/14.
//  Copyright (c) 2014 Saick. All rights reserved.
//

#import "IDEBuildTask+RPPlugin.h"
#import "JRSwizzle.h"

@interface IDEBuildTask()

+ (id)buildTaskWithIdentifier:(id)arg1 restorePersistedBuildResults:(BOOL)arg2 properties:(id)arg3;

@end

@implementation IDEBuildTask (RPPlugin)

+ (void)load
{
  NSError *error = nil;
  [self jr_swizzleClassMethod:@selector(buildTaskWithIdentifier:restorePersistedBuildResults:properties:) withClassMethod:@selector(swizzledBuildTaskWithIdentifier:restorePersistedBuildResults:properties:) error:&error];
  
  if (error)
    NSLog(@"Swizzle buildTaskWithIdentifier error:(%@) in IDEBuildTaskPlugin:", error);
}

+ (id)swizzledBuildTaskWithIdentifier:(id)arg1 restorePersistedBuildResults:(BOOL)arg2 properties:(id)arg3
{
  NSLog(@"swizzledBuildTaskWithIdentifier");
  
  return [self swizzledBuildTaskWithIdentifier:arg1 restorePersistedBuildResults:arg2 properties:arg3];
}

@end
