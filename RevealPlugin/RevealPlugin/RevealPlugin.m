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

@implementation RevealPlugin

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
  NSLog(@"Reveal plugin DidLoaded");

  [self shared];
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

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(observeAllNotification:)
//                                                 name:nil
//                                               object:nil];
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
  NSLog(@"Notification:%@", notif.name);
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

//  NSMenuItem *productMenuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
//  if (productMenuItem) {
//    NSMenuItem *runItem = [productMenuItem.submenu itemWithTitle:@"Run"];
//
//    NSLog(@"%@ target:%@ selector:%@", runItem, runItem.target, NSStringFromSelector(runItem.action));
//
//    objc_msgSend(runItem.target, runItem.action);
  ////    [runItem.target performSelectorOnMainThread:runItem.action withObject:runItem waitUntilDone:NO];
  //  }
  
  // start applescript
  NSString *scriptPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"rp.script"];
//  if (![[NSFileManager defaultManager] fileExistsAtPath:scriptPath]) {
    [kScriptBuild writeToFile:scriptPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//  }
  
  if ([scriptPath length] == 0)
    return;

  NSURL *scriptURL = [NSURL fileURLWithPath:scriptPath];

  NSAppleScript *as = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL
                                                             error:nil];
  [as executeAndReturnError: NULL];
}

- (void)didPressRevealInspectDebugMenu:(NSMenuItem *)sender
{
  NSLog(@"Reveal didPressRevealInspectDebugMenu(Attach to RevealApp):%@", sender);

}

@end
