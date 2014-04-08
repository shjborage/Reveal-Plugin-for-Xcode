//
//  RevealIDEModel.h
//  RevealPlugin
//
//  Created by shjborage on 4/4/14.
//  Copyright (c) 2014 Saick. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IDEConsoleTextView;

@interface DBGDebugSession : NSObject

- (void)requestStop;
- (void)requestPause;
- (void)requestContinue;

@end

@interface DBGDebugSessionController : NSObject

@property (readonly) DBGDebugSession *debugSession;

@end


@interface IDENavigatorArea : NSObject

@property NSArrayController *extensionsController;
- (id)currentNavigator;

@end


@interface IDEWorkspaceTabController : NSObject

@property (readonly) IDENavigatorArea *navigatorArea;
@property(readonly) IDEWorkspaceTabController *structureEditWorkspaceTabController;

- (void)runActiveRunContext:(id)arg1;

@end


@interface IDEWorkspaceWindowController : NSObject

@property (readonly) IDEWorkspaceTabController *activeWorkspaceTabController;
@property (readonly) DBGDebugSessionController *debugSessionController;

@end

#pragma mark - Reveal IDE Tools

@interface RevealIDEModel : NSObject

+ (IDEWorkspaceTabController *)workspaceControllerIn;

//+ (void)activeIDEWindow;

+ (DBGDebugSession *)debugSessionIn;

+ (IDEConsoleTextView *)whenXcodeConsoleIn;

@end
