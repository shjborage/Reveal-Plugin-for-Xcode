//
//  RevealIDEModel.m
//  RevealPlugin
//
//  Created by shjborage on 4/4/14.
//  Copyright (c) 2014 Saick. All rights reserved.
//

#import "RevealIDEModel.h"
#import <objc/message.h>
#import "NSView+SQDump.h"
#import "NSView+SQFindSubView.h"

@implementation RevealIDEModel

+ (IDEWorkspaceTabController *)workspaceControllerIn
{
  NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
  if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
    IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)currentWindowController;
    
    return workspaceController.activeWorkspaceTabController;
  }
  return nil;
}

//+ (void)activeIDEWindow
//{
//  NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
//  if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
//    IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)currentWindowController;
//    
//    IDEWorkspaceTabController *activeTabController = workspaceController.activeWorkspaceTabController;
//    [activeTabController performSelectorOnMainThread:@selector(runActiveRunContext:) withObject:nil waitUntilDone:NO];
//  }
//}

+ (DBGDebugSession *)debugSessionIn
{
  IDEWorkspaceTabController *tabController = [self workspaceControllerIn];
  
  if (![tabController respondsToSelector:@selector(debugSessionController)]) {
    return nil;
  } else {
    DBGDebugSessionController *debugSessionController = objc_msgSend(tabController, @selector(debugSessionController));
    if ([debugSessionController respondsToSelector:@selector(debugSession)]) {
      id debugSession = objc_msgSend(debugSessionController, @selector(debugSession));
      if ([NSStringFromClass([debugSession class]) isEqualToString:@"DBGLLDBSession"]) {
        return debugSession;
      } else {
        return nil;
      }
    } else {
      return nil;
    }
  }
}

+ (IDEConsoleTextView *)whenXcodeConsoleIn
{
//  [[[NSApp mainWindow] contentView] dumpWithIndent:@""];
  NSView *consoleView = [[[NSApp mainWindow] contentView] findSubView:NSClassFromString(@"IDEConsoleTextView")];
  
  if (consoleView == nil) {
    // TODO: View->Debug Area->Active Console to get the IDEConsoleTextView
  }
  return (IDEConsoleTextView *)consoleView;
}

@end
