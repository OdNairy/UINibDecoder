//
//  AANibDecoder.h
//  TestNib
//
//  Created by AB on 5/8/16.
//  Copyright © 2016 Intellectsoft Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AANibStringIDTable.h"

typedef struct UINibArchiveTableInfo {
    unsigned int count;
    unsigned int offset;
} UINibArchiveTableInfo;

typedef struct UINibDecoderHeader {
    unsigned char type[10]; //88
    unsigned int formatVersion; //100
    unsigned int coderVersion; //104
    UINibArchiveTableInfo objects; //108
    UINibArchiveTableInfo keys; //116
    UINibArchiveTableInfo values; //124
    UINibArchiveTableInfo classes; //132
} UINibDecoderHeader;

typedef struct UINibDecoderRecursiveState {
    NSInteger objectID;
    NSInteger nextGenericKey;
    unsigned int nextValueSearchIndex;
    BOOL replaced;
} UINibDecoderRecursiveState;

typedef struct UINibDecoderValue {
    unsigned int valueID;
    unsigned int offset;
} UINibDecoderValue;

typedef struct UIKeyAndScopeToValueCache {
    unsigned int previousScope;
    unsigned int previousKey;
    UINibDecoderValue *previousValue;
} UIKeyAndScopeToValueCache;

typedef struct UINibDecoderObjectEntry {
    unsigned int x1;
    unsigned int x2;
} UINibDecoderObjectEntry;

@interface AANibDecoder : NSCoder

@property id delegate;

+ (instancetype)unarchiveObjectWithData:(NSData *)data;
+ (instancetype)unarchiveObjectWithFile:(NSString *)path;

- (instancetype)initForReadingWithData:(NSData *)data;
- (instancetype)initForReadingWithData:(NSData *)data error:(NSError **)error;

- (BOOL)decodeArrayOfCGFloats:(CGFloat*)values count:(NSInteger)count forKey:(NSString *)key;
- (BOOL)decodeArrayOfDoubles:(double*)values count:(NSInteger)count forKey:(NSString *)key;
- (BOOL)decodeArrayOfFloats:(float*)values count:(NSInteger)count forKey:(NSString *)key;
- (id)decodeNXObject;
- (id)decodePropertyList;

- (void)finishDecoding;
- (NSString *)nextGenericKey;
- (void)replaceObject:(id)objectTarget withObject:(id)objectSource;

- (BOOL)validateAndIndexData:(NSData *)data error:(NSError **)error;
- (BOOL)validateAndIndexClasses:(const void*)data length:(NSUInteger)length;
- (BOOL)validateAndIndexKeys:(const void*)data length:(NSUInteger)length;
- (BOOL)validateAndIndexObjects:(const void*)data length:(NSUInteger)length;
- (BOOL)validateAndIndexValues:(const void*)data length:(NSUInteger)length;

@end
