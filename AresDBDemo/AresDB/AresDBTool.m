//
//  AresDBTool.m
//  AresDBDemo
//
//  Created by Admin on 16/11/25.
//  Copyright © 2016年 AresBegin. All rights reserved.
//

#import "AresDBTool.h"
#import "FMDB.h"
#import "AresDBModel.h"
#import "AresElseTool.h"

static FMDatabase * _fmdb;

//这里默认使用“id”作为主键
static NSString * PRIMARYKEY = @"id";

@interface AresDBTool ()
{
    NSString * _currentDBPath;
}
@end

@implementation AresDBTool

+ (instancetype)instantiateTool{
    static AresDBTool * tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[self.class alloc] init];
    });
    return tool;
}

- (void)openDBWith:(NSString *)dbName Model:(AresDBModel *)model{
    NSString * tableName = [[self class] getValidDBName:dbName];
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"aresDB.sqlite"];
    NSLog(@"filePath->%@",filePath);
    if (![_fmdb open]) {
        [[self class] openDB];
    }
    
#pragma 必须先打开数据库才能创建表 若数据库未打开 会提示未打开数据库
    NSString * sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS t_%@(%@ INTEGER PRIMARY KEY,",tableName,PRIMARYKEY];
     // 增加一个附加主键区别渐变主键id(作用与id一样,不过id你不能当做模型属性取出来而它可以)
    sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ INTEGER NOT NULL,",[[AresDBModel getAllKeys] firstObject]]];
    NSArray * modelArr = [model getAllKeys];
    for (int i = 0; i < modelArr.count; i++) {
        id value = [model getAllValues][i];
        NSString * type = getDBKeyType(value);
        if (i == [model getAllKeys].count - 1) {
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ %@ NOT NULL);",modelArr[i],type]];
        }else{
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ %@ NOT NULL,",modelArr[i],type]];
        }
    }
    [_fmdb executeUpdate:sql];
    [_fmdb close];
}

- (BOOL)insertDataWith:(NSString *)dbName Model:(AresDBModel *)model{
    if (![_fmdb open]) {
        [[self class] openDB];
    }
    NSString * tableName = [[self class] getValidDBName:dbName];
    
    [[self class] checkIfAlterTableWith:tableName Model:model];
    
//    拼接sql语句
    NSArray * keys = [model getAllKeys];
    NSArray * values = [model getAllValues];
    NSString * sql = [NSString stringWithFormat:@"INSERT INTO t_%@",tableName];
    NSString * keyParmaeter = @"(";
    NSString * keyNoSureParameter = @"(";
    NSMutableArray * valuesArray = [NSMutableArray array];
    
    keyParmaeter = [keyParmaeter stringByAppendingString:[NSString stringWithFormat:@"%@, ",[[AresDBModel getAllKeys] firstObject]]];
    keyNoSureParameter = [keyNoSureParameter stringByAppendingString:@"?,"];
    [valuesArray addObject:[NSNumber numberWithLongLong:[[self class] getMaxID:tableName]]];
    
    for (int i = 0; i < keys.count; i ++) {
        if(i == keys.count - 1) {
            keyParmaeter = [keyParmaeter stringByAppendingString:[NSString stringWithFormat:@"%@)",keys[i]]];
            keyNoSureParameter = [keyNoSureParameter stringByAppendingString:@"?)"];
        }else {
            keyParmaeter = [keyParmaeter stringByAppendingString:[NSString stringWithFormat:@"%@, ",keys[i]]];
            keyNoSureParameter = [keyNoSureParameter stringByAppendingString:@"?,"];
        }
        // 添加数据
        [valuesArray addObject:values[i]];
    }
    // sql是最终拼接好的sql语句
    sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ VALUES %@",keyParmaeter,keyNoSureParameter]];
    BOOL isSuccess = [_fmdb executeUpdate:sql withArgumentsInArray:valuesArray];
    if(!isSuccess) NSLog(@"error:%@",_fmdb.lastErrorMessage);
    [_fmdb close];
    return isSuccess;
}

- (BOOL)insertDataWithBatch:(NSString *)dbName DataArray:(NSArray *)dataArray UserTransaction:(BOOL)userTransaction{
    if (![_fmdb open]) {
        [[self class] openDB];
    }
    NSString * tableString = [[self class] getValidDBName:dbName];
    AresDBModel * model = [dataArray firstObject];
    
    [[self class] checkIfAlterTableWith:tableString Model:model];
    
    __block BOOL  isInsertSuccess = YES;
    if (userTransaction) {
//        使用事物处理
        NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:dbName];
        FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
        int64_t customid = [[self class] getMaxID:tableString];
        [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (int i = 0; i < dataArray.count; i++) {
                AresDBModel * modelT = dataArray[i];
                NSArray * keys = [modelT getAllKeys];
                NSArray * values = [modelT getAllValues];
                NSString * sql = [NSString stringWithFormat:@"INSERT INTO t_%@",tableString];
                NSString *keyParameter = @"(";
                NSString *keyNoSureParameter = @"(";
                NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity:1];
                
                // 增加一个附加主键区别渐变主键id(作用与id一样,不过id你不能当做模型属性取出来而它可以)
                keyParameter = [keyParameter stringByAppendingString:[NSString stringWithFormat:@"%@, ",[[AresDBModel getAllKeys] firstObject]]];
                keyNoSureParameter = [keyNoSureParameter stringByAppendingString:@"?,"];
                [valuesArray addObject:@(customid + i)];
                //[valuesArray addObject:[NSNumber numberWithLongLong:[[self class] getMaxID:dbPath]]];
                
                for (int i = 0; i < keys.count; i ++) {
                    if(i == keys.count - 1) {
                        keyParameter = [keyParameter stringByAppendingString:[NSString stringWithFormat:@"%@)",keys[i]]];
                        keyNoSureParameter = [keyNoSureParameter stringByAppendingString:@"?)"];
                    }else {
                        keyParameter = [keyParameter stringByAppendingString:[NSString stringWithFormat:@"%@, ",keys[i]]];
                        keyNoSureParameter = [keyNoSureParameter stringByAppendingString:@"?,"];
                    }
                    // 添加数据
                    [valuesArray addObject:values[i]];
                }
                // sql是最终拼接好的sql语句
                sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ VALUES %@",keyParameter,keyNoSureParameter]];
                
                BOOL isSuccess = [db executeUpdate:sql withArgumentsInArray:valuesArray];
                if(!isSuccess) {
                    *rollback = YES;
                    isInsertSuccess = NO;
                    return ;
                }
            }
        }];
    }else{
        for (int i = 0; i < dataArray.count; i++) {
            AresDBModel * model = dataArray[i];
          BOOL isSuccess = [self insertDataWith:dbName Model:model];
            if (!isSuccess) {
                isInsertSuccess = NO;
            }
        }
    }
    [_fmdb close];
    return isInsertSuccess;
}

- (BOOL)insertDataWithBatch:(NSString *)dbName DataArray:(NSArray *)dataArray UseTransaction:(BOOL )userTransaction Progress:(void(^)(double progress))progress {
    if (![_fmdb open]) {
        [[self class] openDB];
    }
    NSString * tableString = [[self class] getValidDBName:dbName];
    AresDBModel * model = [dataArray firstObject];
    [[self class] checkIfAlterTableWith:tableString Model:model];
    __block BOOL  isInsertSuccess = YES;
    __block NSInteger current = 0;
    
    
    if (userTransaction) {
        //        使用事物处理
        NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:dbName];
        FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
        int64_t customid = [[self class] getMaxID:tableString];
        [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (int i = 0; i < dataArray.count; i++) {
                AresDBModel * modelT = dataArray[i];
                NSArray * keys = [modelT getAllKeys];
                NSArray * values = [modelT getAllValues];
                NSString * sql = [NSString stringWithFormat:@"INSERT INTO t_%@",tableString];
                NSString *keyParameter = @"(";
                NSString *keyNoSureParameter = @"(";
                NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity:1];
                
                // 增加一个附加主键区别渐变主键id(作用与id一样,不过id你不能当做模型属性取出来而它可以)
                keyParameter = [keyParameter stringByAppendingString:[NSString stringWithFormat:@"%@, ",[[AresDBModel getAllKeys] firstObject]]];
                keyNoSureParameter = [keyNoSureParameter stringByAppendingString:@"?,"];
                [valuesArray addObject:@(customid + i)];
                //[valuesArray addObject:[NSNumber numberWithLongLong:[[self class] getMaxID:dbPath]]];
                
                for (int i = 0; i < keys.count; i ++) {
                    if(i == keys.count - 1) {
                        keyParameter = [keyParameter stringByAppendingString:[NSString stringWithFormat:@"%@)",keys[i]]];
                        keyNoSureParameter = [keyNoSureParameter stringByAppendingString:@"?)"];
                    }else {
                        keyParameter = [keyParameter stringByAppendingString:[NSString stringWithFormat:@"%@, ",keys[i]]];
                        keyNoSureParameter = [keyNoSureParameter stringByAppendingString:@"?,"];
                    }
                    // 添加数据
                    [valuesArray addObject:values[i]];
                }
                // sql是最终拼接好的sql语句
                sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ VALUES %@",keyParameter,keyNoSureParameter]];
                
                BOOL isSuccess = [db executeUpdate:sql withArgumentsInArray:valuesArray];
                if(!isSuccess) {
                    *rollback = YES;
                    isInsertSuccess = NO;
                    return ;
                }
                current ++;
                progress((double)current / (double)dataArray.count);
            }
        }];
    }else{
        for (int i = 0 ; i < dataArray.count; i++) {
            AresDBModel * model = [dataArray objectAtIndex:i];
          BOOL isSuccess = [self insertDataWith:dbName Model:model];
            if (!isSuccess) {
                isInsertSuccess = NO;
            }
            current ++;
            progress((double)current / (double)dataArray.count);
        }
    }
    [_fmdb close];
    return isInsertSuccess;
}

- (BOOL)deleteDataWith:(NSString *)dbName{
    if (![_fmdb open]) {
        [[self class] openDB];
    }
    NSString * tableString = [[self class] getValidDBName:dbName];
    BOOL isSuccess = [_fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM t_%@",tableString]];
    if (!isSuccess) NSLog(@"error->%@",_fmdb.lastError);
    [_fmdb close];
    return isSuccess;
}

- (BOOL)deleteDataWith:(NSString *)dbName Identifier:(NSString *)identifier IdentifierValue:(NSString *)identifierValue{
    if (![_fmdb open]) {
        [[self class] openDB];
    }
    NSString * tableString = [[self class] getValidDBName:dbName];
    NSString * deleteSql = [NSString stringWithFormat:@"DELETE FROM t_%@ WHERE %@ = %@",tableString,checkObjectNotNull(identifier)? identifier : PRIMARYKEY,identifierValue];
    BOOL isDelete = [_fmdb executeUpdate:deleteSql];
    if (!isDelete) NSLog(@"delete data error -> %@",_fmdb.lastError);
    [_fmdb close];
    return isDelete;
}

- (BOOL)deleteDataWithBatch:(NSString *)dbName Identifier:(NSString *)identifier IdentifierValues:(NSArray *)identifierValues{
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:dbName];
    
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    __block BOOL isDeleteSuccess = YES;
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (int i = 0; i < identifierValues.count; i++) {
          BOOL isDelete = [self deleteDataWith:dbName Identifier:identifier IdentifierValue:identifierValues[i]];
            if (!isDelete) {
                *rollback = YES;
                isDeleteSuccess = NO;
                return ;
            }
        }
    }];
    [_fmdb close];
    return isDeleteSuccess;
}

- (BOOL)modifyDataWith:(NSString *)dbName Model:(AresDBModel *)model{
    if (![_fmdb open]) {
        [[self class] openDB];
    }
    
    NSString * tableString = [[self class] getValidDBName:dbName];
    NSArray * keys = [model getAllKeys];
    NSArray * values = [model getAllValues];
    NSString * sql = [NSString stringWithFormat:@"UPDATE t_%@ SET ",tableString];
    
    NSMutableArray * valuesArray = [NSMutableArray array];
    for (int i = 0 ; i < keys.count; i++) {
        if (i == keys.count - 1) {
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ = ?",keys[i]]];
        }else{
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ = ?,",keys[i]]];
        }
        [valuesArray addObject:values[i]];
    }
    BOOL isModifySuccess = [_fmdb executeUpdate:sql withArgumentsInArray:valuesArray];
    if(!isModifySuccess) NSLog(@"modify error -> %@",_fmdb.lastError);
    [_fmdb close];
    return isModifySuccess;
}

- (BOOL)modifyDataWith:(NSString *)dbName Model:(AresDBModel *)model Identifier:(NSString *)identifier IdentifierValue:(NSString *)identifierValue{
    if (![_fmdb open]) {
        [[self class] openDB];
    }
    NSString * tableString = [[self class] getValidDBName:dbName];
    NSArray * keys = [model getAllKeys];
    NSArray * values = [model getAllValues];
    NSString * sql = [NSString stringWithFormat:@"UPDATE t_%@ SET ",tableString];
    NSMutableArray * valuesArray = [NSMutableArray array];
    for (int i = 0; i < keys.count; i++) {
        if (i == keys.count -1) {
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ = ? WHERE %@ = %@",keys[i],
                                                checkObjectNotNull(identifier) ? identifier:PRIMARYKEY,identifierValue]];
        }else{
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ = ?,",keys[i]]];
        }
        [valuesArray addObject:values[i]];
    }
    BOOL isModifySuccess = [_fmdb executeUpdate:sql withArgumentsInArray:valuesArray];
    if(!isModifySuccess) NSLog(@"modify error -> %@",_fmdb.lastError);
    [_fmdb close];
    return isModifySuccess;
}

- (BOOL)modifyDataWith:(NSString *)dbName Key:(NSString *)key Value:(id )value{
    if (![_fmdb open]) {
        [[self class] openDB];
    }
    NSString * tableString = [[self class] getValidDBName:dbName];
    NSString * sql = [NSString stringWithFormat:@"UPDATE t_%@ WHERE %@ = ? WHERE id = 1",tableString,key];
    
    BOOL isModifySuccess = [_fmdb executeQuery:sql withArgumentsInArray:@[value]];
    if (!isModifySuccess) NSLog(@"modify error -> %@",_fmdb.lastError);
    [_fmdb close];
    return isModifySuccess;
}

- (BOOL)modifyDataWith:(NSString *)dbName Key:(NSString *)key Value:(id )value Identifier:(NSString *)identifier IdentifierValue:(NSString *)identifierValue{
    if (![_fmdb open]) {
        [[self class] openDB];
    }
    NSString * tableString = [[self class] getValidDBName:dbName];
    NSString * sql = [NSString stringWithFormat:@"UPDATE t_%@ SET %@ = ? WHERE %@ = %@",tableString,key,checkObjectNotNull(identifier)? identifier:PRIMARYKEY,identifierValue];
    BOOL isModifySuccess = [_fmdb executeUpdate:sql withArgumentsInArray:@[value]];
    if (!isModifySuccess) NSLog(@"modify error -> %@",_fmdb.lastError);
    return isModifySuccess;
}

- (BOOL)modifyDataWithBatch:(NSString *)dbName Key:(NSArray *)keys Value:(NSArray *)values Identifier:(NSString *)identifier IdentifierValue:(NSString *)identifierValue {
    
    if(keys.count != values.count) return NO;
    if(![_fmdb open]) {
        [[self class] openDB];
    }
    // 处理不同表命名(name、name.sqlite)获取有效表名
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:dbName];
    NSString *dbPath = [[self class] getValidDBName:dbName];
    
    // 批量用事务处理
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    __block BOOL isModifySuccess = YES;
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (int i = 0; i < keys.count; i ++) {
            
            NSString *sql = [NSString stringWithFormat:@"UPDATE t_%@ SET %@ = '%@' WHERE %@ = %@",dbPath,keys[i],values[i],checkObjectNotNull(identifier)?identifier:PRIMARYKEY,identifierValue];
            NSLog(@"sql:%@",sql);
            BOOL isSuccess = [db executeUpdate:sql];
            if(!isSuccess) {
                
                *rollback = YES;
                isModifySuccess = NO;
                return ;
            }
        }
    }];
    
    [_fmdb close];
    return isModifySuccess;
}

- (BOOL)modifyDataWithBatch:(NSString *)dbName KeyValue:(NSDictionary *)keyValue Identifier:(NSString *)identifier IdentifierValue:(NSString *)identifierValue {
    
    if([[keyValue allKeys] count] != [[keyValue allValues] count]) return NO;
    if(![_fmdb open]) {
        [[self class] openDB];
    }
    // 处理不同表命名(name、name.sqlite)获取有效表名
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:dbName];
    NSString *dbPath = [[self class] getValidDBName:dbName];
    
    // 批量用事务处理
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    __block BOOL isModifySuccess = YES;
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (int i = 0; i < [[keyValue allKeys] count]; i ++) {
            
            NSString *sql = [NSString stringWithFormat:@"UPDATE t_%@ SET %@ = '%@' WHERE %@ = %@",dbPath,[keyValue allKeys][i],[keyValue allValues][i],checkObjectNotNull(identifier)?identifier:PRIMARYKEY,identifierValue];
            NSLog(@"sql:%@",sql);
            BOOL isSuccess = [db executeUpdate:sql];
            if(!isSuccess) {
                
                *rollback = YES;
                isModifySuccess = NO;
                return ;
            }
        }
    }];
    [_fmdb close];
    return isModifySuccess;
}

- (NSArray *)queryDataWith:(NSString *)dbName{
    if (![_fmdb open]) {
        [[self class] openDB];
    }
    NSString * tableString = [[self class] getValidDBName:dbName];
    NSString * sql = [NSString stringWithFormat:@"SELECT * FROM t_%@",tableString];
    NSMutableArray * dataArray = [NSMutableArray array];
    FMResultSet * set = [_fmdb executeQuery:sql];
    while ([set next]) {
        NSArray * dbkeysArray = [[set columnNameToIndexMap] allKeys];
        NSDictionary * dict = [NSDictionary dictionary];
        for (NSString * key in dbkeysArray) {
            id value = [set objectForColumnName:key];
            [dict setValue:value forKey:key];
        }
        [dataArray addObject:dict];
    }
    [_fmdb close];
    return dataArray;
}

+ (NSArray *)searchDBColumns:(NSString *)dbName{
    if (![_fmdb open]) {
        [[self class] openDB];
    }
    NSString * tableString = [[self class] getValidDBName:dbName];
    NSString * sql = [NSString stringWithFormat:@"select * from t_%@",tableString];
    FMResultSet * result = [_fmdb executeQuery:sql];
    NSDictionary * dict = [result columnNameToIndexMap];
    return [dict allKeys];
}

/**
 如果有新增字段 要再表中新增字段再执行更新
 */
+ (void)checkIfAlterTableWith:(NSString *)tableName Model:(AresDBModel *)model{
    NSArray * newColum = [[self class] searchNewColum:tableName Model:model];
    for (int i = 0 ; i < newColum.count; i++) {
        id value = [model getAllValues][i];
        NSString * type = getDBKeyType(value);
        NSString * alertSql = [NSString stringWithFormat:@"ALTER TABLE t_%@ ADD COLUMN %@ %@",tableName,newColum[i],type];
        if (![_fmdb executeUpdate:alertSql])
            NSLog(@"error->%@",_fmdb.lastErrorMessage);
    }
}
/**
 检索新增字段 若有返回新增字段数组 若无 返回空
 */
+ (NSArray *)searchNewColum:(NSString *)tableName Model:(AresDBModel *)model{
    if (![_fmdb open]) {
        [[self class] openDB];
    }
    NSString * sqlStr = [NSString stringWithFormat:@"select * from t_%@",tableName];
    FMResultSet * result = [_fmdb executeQuery:sqlStr];
    
    NSMutableArray * newColumArray = [NSMutableArray array];
    NSArray * keys = [model getAllKeys];
    for (int i = 0; i < keys.count; i++) {
        NSString * key = keys[i];
        [result columnIndexForName:key];
        NSDictionary * dict = [result columnNameToIndexMap];
        if (dict) {
            NSArray * dictKeys = [dict allKeys];
            if (![dictKeys containsObject:[key lowercaseString]]) {
                [newColumArray addObject:key];
            }
        }
    }
    return newColumArray;
}

/**
 如果数据库未打开 先打开数据库
 */
+ (void)openDB{
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"aresDB.sqlite"];
    _fmdb = [FMDatabase databaseWithPath:filePath];
    [_fmdb open];
}
/**
 获取表名
 
 @param dbname name.sqlite
 
 @return name
 */
+ (NSString *)getValidDBName:(NSString *)dbname{
    NSArray * dbNameArray = [dbname componentsSeparatedByString:@"."];
    NSString * dbPath = [dbNameArray firstObject];
    return dbPath;
}

+ (int64_t)getMaxID:(NSString *)tableName{
    NSString * sql = [NSString stringWithFormat:@"select max(%@) max from t_%@",PRIMARYKEY,tableName];
    __block int64_t max = 0;
    [_fmdb executeStatements:sql withResultBlock:^int(NSDictionary *resultsDictionary) {
        if (resultsDictionary) {
            if (checkObjectNotNull(resultsDictionary[@"max"])) {
                max = (int64_t)[resultsDictionary[@"max"] integerValue];
            }
        }
        return 0;
    }];
    return max + 1;
}

@end
