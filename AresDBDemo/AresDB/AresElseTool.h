//
//  AresElseTool.h
//  AresDBDemo
//
//  Created by Admin on 16/11/25.
//  Copyright © 2016年 AresBegin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ARESPrefixWithArray @"Ares_Begin_Prefix_Array"
#define ARESPrefixWithDictionary @"Ares_Begin_Prefix_Dictionary"

@interface AresElseTool : NSObject

/**
 根据value判断key类型(如value = @"jack",即key = TEXT;value = @10,即key = INTEGER)
 目前支持以下类型
 TEXT:   值是文本字符串,使用数据库编码(UTF-8,UTF-16BE或者UTF-16LE)存放,最大长度为2^31-1(2,147,483,647)个字符.
 INTEGER:值是有符号整形,根据值的大小以1,2,3,4,6或8字节存放
 REAL:   值是浮点型值,以8字节IEEE浮点数存放
 BLOB:   值是一个数据块,完全按照输入存放（即没有准换,可以存储例如照片data）
 NULL:   值是NULL
 */
NSString *getDBKeyType(id object);

/**
 *  将数组转化为以,分隔的字符串
 *
 *  @param array 接收数组
 *
 *  @return 字符串
 */
NSString *changeToTextWithArray(NSArray *array);

/**
 *  将字典转换为字符串
 *
 *  @param dict 接收字典
 *
 *  @return 字符串
 */
NSString * changeToTextWithDictionary(NSDictionary *dict);

/**
 *  Checking NSString、NSNull、NSURL、NSDictionary、NSArray、NSNumber
 *
 *  @param object class
 *
 *  @return YES or NO
 */
BOOL checkObjectNotNull(id object);

NSString * getCurrentDBPath();

BOOL setCurrentBDPath(NSString *dbpath);
NSString *getTodayDate(NSString *formatter);


@end
