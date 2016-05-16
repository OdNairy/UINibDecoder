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

@implementation AANibStringIDTable

//----- (0000000000445680) ----------------------------------------------------
// UINibStringIDTable - (id)initWithKeysTransferingOwnership:(id *) count:(uint64_t)
- (id)initWithKeysTransferingOwnership:(NSString * __strong *)keys count:(NSUInteger)keyCount
{
    self = [super init];
    if (self) {
        int v8 = 2;
        int v9;
        do {
            v9 = v8;
            v8 *= 2;
        } while ( v9 <= 2 * keyCount);
        
        table = (AAStringIDTableBucket **)calloc(8, v9);
        buckets = (AAStringIDTableBucket *)calloc(sizeof(AAStringIDTableBucket), keyCount);
        hashMask = v9 - 1;
        count = keyCount;
        
        if (keyCount) {
            int v11 = 0;
            do
            {
                NSUInteger hash = [keys[v11] hash];
                //v13 = objc_msgSend_ptr(v7[v11], selRef_hash);
                buckets[v11].hash = hash;
                //*&v12[v10 + 8] = v13;
                buckets[v11].key = keys[v11];
                //*&v12[v10] = v7[v11];
                NSUInteger v14 = hashMask & hash;
                buckets[v11].bucket = table[v14];
                //*&v12[v10 + 16] = *(v6[1].isa + v14);
                table[v14] = &buckets[v11];
                //*(v6[1].isa + v14) = &v12[v10];
                v11 = v11 + 1;
            }
            while ( v11 < count );
        }
    }
    return self;
}

- (void)dealloc
{
    if (count) {
        for (int i = 0; i < self->count; i++) {
            self->buckets[i].key = nil;
            //objc_msgSend_ptr(self->buckets[v3].var0, selRef_release);
        }
    }
    free(self->table);
    free(self->buckets);
}

- (bool)lookupKey:(NSString *)key identifier:(NSInteger *)identifier
{
    NSUInteger hash = [key hash];
    AAStringIDTableBucket *bucket = self->table[hash & self->hashMask];
    if (bucket) {
        while (bucket->hash != hash || (bucket->key != key && ![bucket->key isEqualToString:key])) {
            bucket = bucket->bucket;
            if (!bucket) {
                return false;
            }
        }
        
        *identifier = 0xAAAAAAAAAAAAAAABLL * (((char *)bucket - (char *)self->buckets) >> 3);
        if ( bucket->key != key )
        {
            //[bucket->key release];
            bucket->key = [key copy];
        }
        return true;
    }
    return false;
}

- (NSInteger)count
{
    return self->count;
}

@end
