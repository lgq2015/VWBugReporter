//
//  UIViewController+VWBugReporter.m
//  VWBugReporter
//
//  Created by Vinzenz Weber on 27/04/15.
//  Copyright (c) 2015 Vinzenz Weber. All rights reserved.
//

#import "UIViewController+VWBugReporter.h"
#import <JiraConnect/JMC.h>

@implementation UIViewController (VWBugReporter)

#if DEBUG

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [super motionEnded:motion withEvent:event];
    if (motion == UIEventSubtypeMotionShake) {
        [self presentViewController:[[JMC sharedInstance] viewController] animated:YES completion:nil];
    }
}

#endif

@end
