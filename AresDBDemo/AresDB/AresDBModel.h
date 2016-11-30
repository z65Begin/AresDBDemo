//
//  AresDBModel.h
//  AresDBDemo
//
//  Created by Admin on 16/11/25.
//  Copyright © 2016年 AresBegin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AresDBModel : NSObject

/******************************************************
 
 注意:
 1:模型字段key全部小写
 2:转模型时,字典中若出现新的key数据库会自动识别为新增字段,并更新表
 3:id应为保留字段(数据库默认主键:id),因此模型中应尽量避免出现id为key的情况
 4:若真需要使用id作为key,请修改创建数据库语句,将id改为其他即可
 
 *******************************************************/


@property (nonatomic, assign) int64_t primaryKeyID;

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;
- (NSArray *)getAllKeys;
- (NSArray *)getAllValues;
- (NSDictionary *)dictionaryWithModel;

+ (NSArray *)getAllKeys;

@end
