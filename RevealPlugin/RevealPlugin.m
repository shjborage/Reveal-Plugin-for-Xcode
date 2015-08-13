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
#import "RevealScriptHeader.h"
#import "RevealIDEModel.h"

@interface RevealPlugin ()

@property (nonatomic, assign) BOOL isRevealed;
@property (nonatomic, assign) BOOL isPreparedForLaunch;
@property (nonatomic, assign) BOOL isInspected;

@property (nonatomic, strong) NSMenuItem *revealItem;
@property (nonatomic, strong) NSMenuItem *attachItem;
@property (nonatomic, strong) NSString *dyLibPath;

@end

@implementation RevealPlugin

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
  NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
  if ([currentApplicationName isEqual:@"Xcode"]) {
    NSLog(@"Reveal plugin DidLoaded");
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
    NSMenuItem *revealItem = [[NSMenuItem alloc] initWithTitle:@"Inspect with Reveal"
                                                        action:@selector(didPressRevealInspectProductMenu:)
                                                 keyEquivalent:@"p"];
    [revealItem setTarget:self];
    [revealItem setKeyEquivalentModifierMask:NSControlKeyMask|NSCommandKeyMask];
    [[productMenuItem submenu] insertItem:revealItem atIndex:revealIndex];
    
    self.revealItem = revealItem;
  }

  NSMenuItem *debugMenuItem = [[NSApp mainMenu] itemWithTitle:@"Debug"];
  if (debugMenuItem) {
    NSMenuItem *revealItem = [[NSMenuItem alloc] initWithTitle:@"Attach to Reveal"
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
      
      if (self.isRevealed) {
        self.isRevealed = NO;
        [self attachToLLDB];
      }
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
}

- (void)didPressRevealInspectDebugMenu:(NSMenuItem *)sender
{
  NSLog(@"Reveal didPressRevealInspectDebugMenu(Attach to Reveal):%@", sender);

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
  
  // do pause execution in and then attach
  // check the dylib exist, if not, alert
  if (![self checkRevealDylib]) {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"The Reveal dynamic library does not exist. Please download the latest copy of the Reveal and replace the old version at http://revealapp.com."];
    [alert runModal];
    
    self.isInspected = NO;
    return;
  }
  
  [self pauseExecutionIn];
  
  self.isInspected = NO;
}

#pragma mark - private

- (BOOL)checkRevealDylib
{
  NSString *dylibPath1 = @"/Applications/Reveal.app/Contents/SharedSupport/iOS-Libraries/libReveal.dylib";
  NSString *dylibPath2 = [@"~/Applications/Reveal.app/Contents/SharedSupport/iOS-Libraries/libReveal.dylib" stringByResolvingSymlinksInPath];

  if ([[NSFileManager defaultManager] fileExistsAtPath:dylibPath1]) {
    self.dyLibPath = dylibPath1;
    return YES;
  } else if ([[NSFileManager defaultManager] fileExistsAtPath:dylibPath2]) {
    self.dyLibPath = dylibPath2;
    return YES;
  } else {
    return NO;
  }
}

- (void)launchRevealApp
{
  // start applescript to launch Reveal
  NSString *scriptPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"rp.script"];
  [kScriptLaunchReveal writeToFile:scriptPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
  if ([scriptPath length] == 0)
    return;
  
  NSURL *scriptURL = [NSURL fileURLWithPath:scriptPath];
  NSAppleScript *as = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL
                                                             error:nil];
  [as executeAndReturnError: NULL];
}

- (void)activeXcodeApp
{
  NSString *scriptPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"xcode.script"];
  [kScriptActiveXcode writeToFile:scriptPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
  if ([scriptPath length] == 0)
    return;
  
  NSURL *scriptURL = [NSURL fileURLWithPath:scriptPath];
  NSAppleScript *as = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL
                                                             error:nil];
  [as executeAndReturnError: NULL];
}

- (void)pauseExecutionIn
{
  DBGDebugSession *debugsession = [RevealIDEModel debugSessionIn];
  
  if (!debugsession) {
    [self activeXcodeApp];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self activeXcodeApp];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DBGDebugSession *debugsession = [RevealIDEModel debugSessionIn];
        if (!debugsession) {
          NSLog(@"Debugsession is nil");
          NSAlert *alert = [[NSAlert alloc] init];
          [alert setMessageText:@"An unexpected error occurred, please try again later!"];
          [alert runModal];
          
          [self.attachItem setEnabled:YES];
          return;
        } else {
          [self inspectWithReveal:debugsession];
        }
      });
    });
  } else {
    [self inspectWithReveal:debugsession];
  }
}

- (void)inspectWithReveal:(DBGDebugSession *)debugsession
{
  if ([debugsession respondsToSelector:@selector(requestPause)]) {
    objc_msgSend(debugsession, @selector(requestPause));
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      IDEConsoleTextView *consoleView = [RevealIDEModel whenXcodeConsoleIn];
      NSString *consoleStr = objc_msgSend(consoleView, @selector(string));
      if (NSNotFound != [consoleStr rangeOfString:@"(lldb)" options:NSBackwardsSearch].location) {
        NSString *loadDyLibExpression = [NSString stringWithFormat:@"expr (void*)dlopen(\"%@\", 0x2);", self.dyLibPath];
        objc_msgSend(consoleView, @selector(insertText:), loadDyLibExpression);
        objc_msgSend(consoleView, @selector(insertNewline:), nil);
        
        objc_msgSend(consoleView, @selector(insertText:), @"expr [(NSNotificationCenter*)[NSNotificationCenter defaultCenter] postNotificationName:@\"IBARevealRequestStart\" object:nil];");
        objc_msgSend(consoleView, @selector(insertNewline:), nil);
        
        objc_msgSend(consoleView, @selector(insertText:), @"continue");
        objc_msgSend(consoleView, @selector(insertNewline:), nil);
        
        [self launchRevealApp];
        NSLog(@"AttachToLLDB done!");
      } else {
        NSLog(@"(lldb) not found");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"An unexpected error occurred, please try again later!"];
        [alert runModal];
        
        [self.attachItem setEnabled:YES];
      }
    });
  } else {
    NSLog(@"Error:if ([debugsession respondsToSelector:@selector(requestPause)]) {");
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"An unexpected error occurred, please try again later!"];
    [alert runModal];
    
    [self.attachItem setEnabled:YES];
    return;
  }
}

@end
