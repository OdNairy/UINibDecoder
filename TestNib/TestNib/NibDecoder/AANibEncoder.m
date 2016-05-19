//
//  AANibEncoder.m
//  TestNib
//
//  Created by AB on 5/8/16.
//  Copyright © 2016 Intellectsoft Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AANibEncoder.h"
#import "AANibCoderValue.h"

@implementation AANibEncoder {
    struct __CFDictionary *_objectsToObjectIDs;
    struct __CFDictionary *_objectIDsToObjects;
    struct __CFArray *_values;
    struct __CFSet *_encodedObjects;
    NSMutableData *_data;
    struct __CFDictionary *_replacements;
    unsigned int _nextObjectID;
    struct {
        unsigned int currentObjectID;
        unsigned int nextAnonymousKey;
    } _recursiveState;
    NSMutableSet *_objectsUniquedByValue;
    struct __CFSet *_objectsReplacedWithNil;
    id _delegate; //4
}

const CFDictionaryKeyCallBacks *UIRetainedIdentityKeyDictionaryCallbacks() {
    static CFDictionaryKeyCallBacks callbacks = {
        0, NULL, NULL, CFCopyDescription, 0, 0
    };
    callbacks.retain = kCFTypeDictionaryKeyCallBacks.retain;
    callbacks.release = kCFTypeDictionaryKeyCallBacks.release;
    return &callbacks;
}
const CFDictionaryValueCallBacks *UIRetainedIdentityValueDictionaryCallbacks() {
    static CFDictionaryValueCallBacks callbacks = {
        0, NULL, NULL, CFCopyDescription, 0
    };
    callbacks.retain = kCFTypeDictionaryValueCallBacks.retain;
    callbacks.release = kCFTypeDictionaryValueCallBacks.release;
    return &callbacks;
}
const CFSetCallBacks *UIRetainedIdentitySetCallbacks(){
    static CFSetCallBacks callbacks = {
        0, NULL, NULL, CFCopyDescription, 0, 0
    };
    callbacks.retain = kCFTypeSetCallBacks.retain;
    callbacks.release = kCFTypeSetCallBacks.release;
    return &callbacks;
}

unsigned int UINibArchiveIndexFromNumber(NSNumber *object)
{
    return [object unsignedIntValue];
}

- (instancetype)initForWritingWithMutableData:(NSMutableData *)data
{
    self = [super init];
    if (self) {
        _data = data;
        _objectsToObjectIDs = CFDictionaryCreateMutable(NULL, 0, UIRetainedIdentityKeyDictionaryCallbacks(), &kCFTypeDictionaryValueCallBacks);
        _objectIDsToObjects = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, UIRetainedIdentityValueDictionaryCallbacks());
        _replacements = CFDictionaryCreateMutable(NULL, 0, UIRetainedIdentityKeyDictionaryCallbacks(), UIRetainedIdentityValueDictionaryCallbacks());
        _values = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
        
        _encodedObjects = CFSetCreateMutable(NULL, 0, UIRetainedIdentitySetCallbacks());
        _objectsUniquedByValue = [NSMutableSet new];
        _objectsReplacedWithNil = CFSetCreateMutable(NULL, 0, UIRetainedIdentitySetCallbacks());
        
        NSObject *root = [[NSObject alloc] init];
        CFSetAddValue(_encodedObjects, (__bridge void *)root);
        NSNumber *objectID = [self assignObjectIDForObject:root];
        _nextObjectID = UINibArchiveIndexFromNumber(objectID);  //*(v4 + 15)
    }
    return self;
}

- (void)dealloc
{
}

- (NSNumber *)objectIDForObject:(id)object
{
    return CFDictionaryGetValue(_objectsToObjectIDs, (__bridge void *)object);
}

- (NSNumber *)assignObjectIDForObject:(id)object
{
    NSNumber *number = [NSNumber numberWithLongLong:_nextObjectID++];
    CFDictionarySetValue(_objectsToObjectIDs, (__bridge void *)object, (__bridge void *)number);
    CFDictionarySetValue(_objectIDsToObjects, (__bridge void *)number, (__bridge void *)object);
    return number;
}

- (bool)previouslyCodedObject:(id)object
{
    return [self objectIDForObject:object] != NULL;
}

- (void)appendValue:(AANibCoderValue *)value
{
    CFArrayAppendValue(_values, (__bridge void *)value);
}

- (Class)encodedClassForObject:(id)object
{
    Class result = [object classForKeyedArchiver];
    if (result) {
        return [result class];
    }
    return result;
}

- (NSString *)encodedClassNameForClass:(Class)class
{
    return NSStringFromClass(class);
}

- (NSString *)encodedClassNameForObject:(id)object
{
    Class classValue = [self encodedClassForObject:object];
    return [self encodedClassNameForClass:classValue];
}

- (bool)object:(id)object encodesWithCoderFromClass:(Class)classValue
{
    IMP imp = [[object class] instanceMethodForSelector:@selector(encodeWithCoder:)];
    return imp == [classValue instanceMethodForSelector:@selector(encodeWithCoder:)];
}

- (bool)object:(id)object encodesAsMemberAndWithCoderOfClass:(Class)classValue
{
    if ([object classForKeyedArchiver] == classValue) {
        return [self object:object encodesWithCoderFromClass:classValue];
    }
    return 0;
}

- (bool)shouldUniqueObjectByValue:(id)object
{
    if (![self object:object encodesAsMemberAndWithCoderOfClass:[NSString class]]) {
        return [self object:object encodesAsMemberAndWithCoderOfClass:[NSNumber class]];
    }
    return true;
}

/*- (id)replacementObjectForObject:(id)object forKey:(NSString *)key
{
    
}

/*
// DA33D0: using guessed type char *selRef_class;
// DBE8A8: using guessed type char *selRef_object_encodesAsMemberAndWithCoderOfClass_;
// DCEBD8: using guessed type __int64 *classRef_NSNumber;
// DCEBF0: using guessed type __int64 *classRef_NSString;

//----- (0000000000443BC1) ----------------------------------------------------
// UINibEncoder - (id)replacementObjectForObject:(id) forKey:(id)
id __cdecl -[UINibEncoder replacementObjectForObject:forKey:](struct UINibEncoder *self, SEL a2, id a3, id a4)
{
    id v4; // r15@1
    id v5; // rbx@1
    struct UINibEncoder *v6; // r14@1
    id result; // rax@3
    struct objc_object *v8; // r12@5
    void *v9; // rdi@10
    char v10; // ST17_1@11
    struct UINibEncoder::__CFDictionary *v11; // ST08_8@11
    void *v12; // rax@11
    __int64 v13; // rax@11
    void *v14; // rdi@11
    struct objc_object *v15; // rax@12
    
    v4 = a4;
    v5 = a3;
    v6 = self;
    if ( CFSetContainsValue(*(&self->objectsReplacedWithNil + 4), a3) || CFDictionaryContainsKey(self->replacements, v5) )
    {
        LODWORD(result) = CFDictionaryGetValue(self->replacements, v5);
        return result;
    }
    if ( !objc_msgSend_ptr(self, selRef_objectIDForObject_, v5) )
    {
        if ( objc_msgSend_ptr(self, selRef_shouldUniqueObjectByValue_, v5) )
        {
            v8 = objc_msgSend_ptr(*(&self->objectsUniquedByValue + 4), selRef_member_, v5);
            if ( v8 )
                goto LABEL_10;
            objc_msgSend_ptr(*(&self->objectsUniquedByValue + 4), selRef_addObject_, v5);
        }
        v8 = objc_msgSend_ptr(v5, selRef_replacementObjectForCoder_, self);
        if ( !v8 )
        {
        LABEL_17:
            CFSetAddValue(*(&v6->objectsReplacedWithNil + 4), v5);
            return 0LL;
        }
    LABEL_10:
        v9 = *(&self->delegate + 4);
        if ( !v9
            || ((v10 = objc_msgSend_ptr(v9, selRef_respondsToSelector_, selRef_nibCoder_willEncodeObject_forObject_forKey_),
                 v11 = v6->objectIDsToObjects,
                 v12 = UINumberWithNibArchiveIndex(v6->recursiveState.currentObjectID),
                 LODWORD(v13) = CFDictionaryGetValue(v11, v12),
                 v14 = *(&v6->delegate + 4),
                 !v10) ? (v15 = objc_msgSend_ptr(v14, selRef_nibCoder_willEncodeObject_, v6, v8)) : (v15 = objc_msgSend_ptr(v14, selRef_nibCoder_willEncodeObject_forObject_forKey_, v6, v8, v13, v4)),
                (v8 = v15) != 0LL) )
        {
            CFDictionarySetValue(v6->replacements, v5, v8);
            if ( !objc_msgSend_ptr(v6, selRef_objectIDForObject_, v8) )
                objc_msgSend_ptr(v6, selRef_assignObjectIDForObject_, v8);
            return v8;
        }
        goto LABEL_17;
    }
    return v5;
}
*/

- (void)serializeArray:(NSArray *)array
{
    [self encodeBool:YES forKey:@"NSInlinedValue"];
    for (id object in array) {
        [self encodeObject:object forKey:@"UINibEncoderEmptyKey"];
    }
}

- (void)serializeDictionary:(NSDictionary *)dictionary
{
    [self encodeBool:YES forKey:@"NSInlinedValue"];
    for (id key in dictionary) {
        id value = dictionary[key];
        [self encodeObject:key forKey:@"UINibEncoderEmptyKey"]; //TODO: check
        [self encodeObject:value forKey:@"UINibEncoderEmptyKey"];
    }
}

- (void)serializeSet:(NSSet *)set
{
    [self encodeBool:YES forKey:@"NSInlinedValue"];
    for (id value in set) {
        [self encodeObject:value forKey:@"UINibEncoderEmptyKey"];
    }
}

- (void)serializeObject:(id)object
{
    if ([self object:object encodesWithCoderFromClass:[NSArray class]]) {
        [self serializeArray:object];
    }
    else if ([self object:object encodesWithCoderFromClass:[NSDictionary class]]) {
        [self serializeDictionary:object];
    }
    else if ([self object:object encodesWithCoderFromClass:[NSSet class]]) {
        [self serializeSet:object];
    }
    else {
        [object encodeWithCoder:self];
    }
}

+ (NSData *)archivedDataWithRootObject:(id)object
{
    NSMutableData *data = [NSMutableData data];
    AANibEncoder *encoder = [[AANibEncoder alloc] initForWritingWithMutableData:data];
    [encoder encodeObject:object forKey:@"object"];
    [encoder finishEncoding];
    return data;
}

+ (BOOL)archiveRootObject:(id)object toFile:(NSString *)filePath
{
    NSData *data = [self archivedDataWithRootObject:object];
    return [data writeToFile:filePath atomically:YES];
}

- (void)finishEncoding
{
    void *pValues[0x81];
    const void **ppValues;
    
    CFMutableDictionaryRef v2 = CFDictionaryCreateMutable(NULL, 0, UIRetainedIdentityKeyDictionaryCallbacks(), &kCFTypeDictionaryValueCallBacks);
    const void *v7 = CFDictionaryGetValue(_objectIDsToObjects, (void *)[NSNumber numberWithLongLong:0]);
    CFDictionarySetValue(v2, v7, (void *)[NSNumber numberWithInteger:0]);
    CFIndex count = CFSetGetCount(_encodedObjects);
    if (count < 0x81) {
        ppValues = (const void **)&pValues;
    }
    else {
        ppValues = malloc(sizeof(id) * count);
    }
    
    CFSetGetValues(_encodedObjects, ppValues);
    CFIndex objectCount = CFSetGetCount(_encodedObjects);
    for (NSInteger i = 0; i < objectCount; i++) {
        if (ppValues != v7) {
            CFDictionarySetValue(v2, ppValues, (void *)[NSNumber numberWithInteger:i + 1]);
        }
    }
    
/*    objectCount = CFArrayGetCount(_values);
    for (NSInteger i = 0; i < objectCount; i++) {
        const char *value = CFArrayGetValueAtIndex(_values, i);
        if (value[20] == 10) {
            const void *v27 = CFDictionaryGetValue(_objectIDsToObjects, [NSNumber numberWithLongLong:value[24]]);
            if (CFSetContainsValue(_encodedObjects, v27)) {
                value[24] = UINibArchiveIndexFromNumber(CFDictionaryGetValue(v2, v27));
            }
            else {
                value[20] = 9;
                value[24] = 0;
            }
        }
        
        v32 = CFDictionaryGetValue(_objectIDsToObjects, [NSNumber numberWithLongLong:value[16]])
        v33 = CFDictionaryGetValue(v2, v32);
        value[16] = UINibArchiveIndexFromNumber(v33);
    }
    
    NSMutableDictionary *v54 = [NSMutableDictionary dictionary];
    NSMutableDictionary *v35 = [NSMutableDictionary dictionary];
    CFIndex v36 = CFSetGetCount(_encodedObjects);
    for (NSInteger i = 0; i < v36; i++) {
        Class v41 = [self encodedClassForObject:ppValues + i];
        NSString *v42 = [self encodedClassNameForClass:v41];
        const void *v44 = CFDictionaryGetValue(v2, ppValues);
        [v54 setObject:v42 forKey:v44];
        id v45 = [v55 objectForKey:v42];
        if (!v45) {
            v48 = [v41 classFallbacksForKeyedArchiver];
            if ([v45 count]) {
                [v35 setObject:v48 forKey:v42];
            }
        }
    }
    if (ppValues != (const void **)&pValues) {
        free(ppValues);
    }
    UIWriteArchiveToData(_data, 1, v54, v55, _values, @"UINibEncoderEmptyKey");*/
}

- (unsigned int)systemVersion
{
    return 2000;
}

- (NSInteger)versionForClassName:(NSString *)className
{
    Class classValue = NSClassFromString(className);
    if (classValue) {
        return [classValue version];
    }
    return NSNotFound;
}

- (bool)allowsKeyedCoding
{
    return true;
}

/*
//----- (000000000044482A) ----------------------------------------------------
// UINibEncoder - (void)encodeObject:(id) forKey:(id)
void __cdecl -[UINibEncoder encodeObject:forKey:](struct UINibEncoder *self, SEL a2, id a3, id a4)
{
    id v4; // r14@1
    void *v5; // rax@2
    void *v6; // r15@2
    void *v7; // r12@3
    void *v8; // rax@4
    void (*v9)(void *, const char *, ...); // r12@4
    void *v10; // ST08_8@4
    void *v11; // rax@4
    unsigned int v12; // eax@6
    void (__fastcall *v13)(struct UINibEncoder *, char *, void *); // r12@6
    char *v14; // rsi@6
    void *v15; // rdx@6
    void (__fastcall *v16)(struct UINibEncoder *, char *, void *); // rax@6
    void (__fastcall *v17)(struct UINibEncoder *, char *, void *); // r15@7
    unsigned int v18; // eax@9
    id v19; // rcx@9
    void (__fastcall *v20)(struct UINibEncoder *, char *, void *); // r14@9
    void *v21; // rax@9
    struct anon_struct_1048 v22; // ST10_8@9
    
    v4 = a4;
    if ( !a3 || (v5 = objc_msgSend_ptr(self, selRef_replacementObjectForObject_forKey_), (v6 = v5) == 0LL) )
    {
        v17 = *objc_msgSend_ptr;
        v14 = selRef_appendValue_;
        v15 = objc_msgSend_ptr(
                               classRef_UINibCoderValue,
                               selRef_nibValueRepresentingNilReferenceForKey_scope_,
                               v4,
                               self->recursiveState.currentObjectID);
        v16 = v17;
        goto LABEL_8;
    }
    v7 = objc_msgSend_ptr(self, selRef_objectIDForObject_, v5);
    if ( !v7 )
    {
        v8 = objc_msgSend_ptr(classRef_NSAssertionHandler, selRef_currentHandler);
        v9 = *objc_msgSend_ptr;
        v10 = v8;
        v11 = objc_msgSend_ptr(
                               classRef_NSString,
                               selRef_stringWithUTF8String_,
                               "/SourceCache/UIKit_Sim/UIKit-3318.16.14/UINibEncoder.m");
        v9(
           v10,
           selRef_handleFailureInMethod_object_file_lineNumber_description_,
           a2,
           self,
           v11,
           304LL,
           &cfstr_ThisShouldHave);
        v7 = 0LL;
    }
    if ( CFSetContainsValue(self->encodedObjects, v6) )
    {
        v12 = UINibArchiveIndexFromNumber(v7);
        v13 = *objc_msgSend_ptr;
        v14 = selRef_appendValue_;
        v15 = objc_msgSend_ptr(
                               classRef_UINibCoderValue,
                               selRef_nibValueForObjectReference_key_scope_,
                               v12,
                               v4,
                               self->recursiveState.currentObjectID);
        v16 = v13;
    LABEL_8:
        v16(self, v14, v15);
        return;
    }
    CFSetAddValue(self->encodedObjects, v6);
    v18 = UINibArchiveIndexFromNumber(v7);
    v19 = v4;
    v20 = *objc_msgSend_ptr;
    v21 = objc_msgSend_ptr(
                           classRef_UINibCoderValue,
                           selRef_nibValueForObjectReference_key_scope_,
                           v18,
                           v19,
                           self->recursiveState.currentObjectID);
    v20(self, selRef_appendValue_, v21);
    v22 = self->recursiveState;
    self->recursiveState = 0LL;
    self->recursiveState.currentObjectID = UINibArchiveIndexFromNumber(v7);
    v20(self, selRef_serializeObject_, v6);
    self->recursiveState = v22;
}
// 7E78B6: using guessed type int __fastcall CFSetAddValue(_QWORD, _QWORD);
// 7E78BC: using guessed type int __fastcall CFSetContainsValue(_QWORD, _QWORD);
// BC6130: using guessed type __CFString cfstr_ThisShouldHave;
// DA3538: using guessed type char *selRef_currentHandler;
// DA3540: using guessed type char *selRef_stringWithUTF8String_;
// DA3548: using guessed type char *selRef_handleFailureInMethod_object_file_lineNumber_description_;
// DBE880: using guessed type char *selRef_objectIDForObject_;
// DBE8F8: using guessed type char *selRef_replacementObjectForObject_forKey_;
// DBE900: using guessed type char *selRef_nibValueForObjectReference_key_scope_;
// DBE908: using guessed type char *selRef_appendValue_;
// DBE910: using guessed type char *selRef_serializeObject_;
// DBE918: using guessed type char *selRef_nibValueRepresentingNilReferenceForKey_scope_;
// DCEBE8: using guessed type __int64 *classRef_NSAssertionHandler;
// DCEBF0: using guessed type __int64 *classRef_NSString;
// DD0720: using guessed type void *classRef_UINibCoderValue;
// DDC818: using guessed type __int64 OBJC_IVAR___UINibEncoder_encodedObjects;
// DDC830: using guessed type __int64 OBJC_IVAR___UINibEncoder_recursiveState;

//----- (0000000000444A34) ----------------------------------------------------
// UINibEncoder - (void)encodeConditionalObject:(id) forKey:(id)
void __cdecl -[UINibEncoder encodeConditionalObject:forKey:](struct UINibEncoder *self, SEL a2, id a3, id a4)
{
    id v4; // r14@1
    id v5; // rbx@1
    int (__fastcall *v6)(__int64 *, char *); // r12@3
    void *v7; // rax@3
    __int64 v8; // rax@3
    __int64 v9; // rax@4
    __int64 v10; // r13@4
    __int64 v11; // rax@4
    void *v12; // rax@5
    void *v13; // rbx@5
    void *v14; // rax@6
    unsigned int v15; // eax@8
    void (__fastcall *v16)(struct UINibEncoder *, char *, void *); // r12@8
    char *v17; // rsi@8
    void *v18; // rdx@8
    void (__fastcall *v19)(struct UINibEncoder *, char *, void *); // rax@8
    void (__fastcall *v20)(struct UINibEncoder *, char *, void *); // rbx@9
    __CFString *v21; // [sp+0h] [bp-40h]@0
    const char *v22; // [sp+8h] [bp-38h]@0
    
    v4 = a4;
    v5 = a3;
    if ( !a3 )
        goto LABEL_13;
    if ( objc_msgSend_ptr(self, selRef_shouldUniqueObjectByValue_) )
    {
        v6 = *objc_msgSend_ptr;
        v7 = objc_msgSend_ptr(v5, selRef_class);
        LODWORD(v8) = NSStringFromClass(v7);
        if ( !(v6)(classRef_NSString, selRef_stringWithFormat_, &cfstr_ThisCoderDoesN, v8) )
        {
            LODWORD(v9) = v6(classRef_NSAssertionHandler, selRef_currentHandler);
            v10 = v9;
            LODWORD(v11) = (v6)(
                                classRef_NSString,
                                selRef_stringWithUTF8String_,
                                "/SourceCache/UIKit_Sim/UIKit-3318.16.14/UINibEncoder.m");
            v22 = "message";
            v21 = &cfstr_InvalidParamet;
            (v6)(v10, selRef_handleFailureInMethod_object_file_lineNumber_description_, a2, self, v11, 325LL);
        }
    }
    v12 = objc_msgSend_ptr(self, selRef_replacementObjectForObject_forKey_, v5, v4, v21, v22);
    v13 = v12;
    if ( v12 )
    {
        v14 = objc_msgSend_ptr(self, selRef_objectIDForObject_, v12);
        if ( !v14 )
            v14 = objc_msgSend_ptr(self, selRef_assignObjectIDForObject_, v13);
        v15 = UINibArchiveIndexFromNumber(v14);
        v16 = *objc_msgSend_ptr;
        v17 = selRef_appendValue_;
        v18 = objc_msgSend_ptr(
                               classRef_UINibCoderValue,
                               selRef_nibValueForObjectReference_key_scope_,
                               v15,
                               v4,
                               self->recursiveState.currentObjectID);
        v19 = v16;
    }
    else
    {
    LABEL_13:
        v20 = *objc_msgSend_ptr;
        v17 = selRef_appendValue_;
        v18 = objc_msgSend_ptr(
                               classRef_UINibCoderValue,
                               selRef_nibValueRepresentingNilReferenceForKey_scope_,
                               v4,
                               self->recursiveState.currentObjectID);
        v19 = v20;
    }
    v19(self, v17, v18);
}
*/

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForBoolean:boolv key:key scope:_recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeInt:(int)intv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForInteger:intv key:key scope:_recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeInt32:(int32_t)intv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForInt32:intv key:key scope:_recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeInt64:(int64_t)intv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForInt64:intv key:key scope:_recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeInteger:(NSInteger)intv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForInteger:intv key:key scope:_recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeFloat:(float)realv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForFloat:realv key:key scope:_recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeDouble:(double)realv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForDouble:realv key:key scope:_recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeBytes:(const uint8_t *)bytesp length:(NSUInteger)lenv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForBytes:bytesp length:lenv key:key scope:_recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeArrayOfDoubles:(double *)doubles count:(NSInteger)count forKey:(NSString *)key
{
    NSMutableData *data = [NSMutableData data];
    char type = 7;
    [data appendBytes:&type length:1];
    for (NSInteger i = 0; i < count; i++, doubles++) {
        [data appendBytes:doubles length:sizeof(double)];
    }
    [self encodeBytes:[data bytes] length:[data length] forKey:key];
}

- (void)encodeArrayOfFloats:(float *)floats count:(NSInteger)count forKey:(NSString *)key
{
    NSMutableData *data = [NSMutableData data];
    char type = 6;
    [data appendBytes:&type length:1];
    for (NSInteger i = 0; i < count; i++, floats++) {
        [data appendBytes:floats length:sizeof(float)];
    }
    [self encodeBytes:[data bytes] length:[data length] forKey:key];
}

- (void)encodeArrayOfCGFloats:(CGFloat *)floats count:(NSInteger)count forKey:(NSString *)key
{
    //ARMv64 only?
    [self encodeArrayOfDoubles:floats count:count forKey:key];
}

- (void)encodeCGPoint:(CGPoint)point forKey:(NSString *)key
{
    [self encodeArrayOfCGFloats:(CGFloat *)&point.x count:2 forKey:key];
}

- (void)encodeCGSize:(CGSize)size forKey:(NSString *)key
{
    [self encodeArrayOfCGFloats:(CGFloat *)&size.width count:2 forKey:key];
}

- (void)encodeCGRect:(CGRect)rect forKey:(NSString *)key
{
    [self encodeArrayOfCGFloats:(CGFloat *)&rect.origin.x count:4 forKey:key];
}

- (void)encodeCGAffineTransform:(CGAffineTransform)transform forKey:(NSString *)key
{
    [self encodeArrayOfCGFloats:(CGFloat *)&transform.a count:6 forKey:key];
}

- (void)encodeUIEdgeInsets:(UIEdgeInsets)insets forKey:(NSString *)key
{
    [self encodeArrayOfCGFloats:(CGFloat *)&insets count:4 forKey:key];
}

- (NSString *)nextGenericKey {
    _recursiveState.nextAnonymousKey++;
    return [NSString stringWithFormat:@"$%ld", _recursiveState.nextAnonymousKey];
}

- (void)encodeObject:(id)object
{
    NSString *key = [self nextGenericKey];
    [self encodeObject:object forKey:key];
}

- (void)encodeRootObject:(id)rootObject
{
    NSString *key = [self nextGenericKey];
    [self encodeObject:rootObject forKey:key];
}

- (void)encodeBycopyObject:(id)anObject
{
    NSString *key = [self nextGenericKey];
    [self encodeObject:anObject forKey:key];
}

- (void)encodeByrefObject:(id)anObject
{
    NSString *key = [self nextGenericKey];
    [self encodeObject:anObject forKey:key];
}

- (void)encodeConditionalObject:(id)object
{
    NSString *key = [self nextGenericKey];
    [self encodeConditionalObject:object forKey:key];
}

- (void)encodeValuesOfObjCTypes:(const char *)types, ...
{
    NSAssert(NO, @""); //unknown stru_B9FBB0
}

- (void)encodeArrayOfObjCType:(const char *)type count:(NSUInteger)count at:(const void *)array
{
    NSAssert(NO, @""); //unknown stru_B9FBB0
}

- (void)encodeBytes:(const void *)byteaddr length:(NSUInteger)length
{
    NSString *key = [self nextGenericKey];
    [self encodeBytes:byteaddr length:length forKey:key];
}

- (void)encodeValueOfObjCType:(const char *)typeptr at:(const void *)addr
{
    if (strlen(typeptr) != 1) {
        return;
    }
    
    //should be switch
    char type = *typeptr;
    if (type <= 57) {
        if (type == 42) {
            NSString *key = [self nextGenericKey];
            uint8_t *data = *(uint8_t **)addr; //TODO: check??
            [self encodeBytes:data length:strlen((char *)data) + 1 forKey:key];
        }
        return;
    }
    if (type > 99) {
        NSInteger intValue;
        if (type > 112) {
            if (type == 113) {
                intValue = *(NSInteger *)addr; //TODO: check
            }
            else if (type != 115) {
                return;
            }
            intValue = *(NSInteger *)addr; //TODO: check
        }
        else {
            if (type == 100) {
                NSString *key = [self nextGenericKey];
                double doubleValue = *(double*)addr; //TODO: check??
                [self encodeDouble:doubleValue forKey:key];
                return;
            }
            if (type == 102) {
                NSString *key = [self nextGenericKey];
                double doubleValue = *(double*)addr; //TODO: check??
                [self encodeDouble:doubleValue forKey:key];
                return;
            }
            if (type != 105) {
                return;
            }
            intValue = *(NSInteger *)addr; //TODO: check
        }
        NSString *key = [self nextGenericKey];
        [self encodeInteger:intValue forKey:key];
    }
    if (type == 58) {
        NSString *str = NSStringFromSelector(*(SEL *)addr);
        NSString *key = [self nextGenericKey];
        [self encodeObject:str forKey:key];
        return;
    }
    if (type == 64) {
        id object = *(id __unsafe_unretained *)addr;
        NSString *key = [self nextGenericKey];
        [self encodeObject:object forKey:key];
        return;
    }
    if (type == 66) {
        BOOL boolValue = *(BOOL*)addr;
        NSString *key = [self nextGenericKey];
        [self encodeBool:boolValue forKey:key];
        return;
    }
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

@end

/*
 //----- (000000000045F683) ----------------------------------------------------
__int64 __fastcall UIWriteArchiveToData(void *a1, int a2, void *a3, void *a4, __int64 a5, __int64 a6)
{
  __int64 v6; // r14@1
  void *v7; // r13@1
  __int64 v8; // rax@1
  __int64 v9; // r15@1
  __int64 v10; // rbx@2
  __int64 v11; // rax@3
  void *(*v12)(void *, const char *, ...); // rbx@4
  void *v13; // rcx@4
  int v14; // er14@5
  int v15; // edx@6
  unsigned __int64 v16; // r15@8
  __int64 v17; // ST98_8@11
  const char *v18; // r12@11
  unsigned int v19; // er14@11
  void *v20; // rax@11
  unsigned int v21; // er13@13
  void *v22; // r15@13
  void *v23; // rax@13
  __int64 v24; // rax@13
  unsigned int v25; // er15@13
  unsigned int v26; // er14@14
  __int64 v27; // r13@14
  __int64 v28; // rax@15
  __int64 v29; // r15@15
  unsigned int v30; // eax@15
  void (*v31)(void *, const char *, ...); // rbx@16
  unsigned int v32; // ebx@17
  unsigned int v33; // ST98_4@17
  void *v34; // STA0_8@17
  void *v35; // rax@17
  void *v36; // r14@17
  void *v37; // rax@17
  void *v38; // rax@18
  unsigned int v39; // er14@18
  int v40; // ST98_4@18
  unsigned int v41; // eax@19
  void *v42; // r14@22
  void *v43; // rax@22
  void *v44; // rax@23
  void *v45; // r14@23
  void *v46; // rbx@23
  __int64 v47; // r13@24
  unsigned __int64 v48; // r12@25
  void *v49; // r15@30
  __int64 v50; // r13@31
  int v51; // er14@31
  signed int v52; // eax@32
  unsigned __int64 v53; // r12@34
  __int64 v54; // rbx@37
  void *v55; // rax@37
  int (__fastcall *v56)(void *, char *, __int128 *, char *, signed __int64); // r14@39
  void *v57; // r13@39
  void *v58; // rax@39
  signed __int64 v59; // rbx@41
  __int64 v60; // r15@44
  void *v61; // rax@44
  void *v62; // r12@44
  const char *v63; // rax@44
  unsigned int v64; // ebx@44
  unsigned int v65; // esi@44
  void *v66; // rbx@44
  void *v67; // rax@44
  void *v68; // r15@44
  __int64 v69; // r12@45
  unsigned __int64 v70; // r13@46
  void *v71; // rax@49
  void *v72; // rax@53
  void *v73; // rbx@53
  __int64 v74; // rax@53
  __int64 v75; // rax@53
  __int64 v76; // r12@54
  int (__fastcall *v77)(void *, char *, void *); // rbx@55
  void *v78; // rax@55
  void *v79; // r15@55
  void *v80; // rax@55
  void *v81; // rax@55
  void *v82; // ST90_8@55
  void *v83; // rax@55
  void *v84; // rax@55
  void *v85; // r15@55
  unsigned int v86; // eax@55
  unsigned int v87; // esi@55
  unsigned int v88; // esi@57
  void *v89; // ST80_8@60
  void (*v90)(void *, const char *, ...); // r12@60
  void *v91; // r15@60
  int v92; // ebx@60
  int v93; // ebx@60
  int v95; // [sp+14h] [bp-49Ch]@1
  void *v96; // [sp+20h] [bp-490h]@13
  __int64 v97; // [sp+28h] [bp-488h]@13
  void *v98; // [sp+30h] [bp-480h]@1
  void *v99; // [sp+38h] [bp-478h]@13
  void *v100; // [sp+40h] [bp-470h]@13
  __int64 v101; // [sp+48h] [bp-468h]@4
  __int64 v102; // [sp+48h] [bp-468h]@40
  void *v103; // [sp+50h] [bp-460h]@1
  void *v104; // [sp+58h] [bp-458h]@1
  void *v105; // [sp+58h] [bp-458h]@13
  void *v106; // [sp+60h] [bp-450h]@4
  __int64 v107; // [sp+68h] [bp-448h]@1
  void *v108; // [sp+68h] [bp-448h]@39
  int v109; // [sp+70h] [bp-440h]@8
  unsigned int v110; // [sp+70h] [bp-440h]@44
  __int64 v111; // [sp+78h] [bp-438h]@5
  const char *v112; // [sp+78h] [bp-438h]@44
  __int64 v113; // [sp+78h] [bp-438h]@53
  unsigned __int64 v114; // [sp+80h] [bp-430h]@6
  __int64 v115; // [sp+80h] [bp-430h]@13
  signed __int64 v116; // [sp+80h] [bp-430h]@44
  void *v117; // [sp+80h] [bp-430h]@53
  void *v118; // [sp+88h] [bp-428h]@4
  void *v119; // [sp+88h] [bp-428h]@23
  int v120; // [sp+90h] [bp-420h]@8
  unsigned int v121; // [sp+90h] [bp-420h]@14
  void *v122; // [sp+90h] [bp-420h]@44
  signed int v123; // [sp+98h] [bp-418h]@34
  void *v124; // [sp+98h] [bp-418h]@55
  unsigned int v125; // [sp+A0h] [bp-410h]@16
  void *v126; // [sp+A0h] [bp-410h]@23
  char v127; // [sp+AFh] [bp-401h]@51
  __int128 v128; // [sp+B0h] [bp-400h]@44
  __int128 v129; // [sp+C0h] [bp-3F0h]@44
  __int128 v130; // [sp+D0h] [bp-3E0h]@44
  __int128 v131; // [sp+E0h] [bp-3D0h]@44
  __int128 v132; // [sp+F0h] [bp-3C0h]@39
  __int128 v133; // [sp+100h] [bp-3B0h]@39
  __int128 v134; // [sp+110h] [bp-3A0h]@39
  __int128 v135; // [sp+120h] [bp-390h]@39
  __int128 v136; // [sp+130h] [bp-380h]@30
  __int128 v137; // [sp+140h] [bp-370h]@30
  __int128 v138; // [sp+150h] [bp-360h]@30
  __int128 v139; // [sp+160h] [bp-350h]@30
  __int128 v140; // [sp+170h] [bp-340h]@23
  __int128 v141; // [sp+180h] [bp-330h]@23
  __int128 v142; // [sp+190h] [bp-320h]@23
  __int128 v143; // [sp+1A0h] [bp-310h]@23
  __int128 v144; // [sp+1B0h] [bp-300h]@4
  __int128 v145; // [sp+1C0h] [bp-2F0h]@4
  __int128 v146; // [sp+1D0h] [bp-2E0h]@4
  __int128 v147; // [sp+1E0h] [bp-2D0h]@4
  int v148; // [sp+1FCh] [bp-2B4h]@18
  char v149; // [sp+200h] [bp-2B0h]@44
  char v150; // [sp+280h] [bp-230h]@39
  char v151; // [sp+300h] [bp-1B0h]@30
  char v152; // [sp+380h] [bp-130h]@23
  char v153; // [sp+400h] [bp-B0h]@4
  __int64 v154; // [sp+480h] [bp-30h]@1

  v107 = a6;
  v6 = a5;
  v103 = a4;
  v98 = a3;
  v95 = a2;
  v154 = *__stack_chk_guard_ptr;
  v7 = objc_msgSend_ptr(classRef_NSMutableSet, selRef_set);
  v104 = v7;
  LODWORD(v8) = CFArrayGetCount(v6);
  v9 = v8;
  if ( v8 > 0 )
  {
    v10 = 0LL;
    do
    {
      LODWORD(v11) = CFArrayGetValueAtIndex(v6, v10);
      objc_msgSend_ptr(v7, selRef_addObject_, *(v11 + 8));
      ++v10;
    }
    while ( v9 != v10 );
  }
  v101 = v6;
  v12 = *objc_msgSend_ptr;
  v118 = objc_msgSend_ptr(classRef_NSMutableDictionary, selRef_dictionary);
  v106 = v12(classRef_NSMutableData, selRef_data);
  v147 = 0LL;
  v146 = 0LL;
  v145 = 0LL;
  v144 = 0LL;
  v13 = v12(v7, selRef_countByEnumeratingWithState_objects_count_, &v144, &v153, 16LL);
  if ( v13 )
  {
    v111 = *v145;
    v14 = 0;
    do
    {
      v114 = v13;
      v15 = v13 - 1;
      if ( v13 <= 1 )
        v15 = 0;
      v109 = v15;
      v120 = v14;
      v16 = 0LL;
      do
      {
        if ( *v145 != v111 )
          objc_enumerationMutation(v7);
        v17 = *(*(&v144 + 1) + 8 * v16);
        v18 = v12(*(*(&v144 + 1) + 8 * v16), selRef_UTF8String);
        v19 = strlen(v18);
        UIAppendVInt32ToData(v106, v19);
        v7 = v104;
        v12(v106, selRef_appendBytes_length_, v18, v19);
        v20 = UINumberWithNibArchiveIndex(v120 + v16);
        v12(v118, selRef_setObject_forKey_, v20, v17);
        ++v16;
      }
      while ( v16 < v114 );
      v14 = v120 + v109 + 1;
      v13 = objc_msgSend_ptr(v104, selRef_countByEnumeratingWithState_objects_count_, &v144, &v153, 16LL);
    }
    while ( v13 );
  }
  v105 = v7;
  v97 = UICreateOrderedAndStrippedCoderValues(v101, v107);
  v96 = v12(classRef_NSMutableData, selRef_data);
  v99 = v12(classRef_NSMutableDictionary, selRef_dictionary);
  v100 = v12(classRef_NSMutableDictionary, selRef_dictionary);
  v21 = 0;
  v22 = UINumberWithNibArchiveIndex(0);
  v23 = UINumberWithNibArchiveIndex(0);
  v12(v99, selRef_setObject_forKey_, v22, v23);
  LODWORD(v24) = CFArrayGetCount(v97);
  v115 = v24;
  v25 = 0;
  if ( v24 <= 0 )
    goto LABEL_63;
  v121 = 0;
  v26 = 0;
  v27 = 0LL;
  do
  {
    LODWORD(v28) = CFArrayGetValueAtIndex(v97, v27);
    v29 = v28;
    v30 = *(v28 + 16);
    if ( v30 == v121 )
    {
      v125 = v26;
      v31 = *objc_msgSend_ptr;
    }
    else
    {
      v32 = v30;
      v33 = v30;
      v34 = UINumberWithNibArchiveIndex(v27);
      v35 = UINumberWithNibArchiveIndex(v32);
      v31 = *objc_msgSend_ptr;
      objc_msgSend_ptr(v99, selRef_setObject_forKey_, v34, v35);
      v36 = UINumberWithNibArchiveIndex(v26);
      v37 = UINumberWithNibArchiveIndex(v121);
      v31(v100, selRef_setObject_forKey_, v36, v37);
      v125 = 0;
      v121 = v33;
    }
    v38 = (v31)(v118, selRef_objectForKey_, *(v29 + 8));
    v39 = UINibArchiveIndexFromNumber(v38);
    v40 = UIFixedByteLengthForType(*(v29 + 20));
    UIAppendVInt32ToData(v96, v39);
    LOBYTE(v148) = *(v29 + 20);
    v31(v96, selRef_appendBytes_length_, &v148, 1LL);
    if ( v40 == -1 )
    {
      v41 = objc_msgSend_ptr(v29, selRef_byteLength);
      UIAppendVInt32ToData(v96, v41);
    }
    UIAppendBytesForValueToData(v96, v29);
    v26 = v125 + 1;
    ++v27;
  }
  while ( v115 != v27 );
  v25 = v121;
  v12 = *objc_msgSend_ptr;
  v21 = v125 + 1;
  if ( v121 != -1 )
  {
LABEL_63:
    v42 = UINumberWithNibArchiveIndex(v21);
    v43 = UINumberWithNibArchiveIndex(v25);
    objc_msgSend_ptr(v100, selRef_setObject_forKey_, v42, v43);
  }
  v44 = v12(v98, selRef_allValues);
  v119 = v12(classRef_NSMutableSet, selRef_setWithArray_, v44);
  v126 = v12(classRef_NSMutableDictionary, selRef_dictionary);
  v143 = 0LL;
  v142 = 0LL;
  v141 = 0LL;
  v140 = 0LL;
  v45 = v12(v103, selRef_allValues);
  v46 = v12(v45, selRef_countByEnumeratingWithState_objects_count_, &v140, &v152, 16LL);
  if ( v46 )
  {
    v47 = *v141;
    do
    {
      v48 = 0LL;
      do
      {
        if ( *v141 != v47 )
          objc_enumerationMutation(v45);
        objc_msgSend_ptr(v119, selRef_addObjectsFromArray_, *(*(&v140 + 1) + 8 * v48++));
      }
      while ( v48 < v46 );
      v46 = objc_msgSend_ptr(v45, selRef_countByEnumeratingWithState_objects_count_, &v140, &v152, 16LL);
    }
    while ( v46 );
  }
  v139 = 0LL;
  v138 = 0LL;
  v137 = 0LL;
  v136 = 0LL;
  v49 = objc_msgSend_ptr(v119, selRef_countByEnumeratingWithState_objects_count_, &v136, &v151, 16LL);
  if ( v49 )
  {
    v50 = *v137;
    v51 = 0;
    do
    {
      v52 = 1;
      if ( v49 > 1 )
        v52 = v49;
      v123 = v52;
      v53 = 0LL;
      do
      {
        if ( *v137 != v50 )
          objc_enumerationMutation(v119);
        v54 = *(*(&v136 + 1) + 8 * v53);
        v55 = UINumberWithNibArchiveIndex(v51 + v53);
        objc_msgSend_ptr(v126, selRef_setObject_forKey_, v55, v54);
        ++v53;
      }
      while ( v53 < v49 );
      v51 += v123;
      v49 = objc_msgSend_ptr(v119, selRef_countByEnumeratingWithState_objects_count_, &v136, &v151, 16LL);
    }
    while ( v49 );
  }
  v56 = *objc_msgSend_ptr;
  v57 = objc_msgSend_ptr(classRef_NSMutableData, selRef_data);
  v135 = 0LL;
  v134 = 0LL;
  v133 = 0LL;
  v132 = 0LL;
  LODWORD(v58) = v56(v119, selRef_countByEnumeratingWithState_objects_count_, &v132, &v150, 16LL);
  v108 = v58;
  if ( v58 )
  {
    v102 = *v133;
    do
    {
      v59 = 0LL;
      do
      {
        if ( *v133 != v102 )
          objc_enumerationMutation(v119);
        v60 = *(*(&v132 + 1) + 8 * v59);
        v116 = v59;
        LODWORD(v61) = (v56)(v103, selRef_objectForKey_, *(*(&v132 + 1) + 8 * v59));
        v62 = v61;
        v122 = v61;
        LODWORD(v63) = (v56)(v60, selRef_UTF8String);
        v112 = v63;
        v64 = strlen(v63);
        v110 = v64;
        LODWORD(v60) = (v56)(v62, selRef_count);
        v65 = v64 + 1;
        v66 = v57;
        UIAppendVInt32ToData(v57, v65);
        UIAppendVInt32ToData(v57, v60);
        v131 = 0LL;
        v130 = 0LL;
        v129 = 0LL;
        v128 = 0LL;
        LODWORD(v67) = v56(v62, selRef_countByEnumeratingWithState_objects_count_, &v128, &v149, 16LL);
        v68 = v67;
        if ( v67 )
        {
          v69 = *v129;
          do
          {
            v70 = 0LL;
            do
            {
              if ( *v129 != v69 )
                objc_enumerationMutation(v122);
              LODWORD(v71) = (v56)(v126, selRef_objectForKey_, *(*(&v128 + 1) + 8 * v70));
              v148 = UINibArchiveIndexFromNumber(v71);
              (v56)(v66, selRef_appendBytes_length_, &v148, 4LL);
              ++v70;
            }
            while ( v70 < v68 );
            v68 = objc_msgSend_ptr(v122, selRef_countByEnumeratingWithState_objects_count_, &v128, &v149, 16LL);
          }
          while ( v68 );
        }
        (v56)(v66, selRef_appendBytes_length_, v112, v110);
        v127 = 0;
        v57 = v66;
        (v56)(v66, selRef_appendBytes_length_, &v127, 1LL);
        v59 = v116 + 1;
      }
      while ( v116 + 1 < v108 );
      v108 = objc_msgSend_ptr(v119, selRef_countByEnumeratingWithState_objects_count_, &v132, &v150, 16LL);
    }
    while ( v108 );
  }
  LODWORD(v72) = (v56)(classRef_NSMutableData, selRef_data);
  v73 = v72;
  v117 = v72;
  LODWORD(v74) = (v56)(v98, selRef_allKeys);
  LODWORD(v75) = (v56)(v74, selRef_count);
  v113 = v75;
  if ( v75 > 0 )
  {
    v76 = 0LL;
    do
    {
      v77 = *objc_msgSend_ptr;
      v78 = objc_msgSend_ptr(classRef_NSNumber, selRef_numberWithInteger_, v76);
      v79 = v78;
      LODWORD(v80) = v77(v98, selRef_objectForKey_, v78);
      LODWORD(v81) = v77(v126, selRef_objectForKey_, v80);
      v82 = v81;
      LODWORD(v83) = v77(v99, selRef_objectForKey_, v79);
      v124 = v83;
      LODWORD(v84) = v77(v100, selRef_objectForKey_, v79);
      v85 = v84;
      v86 = UINibArchiveIndexFromNumber(v82);
      v73 = v117;
      UIAppendVInt32ToData(v117, v86);
      v87 = 0;
      if ( v124 )
        v87 = UINibArchiveIndexFromNumber(v124);
      UIAppendVInt32ToData(v117, v87);
      v88 = 0;
      if ( v85 )
        v88 = UINibArchiveIndexFromNumber(v85);
      UIAppendVInt32ToData(v117, v88);
      ++v76;
    }
    while ( v113 != v76 );
  }
  v89 = v73;
  v90 = *objc_msgSend_ptr;
  objc_msgSend_ptr(a1, selRef_appendBytes_length_, "NIBArchive", 10LL);
  v148 = v95;
  v90(a1, selRef_appendBytes_length_, &v148, 4LL);
  v148 = UICurrentCoderVersion;
  v90(a1, selRef_appendBytes_length_, &v148, 4LL);
  v148 = (v90)(v98, selRef_count);
  v90(a1, selRef_appendBytes_length_, &v148, 4LL);
  v148 = 50;
  v90(a1, selRef_appendBytes_length_, &v148, 4LL);
  v148 = (v90)(v105, selRef_count);
  v90(a1, selRef_appendBytes_length_, &v148, 4LL);
  v148 = ((v90)(v73, selRef_length) + 50);
  v90(a1, selRef_appendBytes_length_, &v148, 4LL);
  v148 = CFArrayGetCount(v97);
  v90(a1, selRef_appendBytes_length_, &v148, 4LL);
  v91 = v73;
  v92 = (v90)(v73, selRef_length);
  v148 = ((v90)(v106, selRef_length) + v92 + 50);
  v90(a1, selRef_appendBytes_length_, &v148, 4LL);
  v148 = (v90)(v119, selRef_count);
  v90(a1, selRef_appendBytes_length_, &v148, 4LL);
  LODWORD(v91) = (v90)(v91, selRef_length);
  v93 = ((v90)(v106, selRef_length) + v91);
  v148 = ((v90)(v96, selRef_length) + v93 + 50);
  v90(a1, selRef_appendBytes_length_, &v148, 4LL);
  v90(a1, selRef_appendData_, v89);
  v90(a1, selRef_appendData_, v106);
  v90(a1, selRef_appendData_, v96);
  v90(a1, selRef_appendData_, v57);
  CFRelease(v97);
  return *__stack_chk_guard_ptr;
}
 */
