//
//  AresDBModel.m
//  AresDBDemo
//
//  Created by Admin on 16/11/25.
//  Copyright © 2016年 AresBegin. All rights reserved.
//

#import "AresDBModel.h"

#import <objc/runtime.h>

@implementation AresDBModel


+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary{
    id obj = [[self alloc] init];
    for (NSString * originKey in dictionary.allKeys) {
        NSString * key = [originKey lowercaseString];
        if ([[obj getAllKeys] containsObject:key]) {
            id value = dictionary[originKey];
            if ([value isKindOfClass:[NSNull class]]) {
                continue;
            }
            [obj setValue:value forKey:key];
        }else{
            continue;
        }
    }
    if (dictionary[@"primaryKeyID"]) {
        [obj setValue:dictionary[@"primaryKeyID"] forKey:@"primaryKeyID"];
    }
    return obj;
}

- (NSArray *)getAllValues{
   NSDictionary * dict = [self dictionaryWithModel];
    NSArray * arr = [self getAllKeys];
    NSMutableArray * dataArray = [NSMutableArray array];
    for (NSString * key in arr) {
        id value = nil;
        if (dict[key] == nil) {
            value = @"";
        }else{
            value = dict[key];
        }
        [dataArray addObject:value];
    }
    return dataArray;
}

- (NSDictionary *)dictionaryWithModel{
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    for (NSString * key in [self getAllKeys]) {
        id value = [self valueForKey:key];
        if (value != nil) {
            if ([value isKindOfClass:[NSArray class]]) {
                if ([value count] == 0) {
                    continue;
                }
            }
            if ([value isKindOfClass:[NSString class]]) {
                if ([value length] == 0) {
                    continue;
                }
            }
            [dictionary setObject:value forKey:key];
        }else{
            continue;
        }
    }
    return dictionary;
}

- (NSArray *)getAllKeys{
    NSMutableArray * props = [NSMutableArray array];
    unsigned int outCount,i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        const char * char_f = property_getName(properties[i]);
        NSString * propertyName = [NSString stringWithUTF8String:char_f];
        [props addObject:propertyName];
    }
    free(properties);
    return props;
}

+ (NSArray *)getAllKeys{
    NSMutableArray * props = [NSMutableArray array];
    unsigned int outCount,i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        const char * char_f = property_getName(properties[i]);
        NSString * propertyName = [NSString stringWithUTF8String:char_f];
        [props addObject:propertyName];
    }
    free(properties);
    return props;
}

@end
