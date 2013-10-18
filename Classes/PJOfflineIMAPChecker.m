//
//  PJOfflineIMAPChecker.m
//  Gmail Notifr
//
//  Created by Piet Jaspers on 18/10/13.
//  Copyright (c) 2013 ashchan.com. All rights reserved.
//

#import "PJOfflineIMAPChecker.h"

@implementation PJOfflineIMAPChecker {
        NSTimer         *_timer;
}

- (void)check {
    [self runOfflineImap:^(BOOL success) {
        [self processResult];
    }];
}

- (BOOL)isAccountEnabled {
    return YES;
}

- (void)reset {
    [self cleanup];
    [[NSNotificationCenter defaultCenter] postNotificationName:GNCheckingAccountNotification object:self userInfo:@{@"guid": @"offlineimap"}];
    
    if ([self isAccountEnabled]) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:10 * 60 target:self selector:@selector(reset) userInfo:nil repeats:YES];
        [self check];
    } else {
        [self notifyMenuUpdate];
    }
}

- (void)runOfflineImap:(void (^)(BOOL success))done {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"Runing offlineimap");
        [[NSTask launchedTaskWithLaunchPath:@"/usr/local/bin/offlineimap" arguments:@[]] waitUntilExit];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Finished running offlineimap");
            done(YES);
        });
    });
}

- (void)notifyMenuUpdate {
    [[NSNotificationCenter defaultCenter] postNotificationName:GNAccountMenuUpdateNotification object:nil userInfo:@{@"guid": @"offlineimap", @"checkedAt": [NSDate date]}];
}

- (void)processResult {
    [[NSNotificationCenter defaultCenter] postNotificationName:GNAccountMenuUpdateNotification object:nil userInfo:@{@"guid": @"offlineimap", @"checkedAt": [NSDate date]}];
}

@end
