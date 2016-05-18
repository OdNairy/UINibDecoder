//
//  AANibStringIDTable.h
//  TestNib
//
//  Created by Alexander on 5/10/16.
//  Copyright © 2016 Intellectsoft Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AANibStringIDTable : NSObject

- (NSInteger)count;
- (id)initWithKeysTransferingOwnership:(NSString * __strong *)keys count:(NSUInteger)keyCount;
- (bool)lookupKey:(NSString *)key identifier:(NSInteger *)identifier;

@end