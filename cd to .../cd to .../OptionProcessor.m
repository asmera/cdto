//
//  OptionProcessor.m
//  cd to
//
//  Created by Sungwoo Han on 2023/08/30.
//  Copyright © 2023 Jay Tuley. All rights reserved.
//

#import "OptionProcessor.h"

@implementation OptionProcessor

+ (BOOL)processOptionWithArgc:(NSInteger)argc argv:(const char * _Nonnull * _Nonnull)argv
{
    BOOL changedSetting = NO;
    
    if (argc > 1) {
        NSMutableArray<NSString *> *options = NSMutableArray.array;
        for (int i = 1; i < argc; i++) {
            [options addObject:[NSString stringWithUTF8String:argv[i]]];
        }
     
        NSUserDefaults *userDefault = NSUserDefaults.standardUserDefaults;
                
        if ([options containsObject:@"-use-iTerm"]) {
            [userDefault setBool:YES forKey:@"cdto-use-iTerm"];
            changedSetting = YES;
        }
        
        if ([options containsObject:@"-use-native"]) {
            [userDefault setBool:NO forKey:@"cdto-use-iTerm"];
            changedSetting = YES;
        }
    }
    
    return changedSetting;
}

@end
