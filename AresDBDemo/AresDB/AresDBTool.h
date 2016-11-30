//
//  AresDBTool.h
//  AresDBDemo
//
//  Created by Admin on 16/11/25.
//  Copyright © 2016年 AresBegin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AresDBModel;
@interface AresDBTool : NSObject

+ (instancetype)instantiateTool;
/**
 打开数据库

 @param dbName 数据库名称 name.sqlite
 @param model  存储数据模型
 */
- (void)openDBWith:(NSString *)dbName Model:(AresDBModel *)model;

- (BOOL)insertDataWith:(NSString *)dbName Model:(AresDBModel *)model;
- (BOOL)insertDataWithBatch:(NSString *)dbName DataArray:(NSArray *)dataArray UserTransaction:(BOOL)userTransaction;
// 带进度的 dataArray存的是模型 userTransaction 带事物处理的 
- (BOOL)insertDataWithBatch:(NSString *)dbName DataArray:(NSArray *)dataArray UseTransaction:(BOOL )userTransaction Progress:(void(^)(double progress))progress;

- (BOOL)deleteDataWith:(NSString *)dbName;
- (BOOL)deleteDataWith:(NSString *)dbName Identifier:(NSString *)identifier IdentifierValue:(NSString *)identifierValue;
- (BOOL)deleteDataWithBatch:(NSString *)dbName Identifier:(NSString *)identifier IdentifierValues:(NSArray *)identifierValues;

- (BOOL)modifyDataWith:(NSString *)dbName Model:(AresDBModel *)model;
- (BOOL)modifyDataWith:(NSString *)dbName Model:(AresDBModel *)model Identifier:(NSString *)identifier IdentifierValue:(NSString *)identifierValue;
- (BOOL)modifyDataWith:(NSString *)dbName Key:(NSString *)key Value:(id )value;
- (BOOL)modifyDataWithBatch:(NSString *)dbName Key:(NSArray *)keys Value:(NSArray *)values Identifier:(NSString *)identifier IdentifierValue:(NSString *)identifierValue;

/**
 *  批量修改模型数据(多条记录:根据标示符找到记录再根据key修改其对应value)
 *  (该方法与上面的一样,只不过用字典替换数组,上面数组方法若你把数组内key与value顺序搞错了就麻烦啦~~~)
 *
 *  @param dbName          数据库名
 *  @param keyValue        变更数据字典
 *  @param identifier      标示符(不传默认使用建表主键:id)
 *  @param identifierValue 标示符值
 *
 *  @return 修改成功或者失败(YES or NO)
 */
- (BOOL)modifyDataWithBatch:(NSString *)dbName KeyValue:(NSDictionary *)keyValue Identifier:(NSString *)identifier IdentifierValue:(NSString *)identifierValue;

/**
 *  查询数据
 *  (再次提醒注意:这里返回的数组内元素是字典类型,你可用对应模型进行转换)
 *  (建议一个做法:数据库名写在模型头文件,这个方法传的是数据库名,如果你有很多模型的话这样就可以快速知道你该用哪个模型类接收数据并转换为模型了)
 一般开发中用途:
 1:例如存储用户基本信息，这里基本是一张表一条记录，此时返回的数组中可以无数据,也可以有一条数据
 2:类似备忘录需求,这里是一张表但有多条记录，此时返回的数组中可以无数据,可以有一条数据,也可以有多条数据)
 *
 *  @param dbName 数据库名
 *
 *  @return 所查询的数据
 */
- (NSArray *)queryDataWith:(NSString *)dbName;
@end
