//
//  main.m
//  cd to ...
//
//  Created by James Tuley on 10/9/19.
//  Copyright © 2019 Jay Tuley. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "OptionProcessor.h"
#import "CDTOLauncher.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        BOOL ret = [OptionProcessor processOptionWithArgc:argc argv:argv];
        if (ret) {
            return 0;
        }
        
        [CDTOLauncher launch];
    }
    return 0;
}
