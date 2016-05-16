//
//  AAProxyObject.m
//  TestNib
//
//  Created by AB on 5/8/16.
//  Copyright © 2016 Intellectsoft Group. All rights reserved.
//

#import "AAProxyObject.h"

@implementation AAProxyObject

+ (CFMutableDictionaryRef)proxyDecodingMap {
    static CFMutableDictionaryRef result = NULL;
    if (!result) {
        result = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    return result;
}

+ (void)addMappingFromIdentifier:(NSString *)identifier toObject:(AAProxyObject *)object forCoder:(NSCoder *)coder {
    CFMutableDictionaryRef map = [self proxyDecodingMap];
    CFMutableDictionaryRef nestedDictionary = (CFMutableDictionaryRef)CFDictionaryGetValue(map, (__bridge const void *)(coder));
    if (!nestedDictionary) {
        nestedDictionary = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(map, (__bridge const void *)(coder), nestedDictionary);
        CFRelease(nestedDictionary);
    }
    CFDictionarySetValue(nestedDictionary, (__bridge const void *)(identifier), (__bridge const void *)(object));
}

+ (void)addMappings:(NSDictionary *)mappings forCoder:(NSCoder *)coder
{
    NSArray *keys = mappings.allKeys;
    for (NSString *key in keys) {
        id object = mappings[key];
        [self addMappingFromIdentifier:key toObject:object forCoder:coder];
    }
}

+ (id)mappedObjectForCoder:(NSCoder *)coder withIdentifier:(NSString *)identifier
{
    CFDictionaryRef dictionary = [self proxyDecodingMap];
    CFDictionaryRef nestedDictionary = CFDictionaryGetValue(dictionary, (__bridge const void *)(coder));
    if (nestedDictionary) {
        return CFDictionaryGetValue(nestedDictionary, (__bridge const void *)(identifier));
    }
    return nil;
}

+ (void)removeMappingsForCoder:(NSCoder *)coder
{
    CFMutableDictionaryRef dictionary = [self proxyDecodingMap];
    CFDictionaryRemoveValue(dictionary, (__bridge const void *)(coder));
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _proxiedObjectIdentifier = [[coder decodeObjectForKey:@"UIProxiedObjectIdentifier"] copy];
        AAProxyObject *proxy = [AAProxyObject mappedObjectForCoder:coder withIdentifier:self.proxiedObjectIdentifier];
        if (proxy) {
            return proxy;
        }
        else {
            NSLog(@"Missing proxy for identifier %@", self.proxiedObjectIdentifier);
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.proxiedObjectIdentifier forKey:@"UIProxiedObjectIdentifier"];
}

@end
