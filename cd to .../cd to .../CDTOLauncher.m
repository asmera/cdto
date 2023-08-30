//
//  LauncherFactory.m
//  cd to
//
//  Created by Sungwoo Han on 2023/08/30.
//  Copyright © 2023 Jay Tuley. All rights reserved.
//

#import "CDTOLauncher.h"

#import <ScriptingBridge/ScriptingBridge.h>
#import "Finder.h"

#import "iTermLauncher.h"
#import "TerminalLauncher.h"

@implementation CDTOLauncher

+ (void)launch
{
    Class launcherClass = nil;
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"cdto-use-iTerm"]) {
        launcherClass = iTermLauncher.class;
    }
    else {
        launcherClass = TerminalLauncher.class;
    }
    
    id<LauncherProtocol> launcher = [launcherClass launcherWithURL:[self urlFromFinder]];
    [launcher run];
}

+ (NSURL *)urlFromFinder
{
    // Setup code that might create autoreleased objects goes here.
    FinderApplication *finder = [SBApplication applicationWithBundleIdentifier:@"com.apple.Finder"];
    
    FinderItem *target = [(NSArray*)[[finder selection] get] firstObject];
    FinderFinderWindow *findWin = [[finder FinderWindows] objectAtLocation:@1];
    findWin = [[finder FinderWindows] objectWithID:[NSNumber numberWithInteger: findWin.id]];
    bool selected = true;
    if (target == nil) {
        target = [[findWin target] get];
        selected = false;
    }
    
    if ([[target kind] isEqualToString:@"Alias"]) {
        target = (FinderItem*)[(FinderAliasFile*)target originalItem];
    }
    
    NSString* fileUrl = [target URL];
    if(fileUrl != nil && ![fileUrl hasSuffix:@"/"] && selected) {
        fileUrl = [fileUrl stringByDeletingLastPathComponent];
    }
    
    NSURL* url = [NSURL URLWithString:fileUrl];
    if (url == nil) {
        NSString *path = NSHomeDirectory();
        url = [NSURL fileURLWithPath:path];
    }
    return url;
}

@end
