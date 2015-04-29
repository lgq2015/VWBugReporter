//
//  VWBugReporter.m
//  VWBugReporter
//
//  Created by Vinzenz Weber on 27/04/15.
//  Copyright (c) 2015 Vinzenz Weber. All rights reserved.
//

#import "VWBugReporter.h"
#import <PLCrashReporter/CrashReporter.h>
#import <SSZipArchive/SSZipArchive.h>
#import <DeviceUtil/DeviceUtil.h>
#import <OpenUDID/OpenUDID.h>


@implementation VWBugReporter


#pragma mark - Initialisation


+ (instancetype)sharedInstance {
    static VWBugReporter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VWBugReporter alloc] init];
    });
    return sharedInstance;
}


+ (VWBugReporter *)sharedBugReporterWithJiraOptions:(JMCOptions *)jiraOptions {

#if TARGET_IPHONE_SIMULATOR
    NSLog(@"APP DIR: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
#endif

    VWBugReporter *bugReporter = [VWBugReporter sharedInstance];

    // setup CocoaLumberjack
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // especially file logging is important for better issue reporting
    bugReporter.fileLogger = [[DDFileLogger alloc] init];
    bugReporter.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    bugReporter.fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:bugReporter.fileLogger];
    
    // setup PLCrashReporter
    [bugReporter setupCrashReporter];

    // setup JiraConnect
    jiraOptions.crashReportingEnabled = NO;
    [[JMC sharedInstance] configureWithOptions:jiraOptions dataSource:bugReporter];
    
    return bugReporter;
}


- (void)setupCrashReporter {
    
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;
    
    // check if we previously crashed
    if ([crashReporter hasPendingCrashReport]) {

        NSError *error = NULL;
        
        PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
        
        // try loading the crash report
        NSData *crashData = [[NSData alloc] initWithData:[crashReporter loadPendingCrashReportDataAndReturnError:&error]];
        if (crashData == nil) {
            DDLogError(@"Could not load crash report: %@", error);
        } else {
            
            PLCrashReport *report = [[PLCrashReport alloc] initWithData:crashData error:&error];
            
            // get the startup timestamp from the crash report, and the file timestamp to calculate the timeinterval when the crash happened after startup
            if (report == nil) {
                DDLogWarn(@"Could not parse crash report");
            } else {
                // write crash to file
                NSString *crashesDir = [self crashesDirectory];
                NSString *crashFilename = [NSString stringWithFormat: @"%.0f.crash", [NSDate timeIntervalSinceReferenceDate]];
                NSString *crashFilePath = [crashesDir stringByAppendingPathComponent:crashFilename];
                if(![crashData writeToFile:crashFilePath atomically:YES]) {
                    DDLogError(@"Failed writing crash report to disk!");
                }
            }
        }
        
        // purge all pending crash reports
        [crashReporter purgePendingCrashReport];

    }
    
    // enable the Crash Reporter for future crashes
    if (![crashReporter enableCrashReporterAndReturnError: &error]) {
        DDLogError(@"Could not enable crash reporter: %@", error);
    }

}


#pragma mark - File handling

- (NSString *)crashesDirectory {
    
    // temporary directory for crashes grabbed from PLCrashReporter
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *crashesDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"crashes"];
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager createDirectoryAtPath:crashesDir withIntermediateDirectories:YES attributes:nil error:&error]) {
        DDLogError(@"Could not create crash files directory: %@", error.debugDescription);
    }
    
    return crashesDir;
}


- (NSArray *)filteredFilesAtPath:(NSString *)dirPath withFileEnding:(NSString *)fileEnding {

    NSMutableArray *filteredFilesArray = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:dirPath error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self ENDSWITH '.%@'", fileEnding];
    NSArray *crashFilesNames = [dirContents filteredArrayUsingPredicate:predicate];
    for (NSString *filename in crashFilesNames) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:filename];
        [filteredFilesArray addObject:filePath];
    }
    
    return filteredFilesArray;
}


#pragma mark - Device Logs


- (NSString *)hardwareDescription {
    
    // the current date and time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss 'GMT'";
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    // Hardware infos
    NSString *hardwareDescription = [DeviceUtil hardwareDescription];
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceString = [NSString stringWithFormat:@"%@ / iOS %@", hardwareDescription,  device.systemVersion];
    
    // gather device informations
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *versionString = [NSString stringWithFormat:@"%@ (%@)", [infoDict objectForKey:@"CFBundleShortVersionString"], [infoDict objectForKey:@"CFBundleVersion"]];
    
    // current iOS language and region
    // a subset of this bundle's localizations, re-ordered into the preferred order for this process's current execution environment; the main bundle's preferred localizations indicate the language (of text) the user is most likely seeing in the UI
    NSArray *preferredLocalizations = [[NSBundle mainBundle] preferredLocalizations];
    NSString *language = [[preferredLocalizations firstObject] lowercaseString];
    NSString *countryCode = [[[NSLocale currentLocale] objectForKey: NSLocaleCountryCode] uppercaseString];
    NSString *localeString = [NSString stringWithFormat:@"%@_%@", language, countryCode];
    
    // device [OpenUDID value] to relate to API calls
    NSString *deviceGUID = [OpenUDID value];
    
    // put all strings together
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *hardwareInfoString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n", dateString, deviceString, versionString, localeString, deviceGUID];
    
    return hardwareInfoString;
}


- (NSArray *)logFilesArray {
    
    NSMutableArray *filesArray = [NSMutableArray array];
    
    // get a list of all log files created by Cocoalumberjack
    DDFileLogger *fileLogger = self.fileLogger;
    NSString *logsDirectory = [fileLogger.logFileManager logsDirectory];
    NSArray *sortedLogFilePaths = [fileLogger.logFileManager sortedLogFilePaths];
    [filesArray addObjectsFromArray:sortedLogFilePaths];
    
    // write hardware information to text file
    NSError *error = nil;
    NSString *hardwareInfoFilePath = [logsDirectory stringByAppendingPathComponent:@"Hardware.txt"];
    NSString *hardwareDescriptionString = [self hardwareDescription];
    if (![hardwareDescriptionString writeToFile:hardwareInfoFilePath
                                     atomically:YES
                                       encoding:NSUTF8StringEncoding
                                          error:&error]) {
        DDLogError(@"Could not write hardware debug info text file to hard disk: %@", error.debugDescription);
    } else {
        [filesArray addObject:hardwareInfoFilePath];
    }
    
    // add all crash logs
    NSArray *crashFiles = [self filteredFilesAtPath:[self crashesDirectory] withFileEnding:@"crash"];
    if (crashFiles) {
        [filesArray addObjectsFromArray:crashFiles];
    }
    
    // get the CoreData databse file path in case the file exists
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSArray *sqliteFiles = [self filteredFilesAtPath:documentsPath withFileEnding:@"sqlite"];
    if (sqliteFiles) {
        [filesArray addObjectsFromArray:sqliteFiles];
    }
    
    return filesArray;
}


- (NSString *)zippedLogFile {
    
    // get the zip file path
    DDFileLogger *fileLogger = self.fileLogger;
    NSString *logsDirectory = [fileLogger.logFileManager logsDirectory];
    NSString *logZipFilePath = [logsDirectory stringByAppendingPathComponent:@"Logs.zip"];
    
    NSArray *logFilesArray = [self logFilesArray];
    
    // zip the database and all log files into a single zip file
    if ([SSZipArchive createZipFileAtPath:logZipFilePath
                         withFilesAtPaths:logFilesArray]) {
        
        return logZipFilePath;
        
    } else {
        
        DDLogError(@"Could not compress log files with SSZipArchive!");
        DDLogVerbose(@"Files to compress: %@", [logFilesArray componentsJoinedByString:@", "]);
        
    }
    
    return nil;
}



#pragma mark - JMCCustomDataSource

/**
 * Returns a custom attachment that will be attached to the issue.
 */
- (JMCAttachmentItem *)customAttachment {
    
    JMCAttachmentItem *attachementItem = nil;
    
    // get the zipped log files
    NSString *logZipFilePath = [self zippedLogFile];
    if (logZipFilePath != nil) {
        
        // load the file data
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSData *zipdata = [fileManager contentsAtPath:logZipFilePath];
        
        // create the attachment item
        attachementItem = [[JMCAttachmentItem alloc] initWithName:@"Logs"
                                                             data:zipdata
                                                             type:JMCAttachmentTypePayload
                                                      contentType:@"application/zip"
                                                   filenameFormat:@"Logs.zip"];
        
    }
    
    return attachementItem;
}


/**
 * The components to set on the issue
- (NSArray *)components {
    return @[[BMNavigationRouter sharedRouter].lastOpenView];
}
 */

@end
