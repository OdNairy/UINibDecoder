//
//  AANibCoderValue.h
//  TestNib
//
//  Created by Alexander on 5/10/16.
//  Copyright © 2016 Intellectsoft Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AANibCoderValue : NSObject {
    NSString *key;
    unsigned long length;
    unsigned int scope;
    char type;
    union {
        float floatValue;
        double doubleValue;
        unsigned long long integerValue;
        void *bytesValue;
    } value;
}

+ (instancetype)nibValueForBoolean:(BOOL)boolValue key:(NSString *)key scope:(unsigned int)scope;
+ (instancetype)nibValueForBytes:(const void*)bytes length:(unsigned long)length key:(NSString *)key scope:(unsigned int)scope;
+ (instancetype)nibValueForDouble:(double)doubleValue key:(NSString *)key scope:(unsigned int)scope;
+ (instancetype)nibValueForFloat:(float)floatValue key:(NSString *)key scope:(unsigned int)scope;
+ (instancetype)nibValueForInt16:(unsigned short)int16Value key:(NSString *)key scope:(unsigned int)scope;
+ (instancetype)nibValueForInt32:(unsigned int)int32Value key:(NSString *)key scope:(unsigned int)scope;
+ (instancetype)nibValueForInt64:(uint64_t)int64value key:(NSString *)key scope:(unsigned int)scope;
+ (instancetype)nibValueForInt8:(unsigned char)int8Value key:(NSString *)key scope:(unsigned int)scope;
+ (instancetype)nibValueForInteger:(NSUInteger)integerValue key:(NSString *)key scope:(unsigned int)scope;
+ (instancetype)nibValueForObjectReference:(long long)reference key:(NSString *)key scope:(unsigned int)scope;
+ (instancetype)nibValueRepresentingNilReferenceForKey:(NSString *)key scope:(unsigned int)scope;

- (unsigned long)byteLength;

@end