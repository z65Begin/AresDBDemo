//
//  AresElseTool.m
//  AresDBDemo
//
//  Created by Admin on 16/11/25.
//  Copyright © 2016年 AresBegin. All rights reserved.
//

#import "AresElseTool.h"

@implementation AresElseTool




NSString * getDBKeyType(id object){
    NSString * objStr = [NSString stringWithFormat:@"%@",object];
    if (object == nil || [object isKindOfClass:[NSNull class]]) {
        return @"NULL";
    }
    if (isInt(objStr) || [object isKindOfClass:[NSNumber class]]) {
        return @"INTEGER";
    }
    if (isFloat(objStr) || isDouble(objStr)) {
        return @"REAL";
    }
    if ([object isKindOfClass:[NSData class]]) {
        return @"BLOB";
    }
    if ([object isKindOfClass:[NSString class]] && ![objStr isEqualToString:@""]) {
        return @"TEXT";
    }
    return @"NULL";
}

NSString * changeToTextSeperateByCommaWithArray(NSArray *array){
    if (array.count > 0) {
        //为区分普通字符串 加前缀
        NSMutableString * result = [NSMutableString stringWithFormat:ARESPrefixWithArray];
        NSInteger count = 0;
        for (id child in array) {
            [result appendString:[NSString stringWithFormat:@"%@",child]];
            if (count < array.count -1) {
                [result appendString:@","];
            }
            count ++;
        }
        return result;
    }
    return nil;
}

NSString * changeToTextWithDictionary(NSDictionary *dict){
    NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSMutableString * dictStr = [NSMutableString stringWithFormat:ARESPrefixWithDictionary];
    [dictStr appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    return dictStr;
}

BOOL checkObjectNotNull(id object){
    if (object == nil || [object isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if ([object isKindOfClass:[NSString class]]  ) {
        NSString * string = (NSString *)object;
        if ([string isEqualToString:@""]) {
            return NO;
        }else
            return YES;
    }
    if ([object isKindOfClass:[NSURL class]]) {
        NSURL * url = (NSURL *)object;
        if ([[NSString stringWithFormat:@"%@",url] isEqualToString:@""]) {
            return NO;
        }else
            return YES;
    }
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = (NSDictionary *)object;
        if (dict.count <= 0) {
            return NO;
        }else
            return YES;
    }
    if ([object isKindOfClass:[NSArray class]]) {
        NSArray * arr = (NSArray *)object;
        if (arr.count <= 0) {
            return NO;
        }else
            return YES;
    }
    if ([object isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    return NO;
}

NSString * getCurrentDBPath(){
    NSString * base = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [base stringByAppendingString:@"ares_db"];
    NSData * data = [NSData dataWithContentsOfFile:path];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

BOOL setCurrentBDPath(NSString *dbpath){
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:dbpath];
    NSString * base = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [base stringByAppendingString:@"ares_db"];
    return [data writeToFile:path atomically:YES];
}

NSString *getTodayDate(NSString *formatter){
    NSDate * nowDate = [NSDate date];
    NSDateFormatter * dateF = [[NSDateFormatter alloc] init];
    dateF.dateFormat = formatter;
    return [dateF stringFromDate:nowDate];
}

BOOL isFloat(NSString *string){
    NSScanner * scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val]&&[scan isAtEnd];
}

BOOL isDouble(NSString *string){
    NSScanner * scan = [NSScanner scannerWithString:string];
    double val;
    return [scan scanDouble:&val]&&[scan isAtEnd];
}

BOOL isInt(NSString *string){
    NSScanner * scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val]&&[scan isAtEnd];
}



@end
