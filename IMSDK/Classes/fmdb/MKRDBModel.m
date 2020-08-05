//
//  YQDBModel.m
//  Pods-YQDBModel_Example
//
//  Created by yyqxiaoyin on 2018/6/26.
//

#import "MKRDBModel.h"
#import <objc/runtime.h>

@interface MKRDBModel ()

@end

@implementation MKRDBModel

+ (void)initialize{
    if (self != [MKRDBModel self]){
        [self createTable];
    }
}

- (instancetype)init{
    if (self = [super init]) {
        NSDictionary *dic = [self.class getAllProperties];
        _columeNames = [NSMutableArray arrayWithArray:[dic objectForKey:@"name"]];
        _columeTypes = [NSMutableArray arrayWithArray:[dic objectForKey:@"type"]];
        _columeOCTypes = [NSMutableArray arrayWithArray:[dic objectForKey:@"OCType"]];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [_columeNames enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [aCoder encodeObject:[self valueForKey:obj] forKey:obj];
    }];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        NSDictionary *dict = [self.class getAllProperties];
        NSMutableArray *columeNames = [NSMutableArray arrayWithArray:[dict objectForKey:@"name"]];
        NSMutableArray *columeTypes = [NSMutableArray arrayWithArray:[dict objectForKey:@"type"]];
        for (int i= 0; i<columeNames.count; i++) {
            NSString *columeName = columeNames[i];
            NSString *type = columeTypes[i];
            if ([type isEqualToString:SQLTEXT] ||[type isEqualToString:SQLBLOB]) {
                [self setValue:[aDecoder decodeObjectForKey:columeName] forKey:columeName];
            }
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    id copyInstance = [[[self class] allocWithZone:zone] init];
    NSDictionary *dict = [self.class getAllProperties];
    NSMutableArray *columeNames = [NSMutableArray arrayWithArray:[dict objectForKey:@"name"]];
    for (int i= 0; i<columeNames.count; i++) {
        NSString *columeName = columeNames[i];
        [copyInstance setValue:[self valueForKey:columeName] forKey:columeName];
    }
    return copyInstance;
}

#pragma mark - 增删查改操作

//MARK: 保存单个数据
- (BOOL)save{
    return [[self class] saveObjects:@[self]];
}

//MARK: 批量保存数据
+ (BOOL)saveObjects:(NSArray *)objects{
    __block BOOL res = YES;
    MKRDBHelper *helper = [MKRDBHelper shareInstance];
    [helper.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (MKRDBModel *model in objects) {
            
            NSString *tableName = [model.class tableName];
            NSMutableString *keyString = [NSMutableString string];
            NSMutableString *valueString = [NSMutableString string];
            NSMutableArray *insertValues = [NSMutableArray array];
            NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
            for (int i = 0; i<model.columeNames.count; i++) {
                NSString *proName = [model.columeNames objectAtIndex:i];
                if ([proName isEqualToString:PRIMARYID]) {
                    continue;
                }
                [valueString appendString:@"?,"];
                Class c = NSClassFromString([model.columeOCTypes objectAtIndex:i]);
                id value = [model valueForKey:proName];
                if (!value) {
                    if ([c isKindOfClass:[NSObject class]]) {
                        value = [[c alloc] init];
                    }
                }
                if ([custumProperties.allKeys containsObject:proName]) {
                    proName = custumProperties[proName];
                }
                [keyString appendFormat:@"%@,",proName];
                NSString *columnType = [model.columeTypes objectAtIndex:i];
                if ([columnType isEqualToString:SQLBLOB]) {
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
                    value = data;
                }
                [insertValues addObject:value];
            }
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            [valueString deleteCharactersInRange:NSMakeRange(valueString.length - 1, 1)];
            NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@) VALUES(%@)",tableName,keyString,valueString];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:insertValues];
            NSLog(flag?@"插入成功":@"插入失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return ;
            }
        }
    }];
    
    return res;
}

//MARK: 插入或者更新一条数据
- (BOOL)saveOrUpdate{
    id primaryValue = [self valueForKey:[self.class customPrimaryKey]];
    BOOL isSave = YES;
    NSInteger existCount = [[self class] tableColumnCountByColumnName:[self.class customPrimaryKey] value:primaryValue];
    isSave = existCount <=0 ? YES : NO;
    if (isSave) {
        return [self save];
    }
    return [self update];
}

+ (BOOL)saveOrUpdateObjects:(NSArray *)objects{
    __block BOOL res = YES;
    MKRDBHelper *helper = [MKRDBHelper shareInstance];
    [helper.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (MKRDBModel *model in objects) {
            
            NSString *tableName = [model.class tableName];
            NSMutableString *keyString = [NSMutableString string];
            NSMutableString *valueString = [NSMutableString string];
            NSMutableArray *insertValues = [NSMutableArray array];
            NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
            for (int i = 0; i<model.columeNames.count; i++) {
                NSString *proName = [model.columeNames objectAtIndex:i];
                if ([proName isEqualToString:PRIMARYID]) {
                    continue;
                }
                [valueString appendString:@"?,"];
                NSString *columnType = [model.columeTypes objectAtIndex:i];
                Class c = NSClassFromString([model.columeOCTypes objectAtIndex:i]);
                id value = [model valueForKey:proName];
                if (!value) {
                    if ([c isKindOfClass:[NSObject class]]) {
                        value = [[c alloc] init];
                    }
                }
                if ([custumProperties.allKeys containsObject:proName]) {
                    proName = custumProperties[proName];
                }
                [keyString appendFormat:@"%@,",proName];
                if ([columnType isEqualToString:SQLBLOB]) {
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
                    value = data;
                }
                [insertValues addObject:value];
            }
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            [valueString deleteCharactersInRange:NSMakeRange(valueString.length - 1, 1)];
            NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@) VALUES(%@)",tableName,keyString,valueString];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:insertValues];
            NSLog(flag?@"替换成功":@"替换失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return ;
            }
        }
    }];
    
    return res;
}

//MARK: 更新单条数据
- (BOOL)update{
    return [[self class] updateObjects:@[self]];
}

//MARK: 更新多条数据
+ (BOOL)updateObjects:(NSArray *)objects{
    MKRDBHelper *helper = [MKRDBHelper shareInstance];
    __block BOOL res = YES;
    [helper.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (MKRDBModel *model in objects) {
            NSString *tableName = [model.class tableName];
            id primaryValue = [model valueForKey:[model.class customPrimaryKey]];
            if (!primaryValue || primaryValue <= 0) {
                res = NO;
                *rollback = YES;
                return ;
            }
            NSMutableString *keyString = [NSMutableString string];
            NSMutableArray *updatValues = [NSMutableArray array];
            NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
            for (int i = 0; i<model.columeNames.count; i++) {
                NSString *proName = [model.columeNames objectAtIndex:i];
                if ([proName isEqualToString:PRIMARYID]) {
                    continue;
                }
                Class c = NSClassFromString([model.columeOCTypes objectAtIndex:i]);
                id value = [model valueForKey:proName];
                if ([c isKindOfClass:[NSObject class]]) {
                    if (!value) {
                        value = [[c alloc] init];
                    }
                }
                NSString *columnType = [model.columeTypes objectAtIndex:i];
                if ([columnType isEqualToString:SQLBLOB]) {
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
                    value = data;
                }
                if ([custumProperties.allKeys containsObject:proName]) {
                    proName = custumProperties[proName];
                }
                [keyString appendFormat:@" %@ = ?,",proName];
                [updatValues addObject:value];
            }
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            NSString *sql = [NSString stringWithFormat:@"UPDATE OR REPLACE %@ SET %@ WHERE %@ = ?",tableName,keyString,[self customPrimaryKey]];
            [updatValues addObject:primaryValue];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:updatValues];
            NSLog(flag?@"更新成功":@"更新失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    
    return res;
}

//MARK: 删除单个数据
- (BOOL)deleteObject{
    return [[self class] deleteObjects:@[self]];
}

+ (BOOL)deleteObjects:(NSArray *)objects{
    MKRDBHelper *helper = [MKRDBHelper shareInstance];
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    __block BOOL res = YES;
    [helper.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (MKRDBModel *model in objects) {
            NSString *tableName = [model.class tableName];
            NSString *primaryKey = [[model class] customPrimaryKey];
            id primaryValue = [model valueForKey:primaryKey];
            if (!primaryValue || primaryValue <= 0) {
                res = NO;
                *rollback = YES;
                return ;
            }
            if ([custumProperties.allKeys containsObject:primaryKey]) {
                primaryKey = custumProperties[primaryKey];
            }
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,primaryKey];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
            NSLog(flag?@"删除成功":@"删除失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}

+ (BOOL)deleteObjectsByCondition:(NSString *)condition{
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    for (int i = 0; i<custumProperties.allKeys.count; i++) {
        NSString *key = [custumProperties.allKeys objectAtIndex:i];
        if ([condition containsString:key]) {
            condition = [condition stringByReplacingOccurrencesOfString:key withString:custumProperties[key]];
        }
    }
    MKRDBHelper *helper = [MKRDBHelper shareInstance];
    __block BOOL res = NO;
    [helper.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *tableName = [self tableName];
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ %@",tableName,condition];
        res = [db executeUpdate:sql];
    }];
    return res;
}

+ (BOOL)deleteObjectWhereColumnName:(NSString *)columnName
                      conditionType:(YQDBConditionType)conditionType
                              value:(NSString *)value{
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    if ([custumProperties.allKeys containsObject:columnName]) {
        columnName = [custumProperties objectForKey:columnName];
    }
    NSString *sql = [NSString stringWithFormat:@"WHERE %@ %@ '%@'",columnName,getConditonStringWithConditionType(conditionType),value];
    return [[self class] deleteObjectsByCondition:sql];
}

+ (BOOL)deleteWhereColumnName:(NSString *)columnName lessThanValue:(NSString *)value{
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    if ([custumProperties.allKeys containsObject:columnName]) {
        columnName = [custumProperties objectForKey:columnName];
    }
    return [[self class] deleteObjectWhereColumnName:columnName conditionType:YQDBConditionTypeLessThan value:value];
}

+ (BOOL)deleteWhereColumnName:(NSString *)columnName lessThanOrEqualValue:(NSString *)value{
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    if ([custumProperties.allKeys containsObject:columnName]) {
        columnName = [custumProperties objectForKey:columnName];
    }
    return [[self class] deleteObjectWhereColumnName:columnName conditionType:YQDBConditionTypeLessThanOrEqual value:value];
}

+ (BOOL)deleteWhereColumnName:(NSString *)columnName equalToValue:(NSString *)value{
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    if ([custumProperties.allKeys containsObject:columnName]) {
        columnName = [custumProperties objectForKey:columnName];
    }
    return [[self class] deleteObjectWhereColumnName:columnName conditionType:YQDBConditionTypeEqual value:value];
}

+ (BOOL)deleteWhereColumnName:(NSString *)columnName greaterThanOrEqualValue:(NSString *)value{
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    if ([custumProperties.allKeys containsObject:columnName]) {
        columnName = [custumProperties objectForKey:columnName];
    }
    return [[self class] deleteObjectWhereColumnName:columnName conditionType:YQDBConditionTypeGreaterThanOrEqual value:value];
}

+ (BOOL)deleteWhereColumnName:(NSString *)columnName greaterThanValue:(NSString *)value{
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    if ([custumProperties.allKeys containsObject:columnName]) {
        columnName = [custumProperties objectForKey:columnName];
    }
    return [[self class] deleteObjectWhereColumnName:columnName conditionType:YQDBConditionTypeGreaterThan value:value];
}

//MARK: 清空表
+ (BOOL)clearTable{
    MKRDBHelper *helper = [MKRDBHelper shareInstance];
    __block BOOL res = NO;
    [helper.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *tableName = [self tableName];
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
        res = [db executeUpdate:sql];
        NSLog(res?@"清空表成功":@"清空表失败");
    }];
    return res;
}

+ (NSArray *)findObjectsByCondition:(NSString *)condition{
    MKRDBHelper *helper = [MKRDBHelper shareInstance];
    NSMutableArray *result = [NSMutableArray array];
    [helper.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *tableName = [self tableName];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ %@",tableName,condition];
        NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            MKRDBModel *model = [[[self class] alloc] init];
            for (int i = 0; i<model.columeNames.count; i++) {
                NSString *columnName = [model.columeNames objectAtIndex:i];
                NSString *columnNameInDB = [model.columeNames objectAtIndex:i];
                if ([custumProperties.allKeys containsObject:columnNameInDB]) {
                    columnNameInDB = custumProperties[columnNameInDB];
                }
                NSString *columnType = [model.columeTypes objectAtIndex:i];
                if ([columnType isEqualToString:SQLTEXT]) {
                    NSString *str = [resultSet stringForColumn:columnNameInDB];
                    if (!str) {
                        str = @"";
                    }
                    [model setValue:str forKey:columnName];
                }else if ([columnType isEqualToString:SQLBLOB]){
                    NSData *data = [resultSet dataForColumn:columnNameInDB];
                    id value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    [model setValue:value forKey:columnName];
                }else{
                    [model setValue:@([resultSet longLongIntForColumn:columnNameInDB]) forKey:columnName];
                }
            }
            [result addObject:model];
            FMDBRelease(model);
        }
    }];
    return result;
}

//MARK: 通过 WHERE 列名  = value  查找相应的数据
+ (NSArray *)findWhereColumnName:(NSString *)columnName equalToValue:(NSString *)value{
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    if ([custumProperties.allKeys containsObject:columnName]) {
        columnName = [custumProperties objectForKey:columnName];
    }
    return [[self class] findWhereColumnName:columnName conditionType:YQDBConditionTypeEqual value:value];
}

+ (NSArray *)findWhereColumnName:(NSString *)columnName lessThanValue:(NSString *)value{
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    if ([custumProperties.allKeys containsObject:columnName]) {
        columnName = [custumProperties objectForKey:columnName];
    }
    return [[self class] findWhereColumnName:columnName conditionType:YQDBConditionTypeLessThan value:value];
}

+ (NSArray *)findWhereColumnName:(NSString *)columnName lessThanOrEqualValue:(NSString *)value{
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    if ([custumProperties.allKeys containsObject:columnName]) {
        columnName = [custumProperties objectForKey:columnName];
    }
    return [[self class] findWhereColumnName:columnName conditionType:YQDBConditionTypeLessThanOrEqual value:value];
}

+ (NSArray *)findWhereColumnName:(NSString *)columnName greaterThanOrEqualValue:(NSString *)value{
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    if ([custumProperties.allKeys containsObject:columnName]) {
        columnName = [custumProperties objectForKey:columnName];
    }
    return [[self class] findWhereColumnName:columnName conditionType:YQDBConditionTypeGreaterThanOrEqual value:value];
}

//MARK: 通过 WHERE 列名  > value  查找相应的数据
+ (NSArray *)findWhereColumnName:(NSString *)columnName greaterThanValue:(NSString *)value{
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    if ([custumProperties.allKeys containsObject:columnName]) {
        columnName = [custumProperties objectForKey:columnName];
    }
    return [[self class] findWhereColumnName:columnName conditionType:YQDBConditionTypeGreaterThan value:value];
}

/** 根据传入的 列名 、条件、值 组成 如 " WHERE 列名字 条件(<  <= = >= >) 值 "的sql语句 */
+ (NSArray *)findWhereColumnName:(NSString *)columnName
                   conditionType:(YQDBConditionType)conditionType
                           value:(NSString *)value{
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    if ([custumProperties.allKeys containsObject:columnName]) {
        columnName = [custumProperties objectForKey:columnName];
    }
    NSString *sql = [NSString stringWithFormat:@"WHERE %@ %@ '%@'",columnName,getConditonStringWithConditionType(conditionType),value];
    return [[self class] findObjectsByCondition:sql];
}

+ (instancetype)findFirstObjectWhereColumnName:(NSString *)columnName
                                 conditionType:(YQDBConditionType)conditionType
                                         value:(NSString *)value{
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    if ([custumProperties.allKeys containsObject:columnName]) {
        columnName = [custumProperties objectForKey:columnName];
    }
    return [[[self class] findWhereColumnName:columnName conditionType:conditionType value:value] firstObject];
}

//MARK: 条件查询之后取出结果第一个对象
+ (instancetype)findFirstObjectByCondition:(NSString *)condition{
    return [[[self class] findObjectsByCondition:condition] firstObject];
}

//MARK: 传入主键查找数据
+ (instancetype)findObjectByPK:(id)pk{
    NSString *primaryID = [self customPrimaryKey];
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    if ([custumProperties.allKeys containsObject:primaryID]) {
        primaryID = custumProperties[primaryID];
    }
    NSString *condition = [NSString stringWithFormat:@"WHERE %@ = '%@'",primaryID,pk];
    return [self findFirstObjectByCondition:condition];
}

//MARK: 查询当前表的所有数据
+ (NSArray *)findAllObject{
    NSMutableArray *results = [NSMutableArray array];
    MKRDBHelper *helper = [MKRDBHelper shareInstance];
    [helper.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *tableName = [self tableName];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            MKRDBModel *model = [[[self class] alloc]init];
            for (int i = 0; i< model.columeNames.count; i++) {
                NSString *columnName = [model.columeNames objectAtIndex:i];
                NSString *columnNameInDB = [model.columeNames objectAtIndex:i];
                if ([custumProperties.allKeys containsObject:columnNameInDB]) {
                    columnNameInDB = custumProperties[columnNameInDB];
                }
                NSString *columnType = [model.columeTypes objectAtIndex:i];
                if ([columnType isEqualToString:SQLTEXT]) {
                    NSString *str = [resultSet stringForColumn:columnNameInDB];
                    if (!str) {
                        str = @"";
                    }
                    [model setValue:str forKey:columnName];
                }else if ([columnType isEqualToString:SQLBLOB]){
                    NSData *data = [resultSet dataForColumn:columnNameInDB];
                    id value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    [model setValue:value forKey:columnName];
                }else{
                    [model setValue:@([resultSet longLongIntForColumn:columnNameInDB]) forKey:columnName];
                }
            }
            [results addObject:model];
            FMDBRelease(model);
        }
    }];
    return results;
}

#pragma mark - 初始化操作
//MARK: 创建表
+ (BOOL)createTable{
    MKRDBHelper *helper = [MKRDBHelper shareInstance];
    __block BOOL res = YES;
    [helper.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *tableName = [self tableName];
        NSString *columeAndType = [[self class] getColumeAndTypeSQLString];
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@)",tableName,columeAndType];
        if (![db executeUpdate:sql]) {
            res = NO;
            return;
        }
        res = [self.class addNewColumn:db tableName:tableName];
    }];
    return res;
}

+ (NSUInteger)tableColumnCount{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@",[self tableName]];
    MKRDBHelper *helper = [MKRDBHelper shareInstance];
    __block NSUInteger count = 0;
    [helper.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        count = [db intForQuery:sql];
    }];
    return count;
}

+ (NSUInteger)tableColumnCountByColumnName:(NSString *)columnName value:(NSString *)value{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@ = '%@'",[self tableName],columnName,value];
    MKRDBHelper *helper = [MKRDBHelper shareInstance];
    __block NSUInteger count = 0;
    [helper.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        count = [db intForQuery:sql];
    }];
    return count;
}

+ (NSUInteger)tableColumnCountByCondition:(NSString *)condition{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ %@",[self tableName],condition];
    MKRDBHelper *helper = [MKRDBHelper shareInstance];
    __block NSUInteger count = 0;
    [helper.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        count = [db intForQuery:sql];
    }];
    return count;
}

//MARK: 数据库中是否已经存在表
+(BOOL)isExistInTable{
    __block BOOL res = NO;
    MKRDBHelper *helper = [MKRDBHelper shareInstance];
    [helper.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *tableName = NSStringFromClass([self class]);
        res = [db tableExists:tableName];
    }];
    
    return res;
}

//MARK: 往表中添加新添加的字段
+ (BOOL)addNewColumn:(FMDatabase *)db tableName:(NSString *)tableName{
    NSMutableArray *columns = [NSMutableArray array];
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {
        //遍历取出数据库表中所有字段名
        NSString *column = [resultSet stringForColumn:@"name"];
        [columns addObject:column];
    }
    
    NSDictionary *dict = [[self class] getAllProperties];
    NSMutableArray *properties = [dict objectForKey:@"name"];
    NSDictionary *custumProperties = [self.class dataBaseCustomPropertyMapper];
    [properties enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([custumProperties.allKeys containsObject:obj]) {
            [properties replaceObjectAtIndex:idx withObject:custumProperties[obj]];
        }
    }];
    
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",columns];
    NSArray *resultArray = [properties filteredArrayUsingPredicate:filterPredicate];
    for (NSInteger i = 0; i<resultArray.count; i++) {
        NSString *column = resultArray[i];
        NSUInteger index = [properties indexOfObject:column];
        NSString *proType = [[dict objectForKey:@"type"] objectAtIndex:index];
        if ([custumProperties.allKeys containsObject:column]) {
            column = custumProperties[column];
        }
        NSString *fieldSql = [NSString stringWithFormat:@"%@ %@",column,proType];
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@",tableName,fieldSql];
        if (![db executeUpdate:sql]) {
            return NO;
        }
    }
    return YES;
}

//MARK: 生成用来创建表的sql
+(NSString *)getColumeAndTypeSQLString{
    NSMutableString *pars = [NSMutableString string];
    NSDictionary *dict = [[self class] getAllProperties];
    NSDictionary *custumProperties = [[self class] dataBaseCustomPropertyMapper];
    NSMutableArray *names = [dict objectForKey:@"name"];
    NSMutableArray *types = [dict objectForKey:@"type"];
    for (int i =0; i<names.count; i++) {
        NSString *name = [names objectAtIndex:i];
        NSString *type = [types objectAtIndex:i];
        if ([custumProperties.allKeys containsObject:name]) {
            name = custumProperties[name];
        }
        if ([name isEqualToString:[self customPrimaryKey]] && ![name isEqualToString:PRIMARYID]) {
            NSMutableString *typeString = [NSMutableString string];
            if ([name hasPrefix:@"unique"]) {
                [typeString appendString:SQLTEXT];
            }
            [typeString appendString:@" UNIQUE"];
            type = typeString;
        }
        [pars appendFormat:@"%@ %@",name,type];
        if (i != names.count -1) {
            [pars appendString:@","];
        }
    }
    return pars;
}

//MARK: 获取所有属性(不包括主键)
+ (NSDictionary *)getAllPropertiesWithoutPK{
    
    NSMutableArray *proNames = @[].mutableCopy;
    NSMutableArray *proTypes = @[].mutableCopy;
    NSMutableArray *proOCTypes = @[].mutableCopy;
    NSArray *blackList = [[self class] propertyBlackList];
    unsigned int count = 0;
    Ivar *ivarlist = class_copyIvarList([self class], &count);
    for (int i = 0; i< count; i++) {
        Ivar ivar = ivarlist[i];
        //获取属性名
        NSString *propertyName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if ([propertyName rangeOfString:@"_"].location == 0) {
            propertyName = [propertyName substringFromIndex:1];
        }
        if ([blackList containsObject:propertyName]) {
            continue;
        }
        [proNames addObject:propertyName];
        //获取属性类型
        NSString *propertyType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        if ([propertyType containsString:@"NS"] || [propertyType containsString:@"UI"]) {
            NSRange range = [propertyType rangeOfString:@"\""];
            propertyType = [propertyType substringFromIndex:range.location + range.length];
            range = [propertyType rangeOfString:@"\""];
            propertyType = [propertyType substringToIndex:range.location];
            //判断属性类型
            if ([propertyType isEqualToString:@"NSString"] ) {
                [proTypes addObject:SQLTEXT];
                
            }else if([propertyType isEqualToString:@"NSNumber"]){
                [proTypes addObject:SQLINTEGER];
            }else{
                [proTypes addObject:SQLBLOB];
            }
            
        }else if ([propertyType isEqualToString:@"i"] || [propertyType isEqualToString:@"q"]|| [propertyType isEqualToString:@"Q"]){
            [proTypes addObject:SQLINTEGER];//整型
        }else if ([propertyType isEqualToString:@"f"] || [propertyType isEqualToString:@"d"]){
            [proTypes addObject:SQLREAL];//浮点类型
        }else if ([propertyType isEqualToString:@"B"]) {
            [proTypes addObject:SQLINTEGER];
        }else if ([propertyType isEqualToString:@"u"]) {
            [proTypes addObject:SQLINTEGER];
        }else{
            [proTypes addObject:SQLINTEGER];//二进制类型
        }
        NSString *ocType = [propertyType stringByReplacingOccurrencesOfString:@"@" withString:@""];
        ocType = [ocType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        [proOCTypes addObject:ocType];
    }
    free(ivarlist);
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",proOCTypes,@"OCType", nil];
}

//MARK: 获取所有属性包括主键
+ (NSDictionary *)getAllProperties{
    NSDictionary *dict = [self getAllPropertiesWithoutPK];
    NSMutableArray *proNames = @[].mutableCopy;
    NSMutableArray *proTypes = @[].mutableCopy;
    NSMutableArray *proOCTypes = @[].mutableCopy;
    if ([[self customPrimaryKey] isEqualToString:PRIMARYID]) {
        [proNames addObject:PRIMARYID];
        [proTypes addObject:[NSString stringWithFormat:@"%@ %@",SQLINTEGER,PRIMARYKEY]];
        [proOCTypes addObject:@"i"];
    }
    [proNames addObjectsFromArray:[dict objectForKey:@"name"]];
    [proTypes addObjectsFromArray:[dict objectForKey:@"type"]];
    [proOCTypes addObjectsFromArray:[dict objectForKey:@"OCType"]];
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",proOCTypes,@"OCType", nil];
}

+ (NSString *)tableName{
    return NSStringFromClass([self class]);
}

+ (NSArray *)propertyBlackList{
    return @[];
}

+ (NSDictionary<NSString *,id> *)dataBaseCustomPropertyMapper{
    return @{};
}

+ (NSString *)customPrimaryKey{
    return PRIMARYID;
}

+ (NSArray *)columnNames{
    NSDictionary *dic = [self.class getAllProperties];
    return dic[@"name"];
}

+ (NSArray *)columeTypes{
    NSDictionary *dic = [self.class getAllProperties];
    return dic[@"type"];
}

NSString* getConditonStringWithConditionType(YQDBConditionType type){
    switch (type) {
        case YQDBConditionTypeLessThan:
            return @"<";
            break;
        case YQDBConditionTypeLessThanOrEqual:
            return @"<=";
            break;
        case YQDBConditionTypeEqual:
            return @"=";
            break;
        case YQDBConditionTypeGreaterThanOrEqual:
            return @">=";
            break;
        case YQDBConditionTypeGreaterThan:
            return @">";
            break;
        default:
            break;
    }
}

@end
