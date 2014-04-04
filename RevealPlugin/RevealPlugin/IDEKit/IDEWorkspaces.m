//
//  IDEWorkspaceWindowController.m
//  RevealPlugin
//
//  Created by shjborage on 4/4/14.
//  Copyright (c) 2014 Saick. All rights reserved.
//

#import "IDEWorkspaces.h"

@implementation RevealTool

+ (IDEWorkspaceTabController *)workspaceControllerIn
{
  NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
  if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
    IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)currentWindowController;
    
    return workspaceController.activeWorkspaceTabController;
  }
  return nil;
}

@end