Reveal-Plugin-for-Xcode
=======================

[![Join the chat at https://gitter.im/shjborage/Reveal-Plugin-for-Xcode](https://badges.gitter.im/shjborage/Reveal-Plugin-for-Xcode.svg)](https://gitter.im/shjborage/Reveal-Plugin-for-Xcode?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Plugin for Xcode to integrate the Reveal App to your project automatic(Without any modifications to your project).

**Please note that plugins are not supported by Xcode 8. See [Here](https://github.com/alcatraz/Alcatraz/issues/475) for more information.**  

## Introduction

**The Reveal Plugin works just like Instruments.**

![ProductMenu](https://github.com/shjborage/Reveal-Plugin-for-Xcode/raw/master/Product-InspectWithReveal.png)

The Reveal app integrates directly into Xcode, so you don't need to add frameworks or modify your project to inspect your app in the iOS Simulator.

If you're in the middle of a debug session and something unexpected happens, you can attach Reveal to see what's going on. No restarting your app, no changing your project. All from inside Xcode.

![DebugMenu](https://github.com/shjborage/Reveal-Plugin-for-Xcode/raw/master/Debug-AttachToReveal.png)

## Install

###Via Alcatraz

Reveal-Plugin-for-XCode is available through the [Alcatraz](http://alcatraz.io/) Xcode plugin management system.

From source

Simply build the Xcode project and restart Xcode. The plugin will automatically install to `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins`.

## Uninstall

To uninstall, just remove the plugin from the above directory, and restart Xcode:

```
rm -rf ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/RevealPlugin.xcplugin
```

Tested on Xcode 5.1 and Mac OS X 10.9.2.

## Plugins upgrade for new Xcode
```
find ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name Info.plist -maxdepth 3 | xargs -I{} defaults write {} DVTPlugInCompatibilityUUIDs -array-add `defaults read /Applications/Xcode.app/Contents/Info DVTPlugInCompatibilityUUID`
```

## Issue
*	When using `Inspect ith Reveal`, if your simulator can't lanuch within 5 seconds, it's will alert an error. Thus, you can alse use Debug->`Attach to Reveal` after your app launched.

* If the plugin is not successfully loaded, it's possible your Xcode version is not supported, Add the build UUIDs for the versions of Xcode you wish to support to `DVTPlugInCompatibilityUUIDs` in `Info.plist`.

	You can get the UUID with this command `defaults read /Applications/Xcode.app/Contents/Info DVTPlugInCompatibilityUUID`, run it in termial.

## Contributors

Welcome to fork and PullRequest to do this better.
We use issues to manage bugs and enhanced features.

## Thanks

+	[Integrating Reveal without modifying your Xcode project](http://blog.ittybittyapps.com/blog/2013/11/07/integrating-reveal-without-modifying-your-xcode-project/)
+	[Xcode 4 插件制作入门](http://onevcat.com/2013/02/xcode-plugin)
