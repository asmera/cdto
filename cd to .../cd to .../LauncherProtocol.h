//
//  LauncherProtocol.h
//  cd to
//
//  Created by Sungwoo Han on 2023/08/29.
//  Copyright © 2023 Jay Tuley. All rights reserved.
//

#ifndef LauncherProtocol_h
#define LauncherProtocol_h

@protocol LauncherProtocol <NSObject>

+ (void)launchWithURL:(NSURL *)url;

@end

#endif /* LauncherProtocol_h */
