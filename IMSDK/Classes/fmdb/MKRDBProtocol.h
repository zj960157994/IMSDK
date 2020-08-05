//
//  MKRDBProtocol.h
//  FMDB
//
//  Created by yyqxiaoyin on 2018/7/4.
//

#import <Foundation/Foundation.h>

@protocol MKRDBProtocol <NSObject>

@optional

+ (NSString *)tableName;

+ (void)setDataBaseName:(NSString *)dataBaseName needDirectory:(BOOL)needDirectory;

+ (NSArray *)propertyBlackList;

+ (NSDictionary <NSString *,id> *)dataBaseCustomPropertyMapper;

+ (NSString *)customPrimaryKey;

@end
