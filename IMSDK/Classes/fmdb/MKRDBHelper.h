//
//  YQDBHelper.h
//  Pods-YQDBModel_Example
//
//  Created by yyqxiaoyin on 2018/6/26.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface MKRDBHelper : NSObject

@property (nonatomic, strong, readonly) FMDatabaseQueue *dbQueue;

+ (NSString *)dbPathWithDirectoryName:(NSString *)directoryName;

+ (instancetype)shareInstance;

+ (void)setDataBaseName:(NSString *)dataBaseName needDirectory:(BOOL)needDirectory;

/**
 *  数据库路径
 *
 *  @return 路径字符串
 */
+(NSString *)dbPath;

-(void)openDB;

@end
