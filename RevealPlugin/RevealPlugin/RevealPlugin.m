//
//  RevealPlugin.m
//  RevealPlugin
//
//  Created by shjborage on 3/27/14.
//  Copyright (c) 2014 Saick. All rights reserved.
//

#import "RevealPlugin.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "BuildScriptHeader.h"

@interface RevealPlugin ()

@end

@implementation RevealPlugin

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
  NSLog(@"Reveal plugin DidLoaded");
  NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
  if ([currentApplicationName isEqual:@"Xcode"]) {
    [self shared];
  }
}

+ (id)shared
{
  static dispatch_once_t onceToken;
  static id instance = nil;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (id)init
{
  if (self = [super init]) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidFinishLaunching:)
                                                 name:NSApplicationDidFinishLaunchingNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observeAllNotification:)
                                                 name:nil
                                               object:nil];
  }
  return self;
}

#pragma mark - notif

- (void)applicationDidFinishLaunching:(NSNotification *)notif
{
//  [[NSNotificationCenter defaultCenter] addObserver:self
//                                           selector:@selector(selectionDidChange:)
//                                               name:NSTextViewDidChangeSelectionNotification
//                                             object:nil];

  NSMenuItem *productMenuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
  if (productMenuItem) {
    NSMenu *menu = [productMenuItem submenu];
    NSMenuItem *analyzeItem = [productMenuItem.submenu itemWithTitle:@"Analyze"];
    NSInteger revealIndex = [menu indexOfItem:analyzeItem] + 1;

//    [[productMenuItem submenu] addItem:[NSMenuItem separatorItem]];
    NSMenuItem *revealItem = [[NSMenuItem alloc] initWithTitle:@"Inspect with RevealApp"
                                                        action:@selector(didPressRevealInspectProductMenu:)
                                                 keyEquivalent:@"p"];
    [revealItem setTarget:self];
    [revealItem setKeyEquivalentModifierMask:NSControlKeyMask|NSCommandKeyMask];
    [[productMenuItem submenu] insertItem:revealItem atIndex:revealIndex];
  }

  NSMenuItem *debugMenuItem = [[NSApp mainMenu] itemWithTitle:@"Debug"];
  if (debugMenuItem) {
    //    [[productMenuItem submenu] addItem:[NSMenuItem separatorItem]];
    NSMenuItem *revealItem = [[NSMenuItem alloc] initWithTitle:@"Attach to RevealApp"
                                                        action:@selector(didPressRevealInspectDebugMenu:)
                                                 keyEquivalent:@";"];
    [revealItem setTarget:self];
    [revealItem setKeyEquivalentModifierMask:NSControlKeyMask|NSCommandKeyMask];
    [[debugMenuItem submenu] addItem:revealItem];
  }
}

- (void)observeAllNotification:(NSNotification *)notif
{
  // Log notifications if you like
  if ([[notif name] length] >= 2 && ([[[notif name] substringWithRange:NSMakeRange(0, 2)] isEqualTo:@"NS"] || [[[notif name] substringWithRange:NSMakeRange(0, 2)] isEqualTo:@"_N"])) {
    // It's a system-level notification
  } else {
    // It's a Xcode-level notification
    NSLog(@"%@", notif.name);
  }
  
  // This seems like quite a mess, but the notification-driven approach avoids waiting for
  // indeterminate amounts of time for building / running to get far enough along to avoid crashes.
  
  // Finished building
  if ([[notif name] isEqualToString:@"IDEBuildOperationDidGenerateOutputFilesNotification"]) {
    
  }
  
  // Finished launching
  if ([[notif name] isEqualToString:@"DVTDeviceShouldIgnoreChangesDidEndNotification"]) {
    
  }
  
  // Finished stopping
  if ([[notif name] isEqualToString:@"CurrentExecutionTrackerCompletedNotification"]) {
    
  }
}

//- (void)selectionDidChange:(NSNotification *)notif
//{
//  NSLog(@"Reveal selectionDidChange:%@", notif);
//}

#pragma mark - actions

/*!
 @brief click Reveal Inspect Menu Action
 
 // 0 step is only used for debug
 // 0. User already run the project (otherwise, alert an error)
 1. enter `lldb`, and attach process (if error occured, process not found)
 2. lldb operation pause and other command
 */
- (void)didPressRevealInspectProductMenu:(NSMenuItem *)sender
{
  NSLog(@"Reveal didPressRevealInspectProductMenu:%@", sender);

  NSMenuItem *productMenuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
  if (productMenuItem) {
    NSMenuItem *runItem = [productMenuItem.submenu itemWithTitle:@"Run"];
    [self performActionForMenuItem:runItem];
  }
  
  // start applescript
//  NSString *scriptPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"rp.script"];
//  [kScriptBuild writeToFile:scriptPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//  if ([scriptPath length] == 0)
//    return;
//
//  NSURL *scriptURL = [NSURL fileURLWithPath:scriptPath];
//  NSAppleScript *as = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL
//                                                             error:nil];
//  [as executeAndReturnError: NULL];
}

- (void)didPressRevealInspectDebugMenu:(NSMenuItem *)sender
{
  NSLog(@"Reveal didPressRevealInspectDebugMenu(Attach to RevealApp):%@", sender);

}

#pragma mark -

- (void)performActionForMenuItem:(NSMenuItem *)menuItem
{
  // Run UI stuff on the main thread
  dispatch_async(dispatch_get_main_queue(), ^{
    [[menuItem menu] performActionForItemAtIndex:[[menuItem menu] indexOfItem:menuItem]];
  });
}

@end
