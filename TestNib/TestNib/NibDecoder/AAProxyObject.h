//
//  AAProxyObject.h
//  TestNib
//
//  Created by AB on 5/8/16.
//  Copyright © 2016 Intellectsoft Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAProxyObject : NSObject
@property (nonatomic, copy) NSString *proxiedObjectIdentifier;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

+ (void)addMappingFromIdentifier:(NSString *)identifier toObject:(AAProxyObject *)object forCoder:(NSCoder *)coder;
+ (void)addMappings:(NSDictionary *)mappings forCoder:(NSCoder *)coder;
+ (void)removeMappingsForCoder:(NSCoder *)coder;
+ (CFMutableDictionaryRef)proxyDecodingMap;
+ (id)mappedObjectForCoder:(NSCoder *)coder withIdentifier:(NSString *)identifier;

@end
