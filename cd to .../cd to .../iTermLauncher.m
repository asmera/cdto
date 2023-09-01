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
    if (!terminal.isRunning) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        NSWorkspace *ws = NSWorkspace.sharedWorkspace;
        NSURL *appURL = [ws URLForApplicationWithBundleIdentifier:iTermBundleId];
        [ws openApplicationAtURL:appURL
                   configuration:NSWorkspaceOpenConfiguration.configuration
               completionHandler:^(NSRunningApplication * _Nullable app, NSError * _Nullable error) {
            SBApplication *terminal = [SBApplication applicationWithBundleIdentifier:iTermBundleId];
            [terminal activate];
            
            while ([[terminal performSelector:@selector(windows)] firstObject] == nil) {
                [NSThread sleepForTimeInterval:0.2];
            }
            [iTermLauncher _runAppleScript:YES withPath:url.path];
            dispatch_semaphore_signal(sema);
        }];
        dispatch_time_t waitTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_semaphore_wait(sema, waitTime);
    }
    else {
        [terminal activate];
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
