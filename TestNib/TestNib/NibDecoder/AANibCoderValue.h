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

+ (id)nibValueForBoolean:(BOOL)boolValue key:(NSString *)key scope:(unsigned int)scope;
+ (id)nibValueForBytes:(const void*)bytes length:(unsigned long)length key:(NSString *)key scope:(unsigned int)scope;
+ (id)nibValueForDouble:(double)doubleValue key:(NSString *)key scope:(unsigned int)scope;
+ (id)nibValueForFloat:(float)floatValue key:(NSString *)key scope:(unsigned int)scope;
+ (id)nibValueForInt16:(unsigned short)int16Value key:(NSString *)key scope:(unsigned int)scope;
+ (id)nibValueForInt32:(unsigned int)int32Value key:(NSString *)key scope:(unsigned int)scope;
+ (id)nibValueForInt64:(uint64_t)int64value key:(NSString *)key scope:(unsigned int)scope;
+ (id)nibValueForInt8:(unsigned char)int8Value key:(NSString *)key scope:(unsigned int)scope;
+ (id)nibValueForInteger:(NSUInteger)integerValue key:(NSString *)key scope:(unsigned int)scope;
+ (id)nibValueForObjectReference:(long long)reference key:(NSString *)key scope:(unsigned int)scope;
+ (id)nibValueRepresentingNilReferenceForKey:(NSString *)key scope:(unsigned int)scope;

- (unsigned long)byteLength;

@end