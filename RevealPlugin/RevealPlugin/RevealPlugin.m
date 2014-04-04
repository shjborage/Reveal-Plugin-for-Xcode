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

@property (nonatomic, assign) BOOL isRevealed;
@property (nonatomic, assign) BOOL isPreparedForLaunch;
@property (nonatomic, assign) BOOL isInspected;

@property (nonatomic, strong) NSMenuItem *revealItem;
@property (nonatomic, strong) NSMenuItem *attachItem;

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
    
    self.revealItem = revealItem;
  }

  NSMenuItem *debugMenuItem = [[NSApp mainMenu] itemWithTitle:@"Debug"];
  if (debugMenuItem) {
    NSMenuItem *revealItem = [[NSMenuItem alloc] initWithTitle:@"Attach to RevealApp"
                                                        action:@selector(didPressRevealInspectDebugMenu:)
                                                 keyEquivalent:@";"];
    [revealItem setTarget:self];
    [revealItem setKeyEquivalentModifierMask:NSControlKeyMask|NSCommandKeyMask];
    [[debugMenuItem submenu] addItem:revealItem];
    
    [revealItem.menu setAutoenablesItems:NO];
    [revealItem setEnabled:NO];
    self.attachItem = revealItem;
  }
}

- (void)observeAllNotification:(NSNotification *)notif
{
//  // Log notifications if you like
//  if ([[notif name] length] >= 2 && ([[[notif name] substringWithRange:NSMakeRange(0, 2)] isEqualTo:@"NS"] || [[[notif name] substringWithRange:NSMakeRange(0, 2)] isEqualTo:@"_N"])) {
//    // It's a system-level notification
//  } else {
//    // It's a Xcode-level notification
//    NSLog(@"%@", notif.name);
//  }
  
  // This seems like quite a mess, but the notification-driven approach avoids waiting for
  // indeterminate amounts of time for building / running to get far enough along to avoid crashes.
  
  /*
   IDEBuildOperationDidStopNotification
   IDEBuildOperationWillStartNotification
   
   DVTDeviceShouldIgnoreChangesDidEndNotification
   IDECurrentLaunchSessionTargetOutputChanged
   IDECurrentLaunchSessionStateChanged
   */
  
  // Finished building
  if ([[notif name] isEqualToString:@"IDEBuildOperationDidGenerateOutputFilesNotification"]) {
    // Recived notification every time per build
    NSLog(@"Build finish...");
    
    self.isPreparedForLaunch = YES;
  }
  
  if ([[notif name] isEqualToString:@"IDECurrentLaunchSessionTargetOutputChanged"]) {
    // Finish building and second notif is the already run the project.
    NSLog(@"Debug state change...");
    if (self.isPreparedForLaunch) {
      NSLog(@"isPreparedForLaunch...");
      [self.attachItem setEnabled:YES];
      
      if (self.isRevealed)
        [self attachToLLDB];
    }
    self.isPreparedForLaunch = NO;
  }
  
  // Finished stopping
  if ([[notif name] isEqualToString:@"CurrentExecutionTrackerCompletedNotification"]) {
    // Reviced no matter how it is stoped.
    NSLog(@"Finished.");
    [self.attachItem setEnabled:NO];
    self.isPreparedForLaunch = NO;
  }
}

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

  self.isRevealed = YES;
  
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

  [self attachToLLDB];
}

#pragma mark -

- (void)performActionForMenuItem:(NSMenuItem *)menuItem
{
  // Run UI stuff on the main thread
  dispatch_async(dispatch_get_main_queue(), ^{
    [[menuItem menu] performActionForItemAtIndex:[[menuItem menu] indexOfItem:menuItem]];
  });
}

#pragma mark - attach to lldb

- (void)attachToLLDB
{
  if (!self.isInspected) {
    NSLog(@"AttachToLLDB starting");
    self.isInspected = YES;
    [self.attachItem setEnabled:NO];
  } else {
    [self.attachItem setEnabled:NO];
    NSLog(@"AttachToLLDB already started");
    return;
  }
  
  // do something
  // self.isInspected = NO;
}

@end
