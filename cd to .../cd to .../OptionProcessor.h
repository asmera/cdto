//
//  OptionProcessor.h
//  cd to
//
//  Created by Sungwoo Han on 2023/08/30.
//  Copyright © 2023 Jay Tuley. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OptionProcessor : NSObject

+ (BOOL)processOptionWithArgc:(NSInteger)argc argv:(const char * _Nonnull * _Nonnull)argv;

@end

NS_ASSUME_NONNULL_END
