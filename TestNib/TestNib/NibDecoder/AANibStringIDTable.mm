//
//  AANibStringIDTable.m
//  TestNib
//
//  Created by Alexander on 5/10/16.
//  Copyright © 2016 Intellectsoft Group. All rights reserved.
//

#import "AANibStringIDTable.h"

typedef struct AAStringIDTableBucket {
    NSString* key;
    NSUInteger hash;
    struct AAStringIDTableBucket* bucket;
} AAStringIDTableBucket;

@implementation AANibStringIDTable  {
    struct AAStringIDTableBucket **_table;
    struct AAStringIDTableBucket *_buckets;
    NSUInteger _count;
    NSUInteger _hashMask;
}

- (id)initWithKeysTransferingOwnership:(NSString * __strong *)keys count:(NSUInteger)keyCount
{
    self = [super init];
    if (self) {

        int tableCount = 2;
        while (tableCount <= 2 * keyCount) {
            tableCount *= 2;
        }
        
        _table = (AAStringIDTableBucket **)calloc(sizeof(AAStringIDTableBucket *), tableCount);
        _buckets = (AAStringIDTableBucket *)calloc(sizeof(AAStringIDTableBucket), keyCount);
        _hashMask = tableCount - 1;
        _count = keyCount;
        
        for (int i = 0; i < _count; i++) {
            NSUInteger hash = [keys[i] hash];
            _buckets[i].hash = hash;
            _buckets[i].key = keys[i];
            
            NSUInteger tableIndex = _hashMask & hash;
            _buckets[i].bucket = _table[tableIndex];
            _table[tableIndex] = &_buckets[i];
        }
    }
    return self;
}

- (void)dealloc
{
    for (int i = 0; i < _count; i++) {
        _buckets[i].key = nil;
    }

    free(_table);
    free(_buckets);
}

- (bool)lookupKey:(NSString *)key identifier:(NSInteger *)identifier
{
    NSInteger sizeOfPointer = sizeof(id);
    NSUInteger hash = [key hash];
    AAStringIDTableBucket *bucket = _table[hash & _hashMask];
    if (bucket) {
        while (bucket->hash != hash || (bucket->key != key && ![bucket->key isEqualToString:key])) {
            bucket = bucket->bucket;
            if (!bucket) {
                return false;
            }
        }
        
        *identifier = 0xAAAAAAAAAAAAAAABLL * (((char *)bucket - (char *)_buckets) / sizeOfPointer); // >> 3
        if ( bucket->key != key ) {
            bucket->key = [key copy];
        }
        return true;
    }
    return false;
}

- (NSInteger)count
{
    return _count;
}

@end
