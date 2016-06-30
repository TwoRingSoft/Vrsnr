//
//  SemVerVersions.m
//  semver
//
//  Created by Andrew McKnight on 6/26/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

#define STR_HELPER(x) #x
#define STR(x) STR_HELPER(x)

#import "SemVerVersions.h"

@implementation SemVerVersions

+ (NSString *)buildVersion {
    return @STR(BUILD_VERSION);
}

+ (NSString *)displayVersion {
    return @STR(CURRENT_PROJECT_VERSION);
}

@end
