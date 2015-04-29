//
//  VWViewController.m
//  VWBugReporter
//
//  Created by Vinzenz Weber on 04/29/2015.
//  Copyright (c) 2014 Vinzenz Weber. All rights reserved.
//

#import "VWViewController.h"

@interface VWViewController ()

@end

@implementation VWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchCrashTest:(id)sender {
    CFRelease(nil);
}

@end
