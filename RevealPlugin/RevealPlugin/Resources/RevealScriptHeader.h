//
//  BuildScriptHeader.h
//  RevealPlugin
//
//  Created by shjborage on 4/3/14.
//  Copyright (c) 2014 Saick. All rights reserved.
//

#ifndef RevealPlugin_BuildScriptHeader_h
#define RevealPlugin_BuildScriptHeader_h

//#define kScriptBuild @"tell application \"Xcode\" \n\
//activate \n\
//open \"{xcodeProjectPath}\" \n\
//end tell \n\
//tell application \"System Events\" \n\
//key code 15 using {command down} \n\
//end tell \n\
//tell application \"Spark Inspector\" \n\
//activate\n\
//end tell"

#define kScriptLaunchReveal @"tell application \"Reveal\" \n\
activate\n\
end tell"

#define kScriptActiveXcode @"tell application \"Xcode\" \n\
activate\n\
end tell"

#endif
