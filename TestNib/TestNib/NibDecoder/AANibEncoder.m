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
    struct __CFDictionary *objectsToObjectIDs;
    struct __CFDictionary *objectIDsToObjects;
    struct __CFArray *values;
    struct __CFSet *encodedObjects;
    NSMutableData *_data;
    struct __CFDictionary *replacements;
    unsigned int nextObjectID;
    struct {
        unsigned int currentObjectID;
        unsigned int nextAnonymousKey;
    } recursiveState;
    NSMutableSet *objectsUniquedByValue;
    struct __CFSet *objectsReplacedWithNil;
    id delegate; //4
}

/*//----- (00000000004436ED) ----------------------------------------------------
// UINibEncoder - (id)initForWritingWithMutableData:(id)
id __cdecl -[UINibEncoder initForWritingWithMutableData:](struct UINibEncoder *self, SEL a2, id a3)
{
    id v3; // r14@1
    _QWORD *v4; // rbx@1
    void *(*v5)(void *, const char *, ...); // r12@2
    __int64 v6; // rax@2
    __int64 v7; // rax@2
    __int64 v8; // rax@2
    __int64 v9; // rax@2
    __int64 v10; // rax@2
    void *v11; // rax@2
    __int64 v12; // rax@2
    void *v13; // rax@2
    void *v14; // r14@2
    void *v15; // rax@2
    char v17; // [sp+8h] [bp-B8h]@2
    char v18; // [sp+38h] [bp-88h]@2
    char v19; // [sp+60h] [bp-60h]@2
    struct UINibEncoder *v20; // [sp+90h] [bp-30h]@1
    void *v21; // [sp+98h] [bp-28h]@1
    
    v3 = a3;
    v20 = self;
    v21 = classRef_UINibEncoder;
    v4 = objc_msgSendSuper2(&v20, selRef_init);
    if ( v4 )
    {
        v5 = *objc_msgSend_ptr;
        v4[5] = objc_msgSend_ptr(v3, selRef_retain);
        UIRetainedIdentityKeyDictionaryCallbacks(&v19);
        UIRetainedIdentityValueDictionaryCallbacks(&v18);
        LODWORD(v6) = CFDictionaryCreateMutable(0LL, 0LL, &v19, kCFTypeDictionaryValueCallBacks_ptr);
        v4[1] = v6;
        LODWORD(v7) = CFDictionaryCreateMutable(0LL, 0LL, kCFTypeDictionaryKeyCallBacks_ptr, &v18);
        v4[2] = v7;
        LODWORD(v8) = CFDictionaryCreateMutable(0LL, 0LL, &v19, &v18);
        v4[6] = v8;
        LODWORD(v9) = CFArrayCreateMutable(0LL, 0LL, kCFTypeArrayCallBacks_ptr);
        v4[3] = v9;
        UIRetainedIdentitySetCallbacks(&v17);
        LODWORD(v10) = CFSetCreateMutable(0LL, 0LL, &v17);
        v4[4] = v10;
        v11 = v5(classRef_NSMutableSet, selRef_alloc);
        v4[9] = v5(v11, selRef_init);
        LODWORD(v12) = CFSetCreateMutable(0LL, 0LL, &v17);
        v4[10] = v12;
        v13 = v5(classRef_NSObject, selRef_alloc);
        v14 = v5(v13, selRef_init);
        CFSetAddValue(v4[4], v14);
        v15 = v5(v4, selRef_assignObjectIDForObject_, v14);
        *(v4 + 15) = UINibArchiveIndexFromNumber(v15);
        v5(v14, selRef_release);
    }
    return v4;
}
// 7E7670: using guessed type int __fastcall CFArrayCreateMutable(_QWORD, _QWORD, _QWORD);
// 7E7748: using guessed type int __fastcall CFDictionaryCreateMutable(_QWORD, _QWORD, _QWORD, _QWORD);
// 7E78B6: using guessed type int __fastcall CFSetAddValue(_QWORD, _QWORD);
// 7E78C2: using guessed type int __fastcall CFSetCreateMutable(_QWORD, _QWORD, _QWORD);
// B62E58: using guessed type __int64 *kCFTypeArrayCallBacks_ptr;
// B62E60: using guessed type __int64 *kCFTypeDictionaryKeyCallBacks_ptr;
// B62E68: using guessed type __int64 *kCFTypeDictionaryValueCallBacks_ptr;
// DA3348: using guessed type char *selRef_retain;
// DA3380: using guessed type char *selRef_release;
// DA3398: using guessed type char *selRef_alloc;
// DA37F0: using guessed type char *selRef_init;
// DBE878: using guessed type char *selRef_assignObjectIDForObject_;
// DCECF0: using guessed type __int64 *classRef_NSMutableSet;
// DCEE78: using guessed type __int64 *classRef_NSObject;
// DD2B50: using guessed type void *classRef_UINibEncoder;
// DDC7F0: using guessed type __int64 OBJC_IVAR___UINibEncoder_data;
// DDC7F8: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectsToObjectIDs;
// DDC800: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectIDsToObjects;
// DDC808: using guessed type __int64 OBJC_IVAR___UINibEncoder_replacements;
// DDC810: using guessed type __int64 OBJC_IVAR___UINibEncoder_values;
// DDC818: using guessed type __int64 OBJC_IVAR___UINibEncoder_encodedObjects;
// DDC820: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectsUniquedByValue;
// DDC828: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectsReplacedWithNil;
// DDC830: using guessed type __int64 OBJC_IVAR___UINibEncoder_recursiveState;

//----- (00000000004438AD) ----------------------------------------------------
// UINibEncoder - (void)dealloc
void __cdecl -[UINibEncoder dealloc](struct UINibEncoder *self, SEL a2)
{
    void (*v2)(void *, const char *, ...); // r14@1
    __int64 v3; // [sp+0h] [bp-20h]@1
    void *v4; // [sp+8h] [bp-18h]@1
    
    CFRelease(self->objectsToObjectIDs);
    CFRelease(self->objectIDsToObjects);
    CFRelease(self->values);
    CFRelease(self->replacements);
    CFRelease(self->encodedObjects);
    CFRelease(*(&self->objectsReplacedWithNil + 4));
    v2 = *objc_msgSend_ptr;
    objc_msgSend_ptr(self->data, selRef_release);
    v2(*(&self->objectsUniquedByValue + 4), selRef_release);
    v4 = classRef_UINibEncoder;
    objc_msgSendSuper2(&v3, selRef_dealloc, self, classRef_UINibEncoder);
}
// 7E7844: using guessed type int __fastcall CFRelease(_QWORD);
// DA3380: using guessed type char *selRef_release;
// DA3508: using guessed type char *selRef_dealloc;
// DD2B50: using guessed type void *classRef_UINibEncoder;
// DDC7F0: using guessed type __int64 OBJC_IVAR___UINibEncoder_data;
// DDC7F8: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectsToObjectIDs;
// DDC800: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectIDsToObjects;
// DDC808: using guessed type __int64 OBJC_IVAR___UINibEncoder_replacements;
// DDC810: using guessed type __int64 OBJC_IVAR___UINibEncoder_values;
// DDC818: using guessed type __int64 OBJC_IVAR___UINibEncoder_encodedObjects;
// DDC820: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectsUniquedByValue;
// DDC828: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectsReplacedWithNil;

//----- (0000000000443974) ----------------------------------------------------
// UINibEncoder - (id)objectIDForObject:(id)
id __cdecl -[UINibEncoder objectIDForObject:](struct UINibEncoder *self, SEL a2, id a3)
{
    id result; // rax@1
    
    LODWORD(result) = CFDictionaryGetValue(self->objectsToObjectIDs, a3);
    return result;
}
// 7E775A: using guessed type int __fastcall CFDictionaryGetValue(_QWORD, _QWORD);
// DDC7F8: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectsToObjectIDs;

//----- (000000000044398C) ----------------------------------------------------
// UINibEncoder - (id)assignObjectIDForObject:(id)
id __cdecl -[UINibEncoder assignObjectIDForObject:](struct UINibEncoder *self, SEL a2, id a3)
{
    id v3; // r14@1
    struct objc_object *v4; // rbx@1
    
    v3 = a3;
    v4 = objc_msgSend_ptr(classRef_NSNumber, selRef_numberWithLongLong_, self->nextObjectID);
    CFDictionarySetValue(self->objectsToObjectIDs, v3, v4);
    CFDictionarySetValue(self->objectIDsToObjects, v4, v3);
    ++self->nextObjectID;
    return v4;
}
// DA4A10: using guessed type char *selRef_numberWithLongLong_;
// DCEBD8: using guessed type __int64 *classRef_NSNumber;
// DDC7F8: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectsToObjectIDs;
// DDC800: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectIDsToObjects;

//----- (00000000004439FB) ----------------------------------------------------
// UINibEncoder - (bool)previouslyCodedObject:(id)
bool __cdecl -[UINibEncoder previouslyCodedObject:](struct UINibEncoder *self, SEL a2, id a3)
{
    return objc_msgSend_ptr(self, selRef_objectIDForObject_, a3) != 0LL;
}
// DBE880: using guessed type char *selRef_objectIDForObject_;
*/
//----- (0000000000443A14) ----------------------------------------------------
// UINibEncoder - (void)appendValue:(id)

- (void)appendValue:(AANibCoderValue *)value
{
    CFArrayAppendValue(self->values, (__bridge void *)value);
}

/*
// 7E7652: using guessed type int __fastcall CFArrayAppendValue(_QWORD, _QWORD);
// DDC810: using guessed type __int64 OBJC_IVAR___UINibEncoder_values;

//----- (0000000000443A2C) ----------------------------------------------------
// UINibEncoder - (Class)encodedClassForObject:(id)
Class __cdecl -[UINibEncoder encodedClassForObject:](struct UINibEncoder *self, SEL a2, id a3)
{
    __int64 v3; // rax@0
    id v4; // rbx@1
    Class result; // rax@1
    
    v4 = a3;
    result = objc_msgSend_ptr(a3, selRef_classForKeyedArchiver, v3);
    if ( !result )
        result = objc_msgSend_ptr(v4, selRef_class);
    return result;
}
// DA33D0: using guessed type char *selRef_class;
// DBE888: using guessed type char *selRef_classForKeyedArchiver;

//----- (0000000000443A67) ----------------------------------------------------
// UINibEncoder - (id)encodedClassNameForClass:(Class)
id __cdecl -[UINibEncoder encodedClassNameForClass:](struct UINibEncoder *self, SEL a2, Class a3)
{
    id result; // rax@1
    
    LODWORD(result) = NSStringFromClass(a3);
    return result;
}
// 7E7A4E: using guessed type int __fastcall NSStringFromClass(_QWORD);

//----- (0000000000443A74) ----------------------------------------------------
// UINibEncoder - (id)encodedClassNameForObject:(id)
id __cdecl -[UINibEncoder encodedClassNameForObject:](struct UINibEncoder *self, SEL a2, id a3)
{
    int (__fastcall *v3)(struct UINibEncoder *, char *, void *); // r14@1
    void *v4; // rax@1
    id result; // rax@1
    
    v3 = *objc_msgSend_ptr;
    v4 = objc_msgSend_ptr(self, selRef_encodedClassForObject_, a3);
    LODWORD(result) = v3(self, selRef_encodedClassNameForClass_, v4);
    return result;
}
// DBE890: using guessed type char *selRef_encodedClassForObject_;
// DBE898: using guessed type char *selRef_encodedClassNameForClass_;

//----- (0000000000443AA5) ----------------------------------------------------
// UINibEncoder - (bool)object:(id) encodesWithCoderFromClass:(Class)
bool __cdecl -[UINibEncoder object:encodesWithCoderFromClass:](struct UINibEncoder *self, SEL a2, id a3, Class a4)
{
    __int64 v4; // rax@0
    Class v5; // r14@1
    void *(*v6)(void *, const char *, ...); // r15@1
    void *v7; // rax@1
    void *v8; // rbx@1
    
    v5 = a4;
    v6 = *objc_msgSend_ptr;
    v7 = objc_msgSend_ptr(a3, selRef_class, v4);
    v8 = v6(v7, selRef_instanceMethodForSelector_, selRef_encodeWithCoder_);
    return v8 == v6(v5, selRef_instanceMethodForSelector_, selRef_encodeWithCoder_);
}
// DA33D0: using guessed type char *selRef_class;
// DA3668: using guessed type char *selRef_encodeWithCoder_;
// DA5E70: using guessed type char *selRef_instanceMethodForSelector_;

//----- (0000000000443B02) ----------------------------------------------------
// UINibEncoder - (bool)object:(id) encodesAsMemberAndWithCoderOfClass:(Class)
bool __cdecl -[UINibEncoder object:encodesAsMemberAndWithCoderOfClass:](struct UINibEncoder *self, SEL a2, id a3, Class a4)
{
    __int64 v4; // rax@0
    Class v5; // r14@1
    id v6; // rbx@1
    bool result; // al@2
    
    v5 = a4;
    v6 = a3;
    if ( objc_msgSend_ptr(a3, selRef_classForKeyedArchiver, v4) == a4 )
        result = objc_msgSend_ptr(self, selRef_object_encodesWithCoderFromClass_, v6, v5);
    else
        result = 0;
    return result;
}
// DBE888: using guessed type char *selRef_classForKeyedArchiver;
// DBE8A0: using guessed type char *selRef_object_encodesWithCoderFromClass_;

//----- (0000000000443B4F) ----------------------------------------------------
// UINibEncoder - (bool)shouldUniqueObjectByValue:(id)
bool __cdecl -[UINibEncoder shouldUniqueObjectByValue:](struct UINibEncoder *self, SEL a2, id a3)
{
    __int64 v3; // rax@0
    id v4; // r14@1
    void *(*v5)(void *, const char *, ...); // r15@1
    void *v6; // rax@1
    char v7; // cl@1
    bool result; // al@1
    void *v9; // rax@2
    
    v4 = a3;
    v5 = *objc_msgSend_ptr;
    v6 = objc_msgSend_ptr(classRef_NSString, selRef_class, v3);
    v7 = v5(self, selRef_object_encodesAsMemberAndWithCoderOfClass_, v4, v6);
    result = 1;
    if ( !v7 )
    {
        v9 = v5(classRef_NSNumber, selRef_class);
        result = v5(self, selRef_object_encodesAsMemberAndWithCoderOfClass_, v4, v9);
    }
    return result;
}
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
// 7E7736: using guessed type int __fastcall CFDictionaryContainsKey(_QWORD, _QWORD);
// 7E775A: using guessed type int __fastcall CFDictionaryGetValue(_QWORD, _QWORD);
// 7E78B6: using guessed type int __fastcall CFSetAddValue(_QWORD, _QWORD);
// 7E78BC: using guessed type int __fastcall CFSetContainsValue(_QWORD, _QWORD);
// DA3700: using guessed type char *selRef_respondsToSelector_;
// DBE878: using guessed type char *selRef_assignObjectIDForObject_;
// DBE880: using guessed type char *selRef_objectIDForObject_;
// DBE8B0: using guessed type char *selRef_shouldUniqueObjectByValue_;
// DBE8B8: using guessed type char *selRef_member_;
// DBE8C0: using guessed type char *selRef_replacementObjectForCoder_;
// DBE8C8: using guessed type char *selRef_nibCoder_willEncodeObject_forObject_forKey_;
// DBE8D0: using guessed type char *selRef_nibCoder_willEncodeObject_;
// DDC800: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectIDsToObjects;
// DDC808: using guessed type __int64 OBJC_IVAR___UINibEncoder_replacements;
// DDC820: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectsUniquedByValue;
// DDC828: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectsReplacedWithNil;
// DDC830: using guessed type __int64 OBJC_IVAR___UINibEncoder_recursiveState;

//----- (0000000000443DBF) ----------------------------------------------------
// UINibEncoder - (void)serializeArray:(id)
void __cdecl -[UINibEncoder serializeArray:](struct UINibEncoder *self, SEL a2, id a3)
{
    id v3; // rbx@1
    void *(*v4)(void *, const char *, ...); // r14@1
    void *v5; // rbx@1
    __int64 v6; // r14@2
    unsigned __int64 v7; // r15@3
    __int64 v8; // rax@8
    id v9; // [sp+8h] [bp-F8h]@1
    __int128 v10; // [sp+10h] [bp-F0h]@1
    __int128 v11; // [sp+20h] [bp-E0h]@1
    __int128 v12; // [sp+30h] [bp-D0h]@1
    __int128 v13; // [sp+40h] [bp-C0h]@1
    char v14; // [sp+50h] [bp-B0h]@1
    __int64 v15; // [sp+D0h] [bp-30h]@1
    
    v3 = a3;
    v9 = a3;
    v15 = *__stack_chk_guard_ptr;
    v4 = *objc_msgSend_ptr;
    objc_msgSend_ptr(self, selRef_encodeBool_forKey_, 1LL, UIInlinedValueMarker);
    v13 = 0LL;
    v12 = 0LL;
    v11 = 0LL;
    v10 = 0LL;
    v5 = v4(v3, selRef_countByEnumeratingWithState_objects_count_, &v10, &v14, 16LL);
    if ( v5 )
    {
        v6 = *v11;
        do
        {
            v7 = 0LL;
            do
            {
                if ( *v11 != v6 )
                    objc_enumerationMutation(v9);
                objc_msgSend_ptr(self, selRef_encodeObject_forKey_, *(*(&v10 + 1) + 8 * v7++), &cfstr_Uinibencoderem);
            }
            while ( v7 < v5 );
            v5 = objc_msgSend_ptr(v9, selRef_countByEnumeratingWithState_objects_count_, &v10, &v14, 16LL);
        }
        while ( v5 );
    }
    v8 = *__stack_chk_guard_ptr;
}
// B629D0: using guessed type __int64 *__stack_chk_guard_ptr;
// B8B630: using guessed type __CFString *UIInlinedValueMarker;
// BC6170: using guessed type __CFString cfstr_Uinibencoderem;
// DA33F8: using guessed type char *selRef_countByEnumeratingWithState_objects_count_;
// DA3670: using guessed type char *selRef_encodeObject_forKey_;
// DA3678: using guessed type char *selRef_encodeBool_forKey_;

//----- (0000000000443F03) ----------------------------------------------------
// UINibEncoder - (void)serializeDictionary:(id)
void __cdecl -[UINibEncoder serializeDictionary:](struct UINibEncoder *self, SEL a2, id a3)
{
    id v3; // r14@1
    void *(*v4)(void *, const char *, ...); // r13@1
    unsigned __int64 v5; // r14@3
    __int64 v6; // ST18_8@6
    void *v7; // rax@6
    __int64 v8; // rax@8
    __int64 v9; // [sp+0h] [bp-110h]@2
    void *v10; // [sp+8h] [bp-108h]@1
    id v11; // [sp+10h] [bp-100h]@1
    __int128 v12; // [sp+20h] [bp-F0h]@1
    __int128 v13; // [sp+30h] [bp-E0h]@1
    __int128 v14; // [sp+40h] [bp-D0h]@1
    __int128 v15; // [sp+50h] [bp-C0h]@1
    char v16; // [sp+60h] [bp-B0h]@1
    __int64 v17; // [sp+E0h] [bp-30h]@1
    
    v3 = a3;
    v11 = a3;
    v17 = *__stack_chk_guard_ptr;
    v4 = *objc_msgSend_ptr;
    objc_msgSend_ptr(self, selRef_encodeBool_forKey_, 1LL, UIInlinedValueMarker);
    v15 = 0LL;
    v14 = 0LL;
    v13 = 0LL;
    v12 = 0LL;
    v10 = v4(v3, selRef_countByEnumeratingWithState_objects_count_, &v12, &v16, 16LL);
    if ( v10 )
    {
        v9 = *v13;
        do
        {
            v5 = 0LL;
            do
            {
                if ( *v13 != v9 )
                    objc_enumerationMutation(v11);
                v6 = *(*(&v12 + 1) + 8 * v5);
                v4(self, selRef_encodeObject_forKey_, *(*(&v12 + 1) + 8 * v5), v9);
                v7 = v4(v11, selRef_objectForKey_, v6);
                v4(self, selRef_encodeObject_forKey_, v7, &cfstr_Uinibencoderem);
                ++v5;
            }
            while ( v5 < v10 );
            v10 = objc_msgSend_ptr(v11, selRef_countByEnumeratingWithState_objects_count_, &v12, &v16, 16LL);
        }
        while ( v10 );
    }
    v8 = *__stack_chk_guard_ptr;
}
// B629D0: using guessed type __int64 *__stack_chk_guard_ptr;
// B8B630: using guessed type __CFString *UIInlinedValueMarker;
// BC6170: using guessed type __CFString cfstr_Uinibencoderem;
// DA33F8: using guessed type char *selRef_countByEnumeratingWithState_objects_count_;
// DA3400: using guessed type char *selRef_objectForKey_;
// DA3670: using guessed type char *selRef_encodeObject_forKey_;
// DA3678: using guessed type char *selRef_encodeBool_forKey_;

//----- (0000000000444093) ----------------------------------------------------
// UINibEncoder - (void)serializeSet:(id)
void __cdecl -[UINibEncoder serializeSet:](struct UINibEncoder *self, SEL a2, id a3)
{
    id v3; // rbx@1
    void *(*v4)(void *, const char *, ...); // r14@1
    void *v5; // rbx@1
    __int64 v6; // r14@2
    unsigned __int64 v7; // r15@3
    __int64 v8; // rax@8
    id v9; // [sp+8h] [bp-F8h]@1
    __int128 v10; // [sp+10h] [bp-F0h]@1
    __int128 v11; // [sp+20h] [bp-E0h]@1
    __int128 v12; // [sp+30h] [bp-D0h]@1
    __int128 v13; // [sp+40h] [bp-C0h]@1
    char v14; // [sp+50h] [bp-B0h]@1
    __int64 v15; // [sp+D0h] [bp-30h]@1
    
    v3 = a3;
    v9 = a3;
    v15 = *__stack_chk_guard_ptr;
    v4 = *objc_msgSend_ptr;
    objc_msgSend_ptr(self, selRef_encodeBool_forKey_, 1LL, UIInlinedValueMarker);
    v13 = 0LL;
    v12 = 0LL;
    v11 = 0LL;
    v10 = 0LL;
    v5 = v4(v3, selRef_countByEnumeratingWithState_objects_count_, &v10, &v14, 16LL);
    if ( v5 )
    {
        v6 = *v11;
        do
        {
            v7 = 0LL;
            do
            {
                if ( *v11 != v6 )
                    objc_enumerationMutation(v9);
                objc_msgSend_ptr(self, selRef_encodeObject_forKey_, *(*(&v10 + 1) + 8 * v7++), &cfstr_Uinibencoderem);
            }
            while ( v7 < v5 );
            v5 = objc_msgSend_ptr(v9, selRef_countByEnumeratingWithState_objects_count_, &v10, &v14, 16LL);
        }
        while ( v5 );
    }
    v8 = *__stack_chk_guard_ptr;
}
// B629D0: using guessed type __int64 *__stack_chk_guard_ptr;
// B8B630: using guessed type __CFString *UIInlinedValueMarker;
// BC6170: using guessed type __CFString cfstr_Uinibencoderem;
// DA33F8: using guessed type char *selRef_countByEnumeratingWithState_objects_count_;
// DA3670: using guessed type char *selRef_encodeObject_forKey_;
// DA3678: using guessed type char *selRef_encodeBool_forKey_;

//----- (00000000004441D7) ----------------------------------------------------
// UINibEncoder - (void)serializeObject:(id)
void __cdecl -[UINibEncoder serializeObject:](struct UINibEncoder *self, SEL a2, id a3)
{
    __int64 v3; // rax@0
    struct UINibEncoder *v4; // r14@1
    struct UINibEncoder *v5; // rbx@1
    void *(*v6)(void *, const char *, ...); // r15@1
    void *v7; // rax@1
    const char *v8; // rsi@2
    void *v9; // rax@3
    void *v10; // rax@5
    struct UINibEncoder *v11; // rdx@7
    
    v4 = a3;
    v5 = self;
    v6 = *objc_msgSend_ptr;
    v7 = objc_msgSend_ptr(classRef_NSArray, selRef_class, v3);
    if ( v6(self, selRef_object_encodesWithCoderFromClass_, v4, v7) )
    {
        v8 = selRef_serializeArray_;
    }
    else
    {
        v9 = v6(classRef_NSDictionary, selRef_class);
        if ( v6(self, selRef_object_encodesWithCoderFromClass_, v4, v9) )
        {
            v8 = selRef_serializeDictionary_;
        }
        else
        {
            v10 = v6(classRef_NSSet, selRef_class);
            if ( !v6(self, selRef_object_encodesWithCoderFromClass_, v4, v10) )
            {
                v8 = selRef_encodeWithCoder_;
                self = v4;
                v11 = v5;
                goto LABEL_8;
            }
            v8 = selRef_serializeSet_;
        }
    }
    v11 = v4;
LABEL_8:
    objc_msgSend_ptr(self, v8, v11);
}
// DA33D0: using guessed type char *selRef_class;
// DA3668: using guessed type char *selRef_encodeWithCoder_;
// DBE8A0: using guessed type char *selRef_object_encodesWithCoderFromClass_;
// DBE8D8: using guessed type char *selRef_serializeArray_;
// DBE8E0: using guessed type char *selRef_serializeDictionary_;
// DBE8E8: using guessed type char *selRef_serializeSet_;
// DCEBB8: using guessed type __int64 *classRef_NSArray;
// DCEBE0: using guessed type __int64 *classRef_NSDictionary;
// DCEFE0: using guessed type __int64 *classRef_NSSet;

//----- (00000000004442A4) ----------------------------------------------------
// UINibEncoder + (id)archivedDataWithRootObject:(id)
id __cdecl +[UINibEncoder archivedDataWithRootObject:](struct UINibEncoder *self, SEL a2, id a3)
{
    id v3; // r14@1
    void *(*v4)(void *, const char *, ...); // r12@1
    struct objc_object *v5; // r15@1
    void *v6; // rax@1
    void *v7; // rax@1
    void *v8; // rbx@1
    
    v3 = a3;
    v4 = *objc_msgSend_ptr;
    v5 = objc_msgSend_ptr(classRef_NSMutableData, selRef_data);
    v6 = v4(self, selRef_alloc);
    v7 = v4(v6, selRef_initForWritingWithMutableData_, v5);
    v8 = v4(v7, selRef_autorelease);
    v4(v8, selRef_encodeObject_forKey_, v3, &cfstr_Object_0);
    v4(v8, selRef_finishEncoding);
    return v5;
}
// BC6010: using guessed type __CFString cfstr_Object_0;
// DA3398: using guessed type char *selRef_alloc;
// DA3670: using guessed type char *selRef_encodeObject_forKey_;
// DA38B8: using guessed type char *selRef_autorelease;
// DA57A8: using guessed type char *selRef_initForWritingWithMutableData_;
// DA5808: using guessed type char *selRef_finishEncoding;
// DA6150: using guessed type char *selRef_data;
// DCEF90: using guessed type __int64 *classRef_NSMutableData;

//----- (000000000044432D) ----------------------------------------------------
// UINibEncoder + (bool)archiveRootObject:(id) toFile:(id)
bool __cdecl +[UINibEncoder archiveRootObject:toFile:](struct UINibEncoder *self, SEL a2, id a3, id a4)
{
    id v4; // rbx@1
    int (__fastcall *v5)(void *, char *, id, signed __int64); // r14@1
    void *v6; // rax@1
    
    v4 = a4;
    v5 = *objc_msgSend_ptr;
    v6 = objc_msgSend_ptr(self, selRef_archivedDataWithRootObject_, a3);
    return v5(v6, selRef_writeToFile_atomically_, v4, 1LL);
}
// DA4F70: using guessed type char *selRef_writeToFile_atomically_;
// DA6358: using guessed type char *selRef_archivedDataWithRootObject_;

//----- (0000000000444363) ----------------------------------------------------
// UINibEncoder - (void)finishEncoding
void __cdecl -[UINibEncoder finishEncoding](struct UINibEncoder *self, SEL a2)
{
    __int64 v2; // rax@1
    __int64 v3; // r12@1
    struct UINibEncoder::__CFDictionary *v4; // r14@1
    void *(*v5)(void *, const char *, ...); // r13@1
    void *v6; // rax@1
    __int64 v7; // rax@1
    __int64 v8; // r15@1
    void *v9; // rax@1
    unsigned __int64 v10; // rax@1
    char *v11; // rax@2
    char *v12; // rsi@4
    __int64 v13; // rax@4
    __int64 v14; // r12@4
    signed __int64 v15; // r13@5
    __int64 *v16; // rbx@5
    __int64 v17; // r14@6
    signed __int64 v18; // rdx@7
    void *v19; // rax@7
    struct UINibEncoder *v20; // r14@9
    __int64 v21; // rax@9
    __int64 v22; // r15@10
    __int64 v23; // rax@11
    __int64 v24; // r13@11
    struct UINibEncoder::__CFDictionary *v25; // rbx@12
    void *v26; // rax@12
    __int64 v27; // rax@12
    __int64 v28; // rbx@12
    void *v29; // rax@13
    struct UINibEncoder::__CFDictionary *v30; // rbx@16
    void *v31; // rax@16
    __int64 v32; // rax@16
    void *v33; // rax@16
    int (__fastcall *v34)(__int64 *, char *); // rbx@17
    struct UINibEncoder *v35; // rax@17
    __int64 v36; // rax@17
    __int64 v37; // r14@17
    char *v38; // r12@18
    __int64 v39; // r13@19
    int (__fastcall *v40)(struct UINibEncoder *, char *, void *); // r15@19
    void *v41; // rax@19
    void *v42; // rax@19
    void *v43; // rbx@19
    __int64 v44; // rax@19
    __int64 v45; // rax@19
    void *v46; // r13@20
    int (__fastcall *v47)(void *, char *); // rbx@20
    void *v48; // rax@20
    void *v49; // r15@20
    __int64 v50; // rax@20
    __int64 v51; // rax@25
    char *v52; // [sp+10h] [bp-490h]@4
    __int64 v53; // [sp+18h] [bp-488h]@9
    void *v54; // [sp+18h] [bp-488h]@17
    struct UINibEncoder *v55; // [sp+20h] [bp-480h]@17
    void *v56; // [sp+28h] [bp-478h]@19
    __int64 v57; // [sp+38h] [bp-468h]@1
    char v58; // [sp+40h] [bp-460h]@1
    char v59; // [sp+70h] [bp-430h]@3
    __int64 v60; // [sp+470h] [bp-30h]@1
    
    v60 = *__stack_chk_guard_ptr;
    UIRetainedIdentityKeyDictionaryCallbacks(&v58);
    LODWORD(v2) = CFDictionaryCreateMutable(0LL, 0LL, &v58, kCFTypeDictionaryValueCallBacks_ptr);
    v3 = v2;
    v57 = v2;
    v4 = self->objectIDsToObjects;
    v5 = *objc_msgSend_ptr;
    v6 = objc_msgSend_ptr(classRef_NSNumber, selRef_numberWithLongLong_, 0LL);
    LODWORD(v7) = CFDictionaryGetValue(v4, v6);
    v8 = v7;
    v9 = v5(classRef_NSNumber, selRef_numberWithInteger_, 0LL);
    CFDictionarySetValue(v3, v8, v9);
    LODWORD(v10) = CFSetGetCount(self->encodedObjects, v8);
    if ( v10 < 0x81 )
        v11 = &v59;
    else
        v11 = malloc(8 * v10);
    v52 = v11;
    v12 = v11;
    CFSetGetValues(self->encodedObjects, v11);
    LODWORD(v13) = CFSetGetCount(self->encodedObjects, v12);
    v14 = v13;
    if ( v13 > 0 )
    {
        v15 = 1LL;
        v16 = v52;
        do
        {
            v17 = *v16;
            if ( *v16 != v8 )
            {
                v18 = v15++;
                v19 = objc_msgSend_ptr(classRef_NSNumber, selRef_numberWithInteger_, v18);
                CFDictionarySetValue(v57, v17, v19);
            }
            ++v16;
            --v14;
        }
        while ( v14 );
    }
    v20 = self;
    LODWORD(v21) = CFArrayGetCount(self->values);
    v53 = v21;
    if ( v21 > 0 )
    {
        v22 = 0LL;
        do
        {
            LODWORD(v23) = CFArrayGetValueAtIndex(v20->values, v22);
            v24 = v23;
            if ( *(v23 + 20) == 10 )
            {
                v25 = v20->objectIDsToObjects;
                v26 = objc_msgSend_ptr(classRef_NSNumber, selRef_numberWithLongLong_, *(v23 + 24));
                LODWORD(v27) = CFDictionaryGetValue(v25, v26);
                v28 = v27;
                if ( CFSetContainsValue(v20->encodedObjects, v27) )
                {
                    LODWORD(v29) = CFDictionaryGetValue(v57, v28);
                    *(v24 + 24) = UINibArchiveIndexFromNumber(v29);
                }
                else
                {
                    *(v24 + 20) = 9;
                    *(v24 + 24) = 0LL;
                }
                v20 = self;
            }
            v30 = v20->objectIDsToObjects;
            v31 = objc_msgSend_ptr(classRef_NSNumber, selRef_numberWithLongLong_, *(v24 + 16));
            LODWORD(v32) = CFDictionaryGetValue(v30, v31);
            LODWORD(v33) = CFDictionaryGetValue(v57, v32);
            *(v24 + 16) = UINibArchiveIndexFromNumber(v33);
            ++v22;
        }
        while ( v53 != v22 );
    }
    v34 = *objc_msgSend_ptr;
    v54 = objc_msgSend_ptr(classRef_NSMutableDictionary, selRef_dictionary);
    LODWORD(v35) = v34(classRef_NSMutableDictionary, selRef_dictionary);
    v55 = v35;
    LODWORD(v36) = CFSetGetCount(v20->encodedObjects, selRef_dictionary);
    v37 = v36;
    if ( v36 > 0 )
    {
        v38 = v52;
        do
        {
            v39 = *v38;
            v40 = *objc_msgSend_ptr;
            v41 = objc_msgSend_ptr(self, selRef_encodedClassForObject_, *v38);
            v56 = v41;
            LODWORD(v42) = v40(self, selRef_encodedClassNameForClass_, v41);
            v43 = v42;
            LODWORD(v44) = CFDictionaryGetValue(v57, v39);
            (v40)(v54, selRef_setObject_forKey_, v43, v44);
            LODWORD(v45) = v40(v55, selRef_objectForKey_, v43);
            if ( !v45 )
            {
                v46 = v43;
                v47 = *objc_msgSend_ptr;
                v48 = objc_msgSend_ptr(v56, selRef_classFallbacksForKeyedArchiver);
                v49 = v48;
                LODWORD(v50) = v47(v48, selRef_count);
                if ( v50 )
                    objc_msgSend_ptr(v55, selRef_setObject_forKey_, v49, v46);
            }
            v38 += 8;
            --v37;
        }
        while ( v37 );
    }
    if ( v52 != &v59 )
        free(v52);
    CFRelease(v57);
    UIWriteArchiveToData(self->data, 1, v54, v55, self->values, &cfstr_Uinibencoderem);
    v51 = *__stack_chk_guard_ptr;
}
// 7E767C: using guessed type int __fastcall CFArrayGetCount(_QWORD);
// 7E7688: using guessed type int __fastcall CFArrayGetValueAtIndex(_QWORD, _QWORD);
// 7E7748: using guessed type int __fastcall CFDictionaryCreateMutable(_QWORD, _QWORD, _QWORD, _QWORD);
// 7E775A: using guessed type int __fastcall CFDictionaryGetValue(_QWORD, _QWORD);
// 7E7844: using guessed type int __fastcall CFRelease(_QWORD);
// 7E78BC: using guessed type int __fastcall CFSetContainsValue(_QWORD, _QWORD);
// 7E78C8: using guessed type int __fastcall CFSetGetCount(_QWORD, _QWORD);
// 7E78D4: using guessed type int __fastcall CFSetGetValues(_QWORD, _QWORD);
// B629D0: using guessed type __int64 *__stack_chk_guard_ptr;
// B62E68: using guessed type __int64 *kCFTypeDictionaryValueCallBacks_ptr;
// BC6170: using guessed type __CFString cfstr_Uinibencoderem;
// DA3400: using guessed type char *selRef_objectForKey_;
// DA3408: using guessed type char *selRef_setObject_forKey_;
// DA3750: using guessed type char *selRef_count;
// DA41E8: using guessed type char *selRef_dictionary;
// DA4A10: using guessed type char *selRef_numberWithLongLong_;
// DA4A20: using guessed type char *selRef_numberWithInteger_;
// DBE890: using guessed type char *selRef_encodedClassForObject_;
// DBE898: using guessed type char *selRef_encodedClassNameForClass_;
// DBE8F0: using guessed type char *selRef_classFallbacksForKeyedArchiver;
// DCEBD0: using guessed type __int64 *classRef_NSMutableDictionary;
// DCEBD8: using guessed type __int64 *classRef_NSNumber;
// DDC7F0: using guessed type __int64 OBJC_IVAR___UINibEncoder_data;
// DDC800: using guessed type __int64 OBJC_IVAR___UINibEncoder_objectIDsToObjects;
// DDC810: using guessed type __int64 OBJC_IVAR___UINibEncoder_values;
// DDC818: using guessed type __int64 OBJC_IVAR___UINibEncoder_encodedObjects;
*/

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
// 7E7A4E: using guessed type int __fastcall NSStringFromClass(_QWORD);
// B9FB10: using guessed type __CFString cfstr_InvalidParamet;
// BC6150: using guessed type __CFString cfstr_ThisCoderDoesN;
// DA33D0: using guessed type char *selRef_class;
// DA3538: using guessed type char *selRef_currentHandler;
// DA3540: using guessed type char *selRef_stringWithUTF8String_;
// DA3548: using guessed type char *selRef_handleFailureInMethod_object_file_lineNumber_description_;
// DA3558: using guessed type char *selRef_stringWithFormat_;
// DBE878: using guessed type char *selRef_assignObjectIDForObject_;
// DBE880: using guessed type char *selRef_objectIDForObject_;
// DBE8B0: using guessed type char *selRef_shouldUniqueObjectByValue_;
// DBE8F8: using guessed type char *selRef_replacementObjectForObject_forKey_;
// DBE900: using guessed type char *selRef_nibValueForObjectReference_key_scope_;
// DBE908: using guessed type char *selRef_appendValue_;
// DBE918: using guessed type char *selRef_nibValueRepresentingNilReferenceForKey_scope_;
// DCEBE8: using guessed type __int64 *classRef_NSAssertionHandler;
// DCEBF0: using guessed type __int64 *classRef_NSString;
// DD0720: using guessed type void *classRef_UINibCoderValue;
// DDC830: using guessed type __int64 OBJC_IVAR___UINibEncoder_recursiveState;
*/

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForBoolean:boolv key:key scope:self->recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeInt:(int)intv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForInteger:intv key:key scope:self->recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeInt32:(int32_t)intv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForInt32:intv key:key scope:self->recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeInt64:(int64_t)intv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForInt64:intv key:key scope:self->recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeInteger:(NSInteger)intv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForInteger:intv key:key scope:self->recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeFloat:(float)realv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForFloat:realv key:key scope:self->recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeDouble:(double)realv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForDouble:realv key:key scope:self->recursiveState.currentObjectID];
    [self appendValue:value];
}

- (void)encodeBytes:(const uint8_t *)bytesp length:(NSUInteger)lenv forKey:(NSString *)key
{
    AANibCoderValue *value = [AANibCoderValue nibValueForBytes:bytesp length:lenv key:key scope:self->recursiveState.currentObjectID];
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
    self->recursiveState.nextAnonymousKey++;
    return [NSString stringWithFormat:@"$%ld", self->recursiveState.nextAnonymousKey];
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
    return self->delegate;
}

- (void)setDelegate:(id)aDelegate
{
    self->delegate = aDelegate;
}

@end
