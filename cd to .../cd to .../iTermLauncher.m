//
//  iTermManager.m
//  cd to
//
//  Created by Sungwoo Han on 2023/08/29.
//  Copyright © 2023 Jay Tuley. All rights reserved.
//

#import "iTermLauncher.h"
#import <Cocoa/Cocoa.h>
#import <ScriptingBridge/ScriptingBridge.h>

@implementation iTermLauncher

+ (void)launchWithURL:(NSURL *)url
{
    NSString * const iTermBundleId = @"com.googlecode.iterm2";
    
    SBApplication *terminal = [SBApplication applicationWithBundleIdentifier:iTermBundleId];
    BOOL running = terminal.isRunning;
    [terminal activate];
    if (!running) {
        NSCondition *c = [[NSCondition alloc] init];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            while ([[terminal performSelector:@selector(windows)] firstObject] == nil) {
                [NSThread sleepForTimeInterval:0.2];
            }
            [iTermLauncher _runAppleScript:YES withPath:url.path];
            [c signal];
        });
        [c waitUntilDate:[NSDate.date dateByAddingTimeInterval:5]];
    }
    else {
        [iTermLauncher _runAppleScript:NO withPath:url.path];
    }
}

+ (void)_runAppleScript:(BOOL)isFirtLaunch withPath:(NSString *)path
{
    NSMutableString *scriptStr =
    [NSMutableString stringWithFormat:
     @"tell application \"iTerm\"\n"];
    
    if (!isFirtLaunch) {
        [scriptStr appendString:
         @" create window with default profile\n"];
    }

    [scriptStr appendString:
     @"  set aWindow to current window\n"
      "  set aCount to 0\n"
      "  repeat while aWindow is missing value and aCount < 10\n"
      "    delay 0.1\n"
      "    set aWindow to current window\n"
      "    set aCount to aCount + 1\n"
      "  end repeat\n"];
    
    if (isFirtLaunch) {
        [scriptStr appendString:
         @"  tell aWindow\n"
          "    set aTab to current tab\n"
          "    set aCount to 0\n"
          "    repeat while aTab is missing value and aCount < 10\n"
          "      delay 0.1\n"
          "      set aTab to current tab\n"
          "      set aCount to aCount + 1\n"
          "    end repeat\n"
          "  end tell\n"];
    }

    [scriptStr appendFormat:
     @"  tell current tab of aWindow\n"
      "    tell current session\n"
      "      write text \"cd '%@'\"\n"
      "    end tell\n"
      "  end tell\n"
      "end tell", path];
    
    NSAppleScript *sc = [[NSAppleScript alloc] initWithSource:scriptStr];
    NSDictionary *retDic = nil;
    [sc executeAndReturnError:&retDic];
}

@end
