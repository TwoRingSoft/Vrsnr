//
//  SemVerVersions.h
//  semver
//
//  Created by Andrew McKnight on 6/26/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SemVerVersions : NSObject

+ (NSString *)buildVersion;
+ (NSString *)displayVersion;

@end
