//
//  YQDBHelper.m
//  Pods-YQDBModel_Example
//
//  Created by yyqxiaoyin on 2018/6/26.
//

#import "MKRDBHelper.h"

@interface MKRDBHelper ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@property (nonatomic, strong) NSString *dataBaseName;

@property (nonatomic, assign) BOOL needDirectory;

@end

@implementation MKRDBHelper

+ (instancetype)shareInstance{
    static MKRDBHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MKRDBHelper alloc] init];
        instance.dataBaseName = @"nnim.sqlite";
        instance.needDirectory = NO;
    });
    return instance;
}

+ (NSString *)dbPath{
    MKRDBHelper *helper = [MKRDBHelper shareInstance];
    return [UserModel dataSavedPathInLocalForCurrentUser:helper.dataBaseName];
}

+ (void)setDataBaseName:(NSString *)dataBaseName needDirectory:(BOOL)needDirectory{
    [MKRDBHelper shareInstance].dataBaseName = dataBaseName;
    [MKRDBHelper shareInstance].needDirectory = needDirectory;
}

-(void)openDB{
    _dbQueue = nil;
    [[MKRDBHelper shareInstance] dbQueue];
}


- (FMDatabaseQueue *)dbQueue{
    if (!_dbQueue){
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:[[self class] dbPath]];
    }
    return _dbQueue;
}

@end
