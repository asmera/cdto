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

@interface iTermLauncher()

@property (nonatomic, strong) NSString *path;

@end

@implementation iTermLauncher

+ (instancetype)launcherWithURL:(NSURL *)url
{
    return [[iTermLauncher alloc] initWithTargetPath:url.path];
}

- (instancetype)initWithTargetPath:(NSString *)path
{
    if (self = [super init]) {
        self.path = path;
    }
    return self;
}

- (void)run
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
            [self _runAppleScript:YES];
            [c signal];
        });
        [c waitUntilDate:[NSDate.date dateByAddingTimeInterval:5]];
    }
    else {
        [self _runAppleScript:NO];
    }
}

- (void)_runAppleScript:(BOOL)isFirtLaunch
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
      "end tell", self.path];
    
    NSAppleScript *sc = [[NSAppleScript alloc] initWithSource:scriptStr];
    NSDictionary *retDic = nil;
    [sc executeAndReturnError:&retDic];
}

@end
