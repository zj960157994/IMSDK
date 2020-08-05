//
//  YQDBModel.h
//  Pods-YQDBModel_Example
//
//  Created by yyqxiaoyin on 2018/6/26.
//

#import <Foundation/Foundation.h>
#import "MKRDBProtocol.h"
#import "MKRDBHelper.h"

#define SQLTEXT     @"TEXT"
#define SQLINTEGER  @"INTEGER"
#define SQLREAL     @"REAL"
#define SQLBLOB     @"BLOB"
#define SQLNULL     @"NULL"
#define PRIMARYKEY  @"PRIMARY KEY AUTOINCREMENT"
#define PRIMARYID   @"pk"

typedef NS_ENUM(NSUInteger, YQDBConditionType) {
    YQDBConditionTypeLessThan            = 0,
    YQDBConditionTypeLessThanOrEqual,
    YQDBConditionTypeEqual,
    YQDBConditionTypeGreaterThanOrEqual,
    YQDBConditionTypeGreaterThan,
};

@interface MKRDBModel : NSObject

/** 主键 */
@property (nonatomic, assign) int pk;

+ (NSDictionary *)getAllPropertiesWithoutPK;

+ (NSString *)getColumeAndTypeSQLString;

@property (nonatomic, strong ,readonly) NSMutableArray *columeNames;

@property (nonatomic, strong ,readonly) NSMutableArray *columeTypes;

@property (nonatomic, strong ,readonly) NSMutableArray *columeOCTypes;

+ (NSArray *)columnNames;

+ (NSArray *)columeTypes;

#pragma mark - ============= 插入操作 =============
/** 批量插入数据 */
+ (BOOL)saveObjects:(NSArray *)objects;

+ (BOOL)saveOrUpdateObjects:(NSArray *)objects;

/** 插入单条数据 */
- (BOOL)save;

/** 保存或者更新单条数据 根据主键pk判断 若存在为更新 不存在为保存 */
- (BOOL)saveOrUpdate;

#pragma mark - ============= 删除操作 =============
/** 删除单条数据 */
- (BOOL)deleteObject;

/** 批量删除数据 */
+ (BOOL)deleteObjects:(NSArray *)objects;

/** 清空表 */
+ (BOOL)clearTable;

/** 传入条件语句删除数据 : WHERE age > 13 */
+ (BOOL)deleteObjectsByCondition:(NSString *)condition;

/**
 根据传入的 列名 、条件、值 组成 如 " WHERE 列名字 条件(<  <= = >= >) 值 "的sql语句 删除数据
 @param columnName      列名
 @param conditionType   条件枚举
 @param value           用来做条件判断的值
 @return                返回结果集
 */
+ (BOOL)deleteObjectWhereColumnName:(NSString *)columnName
                      conditionType:(YQDBConditionType)conditionType
                              value:(NSString *)value;

/** 执行 "列名 < value" 删除操作 */
+ (BOOL)deleteWhereColumnName:(NSString *)columnName lessThanValue:(NSString *)value;

/** 执行 "列名 <= value" 删除操作 */
+ (BOOL)deleteWhereColumnName:(NSString *)columnName lessThanOrEqualValue:(NSString *)value;

/** 执行 "列名 = value" 删除操作 */
+ (BOOL)deleteWhereColumnName:(NSString *)columnName equalToValue:(NSString *)value;

/** 执行 "列名 >= value" 删除操作 */
+ (BOOL)deleteWhereColumnName:(NSString *)columnName greaterThanOrEqualValue:(NSString *)value;

/** 执行 "列名 > value" 删除操作 */
+ (BOOL)deleteWhereColumnName:(NSString *)columnName greaterThanValue:(NSString *)value;

#pragma mark - ============= 查询操作 =============

/** 表中所有数据个数 */
+ (NSUInteger)tableColumnCount;

/** 查找表中columnName = value 数据个数 */
+ (NSUInteger)tableColumnCountByColumnName:(NSString *)columnName value:(NSString *)value;

+ (NSUInteger)tableColumnCountByCondition:(NSString *)condition;

/** 表是否存在 */
+ (BOOL)isExistInTable;

/** 查询所有数据 */
+ (NSArray *)findAllObject;

/** 传入主键pk查询数据 */
+ (instancetype)findObjectByPK:(id)pk;

/** 传入条件语句查询数据 返回查询结果的第一条数据  条件语句 eg : WHERE age > 13 */
+ (instancetype)findFirstObjectByCondition:(NSString *)condition;

/** 传入条件语句查询数据 返回模型结果集 eg : WHERE age > 13 */
+ (NSArray *)findObjectsByCondition:(NSString *)condition;

/**
 根据传入的 列名 、条件、值 组成 如 " WHERE 列名字 条件(<  <= = >= >) 值 "的sql语句
 @param columnName      列名
 @param conditionType   条件枚举
 @param value           用来做条件判断的值
 @return                返回结果集
 */
+ (NSArray *)findWhereColumnName:(NSString *)columnName
                   conditionType:(YQDBConditionType)conditionType
                           value:(NSString *)value;
/** 根据传入的 列名 、条件、值 组成 如 " WHERE 列名字 条件(<  <= = >= >) 值 "的sql语句
 返回查询结果的第一条数据
 */
+ (instancetype)findFirstObjectWhereColumnName:(NSString *)columnName
                                 conditionType:(YQDBConditionType)conditionType
                                         value:(NSString *)value;

/** 执行 "列名 < value" 查询操作 */
+ (NSArray *)findWhereColumnName:(NSString *)columnName lessThanValue:(NSString *)value;

/** 执行 "列名 <= value" 查询操作 */
+ (NSArray *)findWhereColumnName:(NSString *)columnName lessThanOrEqualValue:(NSString *)value;

/** 执行 "列名 = value" 查询操作 */
+ (NSArray *)findWhereColumnName:(NSString *)columnName equalToValue:(NSString *)value;

/** 执行 "列名 >= value" 查询操作 */
+ (NSArray *)findWhereColumnName:(NSString *)columnName greaterThanOrEqualValue:(NSString *)value;

/** 执行 "列名 > value" 查询操作 */
+ (NSArray *)findWhereColumnName:(NSString *)columnName greaterThanValue:(NSString *)value;

#pragma mark - ============= 更新操作 =============
/** 更新单条数据 */
- (BOOL)update;

/** 批量更新数据 */
+ (BOOL)updateObjects:(NSArray *)objects;

@end
