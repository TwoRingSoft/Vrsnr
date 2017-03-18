//
//  VrsnrVersions.h
//  vrsn
//
//  Created by Andrew McKnight on 6/26/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VrsnrVersions : NSObject

+ (NSString *)buildVersion;
+ (NSString *)displayVersion;

@end

NS_ASSUME_NONNULL_END
