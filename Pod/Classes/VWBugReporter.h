//
//  VWBugReporter.h
//  VWBugReporter
//
//  Created by Vinzenz Weber on 27/04/15.
//  Copyright (c) 2015 Vinzenz Weber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JiraConnect/JMC.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface VWBugReporter : NSObject <JMCCustomDataSource>

@property (strong, nonatomic) DDFileLogger *fileLogger;
@property (strong, nonatomic) JMCOptions *options;

+ (instancetype)sharedInstance;
+ (VWBugReporter *)sharedBugReporterWithUrl:(NSString *)jiraURL
                                 projectKey:(NSString *)projektKey
                                     apiKey:(NSString *)apiKey;
+ (VWBugReporter *)sharedBugReporterWithJiraOptions:(JMCOptions *)jiraOptions;

- (NSString *)zippedLogFile;

@end
