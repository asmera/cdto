//
//  main.m
//  cd to ...
//
//  Created by James Tuley on 10/9/19.
//  Copyright © 2019 Jay Tuley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CDTOLauncher.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        if (argc > 1) {
            BOOL changedSetting = NO;
            const char *lastOption = argv[1];
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            
            if (strcmp("-use-iTerm", lastOption) == 0) {
                [userDefault setBool:YES forKey:@"cdto-use-iTerm"];
                changedSetting = YES;
            }
            else if (strcmp("-use-native", lastOption) == 0) {
                [userDefault setBool:NO forKey:@"cdto-use-iTerm"];
                changedSetting = YES;
            }
            if (changedSetting) {
                return 0;
            }
        }
        
        [CDTOLauncher launch];
    }
    return 0;
}
