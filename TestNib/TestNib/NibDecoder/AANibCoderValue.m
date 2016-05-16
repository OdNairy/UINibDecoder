//
//  AANibCoderValue.m
//  TestNib
//
//  Created by Alexander on 5/10/16.
//  Copyright © 2016 Intellectsoft Group. All rights reserved.
//

#import "AANibCoderValue.h"

unsigned long AAFixedByteLengthForType_table[11] = { 1LL, 2LL, 4LL, 8LL, 0LL, 0LL, 4LL, 8LL, -1LL, 0LL, 4LL };

@implementation AANibCoderValue

+ (id)nibValueForObjectReference:(long long)reference key:(NSString *)key scope:(unsigned int)scope
{
    AANibCoderValue *value = [[AANibCoderValue alloc] init];
    value->key = [key copy];
    value->scope = scope;
    value->type = 10;
    value->value.integerValue = reference;
    return value;
}

+ (id)nibValueForInt8:(unsigned char)int8Value key:(NSString *)key scope:(unsigned int)scope
{
    AANibCoderValue *value = [AANibCoderValue new];
    value->key = [key copy];
    value->scope = scope;
    value->type = 0;
    value->value.integerValue = int8Value;
    return value;
}

+ (id)nibValueForInt16:(unsigned short)int16Value key:(NSString *)key scope:(unsigned int)scope
{
    AANibCoderValue *value = [AANibCoderValue new];
    value->key = [key copy];
    value->scope = scope;
    value->type = 1;
    value->value.integerValue = int16Value;
    return value;
}

+ (id)nibValueForInt32:(unsigned int)int32Value key:(NSString *)key scope:(unsigned int)scope
{
    AANibCoderValue *value = [AANibCoderValue new];
    value->key = [key copy];
    value->scope = scope;
    value->type = 2;
    value->value.integerValue = int32Value;
    return value;
}

+ (id)nibValueForInt64:(uint64_t)int64value key:(NSString *)key scope:(unsigned int)scope
{
    AANibCoderValue *value = [AANibCoderValue new];
    value->key = [key copy];
    value->scope = scope;
    value->type = 3;
    value->value.integerValue = int64value;
    return value;
}

+ (id)nibValueForInteger:(NSUInteger)integerValue key:(NSString *)key scope:(unsigned int)scope
{
    if (integerValue > 0x7F) {
        if (integerValue > 0x7FFF) {
            if (integerValue > 0x7FFFFFFF) {
                return [self nibValueForInt64:integerValue key:key scope:scope];
            }
            return [self nibValueForInt32:(unsigned int)integerValue key:key scope:scope];
        }
        return [self nibValueForInt16:integerValue key:key scope:scope];
    }
    return [self nibValueForInt8:integerValue key:key scope:scope];
}

+ (id)nibValueForBoolean:(BOOL)boolValue key:(NSString *)key scope:(unsigned int)scope
{
    AANibCoderValue *value = [AANibCoderValue new];
    value->key = [key copy];
    value->scope = scope;
    value->type = boolValue | 4;
    value->value.integerValue = boolValue;
    return value;
}

+ (id)nibValueForDouble:(double)doubleValue key:(NSString *)key scope:(unsigned int)scope
{
    AANibCoderValue *value = [AANibCoderValue new];
    value->key = [key copy];
    value->scope = scope;
    value->type = 7;
    value->value.doubleValue = doubleValue;
    return value;
}

+ (id)nibValueForFloat:(float)floatValue key:(NSString *)key scope:(unsigned int)scope
{
    AANibCoderValue *value = [AANibCoderValue new];
    value->key = [key copy];
    value->scope = scope;
    value->type = 6;
    value->value.floatValue = floatValue;
    return value;
}

+ (id)nibValueForBytes:(const void*)bytes length:(unsigned long)length key:(NSString *)key scope:(unsigned int)scope
{
    void *copyBytes = malloc(length);
    memcpy(copyBytes, bytes, length);
    
    AANibCoderValue *value = [AANibCoderValue new];
    value->key = [key copy];
    value->scope = scope;
    value->type = 8;
    value->length = length;
    value->value.bytesValue = copyBytes;
    return value;
}

+ (id)nibValueRepresentingNilReferenceForKey:(NSString *)key scope:(unsigned int)scope
{
    AANibCoderValue *value = [AANibCoderValue new];
    value->key = [key copy];
    value->scope = scope;
    value->type = 9;
    return value;
}

- (void)dealloc
{
    if (self->type == 8) {
        free(self->value.bytesValue);
    }
}

- (unsigned long)byteLength
{
    unsigned long result = -2LL;
    if (type >= 0 && type <= 0xA) {
        if (type == 8)
            return length;
        return AAFixedByteLengthForType_table[type];
    }
    return result;
}

@end
