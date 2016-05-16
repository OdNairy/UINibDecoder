//
//  AANibStringIDTable.h
//  TestNib
//
//  Created by Alexander on 5/10/16.
//  Copyright © 2016 Intellectsoft Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AANibStringIDTable : NSObject {
    struct AAStringIDTableBucket **table;
    struct AAStringIDTableBucket *buckets;
    //struct UIStringIDTableBucket { id x1; struct UIStringIDTableBucket {} *x2; } *buckets;
    NSUInteger count;
    NSUInteger hashMask;
}

- (NSInteger)count;
- (id)initWithKeysTransferingOwnership:(NSString * __strong *)keys count:(NSUInteger)keyCount;
- (bool)lookupKey:(NSString *)key identifier:(NSInteger *)identifier;

@end