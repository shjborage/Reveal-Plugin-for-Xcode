//
//  RevealPlugin.m
//  RevealPlugin
//
//  Created by shjborage on 3/27/14.
//  Copyright (c) 2014 Saick. All rights reserved.
//

#import "RevealPlugin.h"

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
  }
  return self;
}

#pragma mark - notif

- (void)applicationDidFinishLaunching:(NSNotification *)notif
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(selectionDidChange:)
                                               name:NSTextViewDidChangeSelectionNotification
                                             object:nil];
  
  NSMenuItem *productMenuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
  if (productMenuItem) {
    NSMenu *menu = [productMenuItem submenu];
    NSMenuItem *stopItem = [productMenuItem.submenu itemWithTitle:@"Stop"];
    NSInteger revealIndex = [menu indexOfItem:stopItem] + 1;
    
//    [[productMenuItem submenu] addItem:[NSMenuItem separatorItem]];
    NSMenuItem *revealItem = [[NSMenuItem alloc] initWithTitle:@"Inspect with RevealApp"
                                                        action:@selector(didPressRevealInspectMenu:)
                                                 keyEquivalent:@""];
    [revealItem setTarget:self];
    [revealItem setKeyEquivalentModifierMask:NSAlternateKeyMask];
    [[productMenuItem submenu] insertItem:revealItem atIndex:revealIndex];
  }
}

- (void)selectionDidChange:(NSNotification *)notif
{
  NSLog(@"Reveal selectionDidChange:%@", notif);
}

#pragma mark - actions

- (void)didPressRevealInspectMenu:(NSMenuItem *)sender
{
  NSLog(@"Reveal didPressRevealInspectMenu:%@", sender);
}

@end
