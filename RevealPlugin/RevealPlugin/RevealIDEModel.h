//
//  RevealIDEModel.h
//  RevealPlugin
//
//  Created by shjborage on 4/4/14.
//  Copyright (c) 2014 Saick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDENavigatorArea : NSObject

@property NSArrayController *extensionsController;
- (id)currentNavigator;

@end

@interface IDEWorkspaceTabController : NSObject

@property (readonly) IDENavigatorArea *navigatorArea;
@property(readonly) IDEWorkspaceTabController *structureEditWorkspaceTabController;

@end

@interface IDEWorkspaceWindowController : NSObject

@property (readonly) IDEWorkspaceTabController *activeWorkspaceTabController;

@end


#pragma mark - Reveal IDE Tools

@interface RevealIDEModel : NSObject

+ (IDEWorkspaceTabController *)workspaceControllerIn;

@end
