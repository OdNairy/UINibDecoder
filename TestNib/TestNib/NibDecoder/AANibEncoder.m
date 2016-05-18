//
//  AANibEncoder.m
//  TestNib
//
//  Created by AB on 5/8/16.
//  Copyright © 2016 Intellectsoft Group. All rights reserved.
//

#import "AANibEncoder.h"

@implementation AANibEncoder {
    struct __CFDictionary *objectsToObjectIDs;
    struct __CFDictionary *objectIDsToObjects;
    struct __CFArray *values;
    struct __CFSet *encodedObjects;
    NSMutableData *data;
    struct __CFDictionary *replacements;
    unsigned int nextObjectID;
    struct {
        unsigned int currentObjectID;
        unsigned int nextAnonymousKey;
    } recursiveState;
    NSMutableSet *objectsUniquedByValue;
    struct __CFSet *objectsReplacedWithNil;
    id delegate;
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

//----- (0000000000443A14) ----------------------------------------------------
// UINibEncoder - (void)appendValue:(id)
void __cdecl -[UINibEncoder appendValue:](struct UINibEncoder *self, SEL a2, id a3)
{
    CFArrayAppendValue(self->values, a3);
}
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

//----- (00000000004447E9) ----------------------------------------------------
// UINibEncoder - (unsigned int)systemVersion
unsigned int __cdecl -[UINibEncoder systemVersion](struct UINibEncoder *self, SEL a2)
{
    return 2000;
}

//----- (00000000004447F4) ----------------------------------------------------
// UINibEncoder - (int64_t)versionForClassName:(id)
int64_t __cdecl -[UINibEncoder versionForClassName:](struct UINibEncoder *self, SEL a2, id a3)
{
    void *v3; // rax@1
    int64_t result; // rax@2
    
    LODWORD(v3) = NSClassFromString(a3);
    if ( v3 )
        result = objc_msgSend_ptr(v3, selRef_version);
    else
        result = 0x7FFFFFFFFFFFFFFFLL;
    return result;
}
// 7E79CA: using guessed type int __fastcall NSClassFromString(_QWORD);
// DBE400: using guessed type char *selRef_version;

//----- (0000000000444822) ----------------------------------------------------
// UINibEncoder - (bool)allowsKeyedCoding
bool __cdecl -[UINibEncoder allowsKeyedCoding](struct UINibEncoder *self, SEL a2)
{
    return 1;
}

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

//----- (0000000000444BF2) ----------------------------------------------------
// UINibEncoder - (void)encodeBool:(bool) forKey:(id)
void __cdecl -[UINibEncoder encodeBool:forKey:](struct UINibEncoder *self, SEL a2, bool a3, id a4)
{
    void (__fastcall *v4)(struct UINibEncoder *, char *, void *); // r14@1
    void *v5; // rax@1
    
    v4 = *objc_msgSend_ptr;
    v5 = objc_msgSend_ptr(
                          classRef_UINibCoderValue,
                          selRef_nibValueForBoolean_key_scope_,
                          a3,
                          a4,
                          self->recursiveState.currentObjectID);
    v4(self, selRef_appendValue_, v5);
}
// DBE908: using guessed type char *selRef_appendValue_;
// DBE920: using guessed type char *selRef_nibValueForBoolean_key_scope_;
// DD0720: using guessed type void *classRef_UINibCoderValue;
// DDC830: using guessed type __int64 OBJC_IVAR___UINibEncoder_recursiveState;

//----- (0000000000444C38) ----------------------------------------------------
// UINibEncoder - (void)encodeInt:(int) forKey:(id)
void __cdecl -[UINibEncoder encodeInt:forKey:](struct UINibEncoder *self, SEL a2, int a3, id a4)
{
    void (__fastcall *v4)(struct UINibEncoder *, char *, void *); // r14@1
    void *v5; // rax@1
    
    v4 = *objc_msgSend_ptr;
    v5 = objc_msgSend_ptr(
                          classRef_UINibCoderValue,
                          selRef_nibValueForInteger_key_scope_,
                          a3,
                          a4,
                          self->recursiveState.currentObjectID);
    v4(self, selRef_appendValue_, v5);
}
// DBE908: using guessed type char *selRef_appendValue_;
// DBE928: using guessed type char *selRef_nibValueForInteger_key_scope_;
// DD0720: using guessed type void *classRef_UINibCoderValue;
// DDC830: using guessed type __int64 OBJC_IVAR___UINibEncoder_recursiveState;

//----- (0000000000444C7E) ----------------------------------------------------
// UINibEncoder - (void)encodeInt32:(int) forKey:(id)
void __cdecl -[UINibEncoder encodeInt32:forKey:](struct UINibEncoder *self, SEL a2, int a3, id a4)
{
    void (__fastcall *v4)(struct UINibEncoder *, char *, void *); // r14@1
    void *v5; // rax@1
    
    v4 = *objc_msgSend_ptr;
    v5 = objc_msgSend_ptr(
                          classRef_UINibCoderValue,
                          selRef_nibValueForInteger_key_scope_,
                          a3,
                          a4,
                          self->recursiveState.currentObjectID);
    v4(self, selRef_appendValue_, v5);
}
// DBE908: using guessed type char *selRef_appendValue_;
// DBE928: using guessed type char *selRef_nibValueForInteger_key_scope_;
// DD0720: using guessed type void *classRef_UINibCoderValue;
// DDC830: using guessed type __int64 OBJC_IVAR___UINibEncoder_recursiveState;

//----- (0000000000444CC4) ----------------------------------------------------
// UINibEncoder - (void)encodeInt64:(int64_t) forKey:(id)
void __cdecl -[UINibEncoder encodeInt64:forKey:](struct UINibEncoder *self, SEL a2, int64_t a3, id a4)
{
    void (__fastcall *v4)(struct UINibEncoder *, char *, void *); // r14@1
    void *v5; // rax@1
    
    v4 = *objc_msgSend_ptr;
    v5 = objc_msgSend_ptr(
                          classRef_UINibCoderValue,
                          selRef_nibValueForInteger_key_scope_,
                          a3,
                          a4,
                          self->recursiveState.currentObjectID);
    v4(self, selRef_appendValue_, v5);
}
// DBE908: using guessed type char *selRef_appendValue_;
// DBE928: using guessed type char *selRef_nibValueForInteger_key_scope_;
// DD0720: using guessed type void *classRef_UINibCoderValue;
// DDC830: using guessed type __int64 OBJC_IVAR___UINibEncoder_recursiveState;

//----- (0000000000444D07) ----------------------------------------------------
// UINibEncoder - (void)encodeInteger:(int64_t) forKey:(id)
void __cdecl -[UINibEncoder encodeInteger:forKey:](struct UINibEncoder *self, SEL a2, int64_t a3, id a4)
{
    void (__fastcall *v4)(struct UINibEncoder *, char *, void *); // r14@1
    void *v5; // rax@1
    
    v4 = *objc_msgSend_ptr;
    v5 = objc_msgSend_ptr(
                          classRef_UINibCoderValue,
                          selRef_nibValueForInteger_key_scope_,
                          a3,
                          a4,
                          self->recursiveState.currentObjectID);
    v4(self, selRef_appendValue_, v5);
}
// DBE908: using guessed type char *selRef_appendValue_;
// DBE928: using guessed type char *selRef_nibValueForInteger_key_scope_;
// DD0720: using guessed type void *classRef_UINibCoderValue;
// DDC830: using guessed type __int64 OBJC_IVAR___UINibEncoder_recursiveState;

//----- (0000000000444D4A) ----------------------------------------------------
// UINibEncoder - (void)encodeFloat:(float) forKey:(id)
// local variable allocation has failed, the output may be wrong!
void __cdecl -[UINibEncoder encodeFloat:forKey:](struct UINibEncoder *self, SEL a2, float a3, id a4)
{
    void (__fastcall *v4)(struct UINibEncoder *, char *, void *); // r14@1
    void *v5; // rax@1
    
    v4 = *objc_msgSend_ptr;
    v5 = objc_msgSend_ptr(
                          classRef_UINibCoderValue,
                          selRef_nibValueForFloat_key_scope_,
                          a4,
                          self->recursiveState.currentObjectID,
                          *&a3);
    v4(self, selRef_appendValue_, v5);
}
// 444D4A: variables would overlap: xmm0_4.4 and xmm0_8.8
// DBE908: using guessed type char *selRef_appendValue_;
// DBE930: using guessed type char *selRef_nibValueForFloat_key_scope_;
// DD0720: using guessed type void *classRef_UINibCoderValue;
// DDC830: using guessed type __int64 OBJC_IVAR___UINibEncoder_recursiveState;

//----- (0000000000444D8C) ----------------------------------------------------
// UINibEncoder - (void)encodeDouble:(double) forKey:(id)
void __cdecl -[UINibEncoder encodeDouble:forKey:](struct UINibEncoder *self, SEL a2, double a3, id a4)
{
    void (__fastcall *v4)(struct UINibEncoder *, char *, void *); // r14@1
    void *v5; // rax@1
    
    v4 = *objc_msgSend_ptr;
    v5 = objc_msgSend_ptr(
                          classRef_UINibCoderValue,
                          selRef_nibValueForDouble_key_scope_,
                          a4,
                          self->recursiveState.currentObjectID,
                          a3);
    v4(self, selRef_appendValue_, v5);
}
// DBE908: using guessed type char *selRef_appendValue_;
// DBE938: using guessed type char *selRef_nibValueForDouble_key_scope_;
// DD0720: using guessed type void *classRef_UINibCoderValue;
// DDC830: using guessed type __int64 OBJC_IVAR___UINibEncoder_recursiveState;

//----- (0000000000444DCE) ----------------------------------------------------
// UINibEncoder - (void)encodeBytes:(const char *) length:(uint64_t) forKey:(id)
void __cdecl -[UINibEncoder encodeBytes:length:forKey:](struct UINibEncoder *self, SEL a2, const char *a3, uint64_t a4, id a5)
{
    void (__fastcall *v5)(struct UINibEncoder *, char *, void *); // r14@1
    void *v6; // rax@1
    
    v5 = *objc_msgSend_ptr;
    v6 = objc_msgSend_ptr(
                          classRef_UINibCoderValue,
                          selRef_nibValueForBytes_length_key_scope_,
                          a3,
                          a4,
                          a5,
                          self->recursiveState.currentObjectID);
    v5(self, selRef_appendValue_, v6);
}
// DBE908: using guessed type char *selRef_appendValue_;
// DBE940: using guessed type char *selRef_nibValueForBytes_length_key_scope_;
// DD0720: using guessed type void *classRef_UINibCoderValue;
// DDC830: using guessed type __int64 OBJC_IVAR___UINibEncoder_recursiveState;

//----- (0000000000444E11) ----------------------------------------------------
// UINibEncoder - (void)encodeArrayOfDoubles:(double *) count:(int64_t) forKey:(id)
void __cdecl -[UINibEncoder encodeArrayOfDoubles:count:forKey:](struct UINibEncoder *self, SEL a2, double *a3, int64_t a4, id a5)
{
    int64_t v5; // r13@1
    double *v6; // rbx@1
    void (*v7)(void *, const char *, ...); // r14@1
    void *v8; // r12@1
    int (__fastcall *v9)(void *, char *); // rbx@3
    void *v10; // r14@3
    __int64 v11; // rax@3
    id v12; // [sp+10h] [bp-40h]@1
    __int64 v13; // [sp+18h] [bp-38h]@2
    char v14; // [sp+27h] [bp-29h]@1
    
    v12 = a5;
    v5 = a4;
    v6 = a3;
    v7 = *objc_msgSend_ptr;
    v8 = objc_msgSend_ptr(classRef_NSMutableData, selRef_data);
    v14 = 7;
    v7(v8, selRef_appendBytes_length_, &v14, 1LL);
    if ( v5 > 0 )
    {
        do
        {
            v13 = *v6;
            objc_msgSend_ptr(v8, selRef_appendBytes_length_, &v13, 8LL);
            ++v6;
            --v5;
        }
        while ( v5 );
    }
    v9 = *objc_msgSend_ptr;
    v10 = objc_msgSend_ptr(v8, selRef_bytes);
    LODWORD(v11) = v9(v8, selRef_length);
    (v9)(self, selRef_encodeBytes_length_forKey_, v10, v11, v12);
}
// DA4148: using guessed type char *selRef_length;
// DA5D30: using guessed type char *selRef_encodeBytes_length_forKey_;
// DA5DA0: using guessed type char *selRef_bytes;
// DA5DE0: using guessed type char *selRef_appendBytes_length_;
// DA6150: using guessed type char *selRef_data;
// DCEF90: using guessed type __int64 *classRef_NSMutableData;

//----- (0000000000444EE6) ----------------------------------------------------
// UINibEncoder - (void)encodeArrayOfFloats:(float *) count:(int64_t) forKey:(id)
void __cdecl -[UINibEncoder encodeArrayOfFloats:count:forKey:](struct UINibEncoder *self, SEL a2, float *a3, int64_t a4, id a5)
{
    int64_t v5; // r13@1
    float *v6; // rbx@1
    void (*v7)(void *, const char *, ...); // r14@1
    void *v8; // r12@1
    int (__fastcall *v9)(void *, char *); // rbx@3
    void *v10; // r14@3
    __int64 v11; // rax@3
    __int64 v12; // [sp+0h] [bp-40h]@1
    __int64 v13; // [sp+8h] [bp-38h]@1
    int v14; // [sp+10h] [bp-30h]@2
    char v15; // [sp+17h] [bp-29h]@1
    
    v5 = a4;
    v6 = a3;
    v7 = *objc_msgSend_ptr;
    v8 = objc_msgSend_ptr(classRef_NSMutableData, selRef_data, self, a5);
    v15 = 6;
    v7(v8, selRef_appendBytes_length_, &v15, 1LL);
    if ( v5 > 0 )
    {
        do
        {
            v14 = *v6;
            objc_msgSend_ptr(v8, selRef_appendBytes_length_, &v14, 4LL);
            ++v6;
            --v5;
        }
        while ( v5 );
    }
    v9 = *objc_msgSend_ptr;
    v10 = objc_msgSend_ptr(v8, selRef_bytes);
    LODWORD(v11) = v9(v8, selRef_length);
    (v9)(v12, selRef_encodeBytes_length_forKey_, v10, v11, v13);
}
// DA4148: using guessed type char *selRef_length;
// DA5D30: using guessed type char *selRef_encodeBytes_length_forKey_;
// DA5DA0: using guessed type char *selRef_bytes;
// DA5DE0: using guessed type char *selRef_appendBytes_length_;
// DA6150: using guessed type char *selRef_data;
// DCEF90: using guessed type __int64 *classRef_NSMutableData;

//----- (0000000000444FBB) ----------------------------------------------------
// UINibEncoder - (void)encodeArrayOfCGFloats:(double *) count:(int64_t) forKey:(id)
void __cdecl -[UINibEncoder encodeArrayOfCGFloats:count:forKey:](struct UINibEncoder *self, SEL a2, double *a3, int64_t a4, id a5)
{
    objc_msgSend_ptr(self, selRef_encodeArrayOfDoubles_count_forKey_, a3, a4, a5);
}
// DBE948: using guessed type char *selRef_encodeArrayOfDoubles_count_forKey_;

//----- (0000000000444FCD) ----------------------------------------------------
// UINibEncoder - (void)encodeCGPoint:(struct CGPoint) forKey:(id)
// local variable allocation has failed, the output may be wrong!
void __cdecl -[UINibEncoder encodeCGPoint:forKey:](struct UINibEncoder *self, SEL a2, struct CGPoint a3, id a4)
{
    __int64 *v4; // rbx@1
    __int64 v5; // rax@1
    double v6; // [sp+0h] [bp-20h]@1
    double v7; // [sp+8h] [bp-18h]@1
    __int64 v8; // [sp+10h] [bp-10h]@1
    
    v4 = __stack_chk_guard_ptr;
    v8 = *__stack_chk_guard_ptr;
    v6 = a3.var0;
    v7 = a3.var1;
    objc_msgSend_ptr(self, selRef_encodeArrayOfCGFloats_count_forKey_, &v6, 2LL, a4, *&a3.var0, *&a3.var1, v8);
    v5 = *v4;
}
// 444FCD: fragmented variable at xmm1_8:xmm0_8.16 may be wrong
// B629D0: using guessed type __int64 *__stack_chk_guard_ptr;
// DBE950: using guessed type char *selRef_encodeArrayOfCGFloats_count_forKey_;

//----- (000000000044501F) ----------------------------------------------------
// UINibEncoder - (void)encodeCGSize:(struct CGSize) forKey:(id)
// local variable allocation has failed, the output may be wrong!
void __cdecl -[UINibEncoder encodeCGSize:forKey:](struct UINibEncoder *self, SEL a2, struct CGSize a3, id a4)
{
    __int64 *v4; // rbx@1
    __int64 v5; // rax@1
    double v6; // [sp+0h] [bp-20h]@1
    double v7; // [sp+8h] [bp-18h]@1
    __int64 v8; // [sp+10h] [bp-10h]@1
    
    v4 = __stack_chk_guard_ptr;
    v8 = *__stack_chk_guard_ptr;
    v6 = a3.var0;
    v7 = a3.var1;
    objc_msgSend_ptr(self, selRef_encodeArrayOfCGFloats_count_forKey_, &v6, 2LL, a4, *&a3.var0, *&a3.var1, v8);
    v5 = *v4;
}
// 44501F: fragmented variable at xmm1_8:xmm0_8.16 may be wrong
// B629D0: using guessed type __int64 *__stack_chk_guard_ptr;
// DBE950: using guessed type char *selRef_encodeArrayOfCGFloats_count_forKey_;

//----- (0000000000445071) ----------------------------------------------------
// UINibEncoder - (void)encodeCGRect:(struct CGRect) forKey:(id)
void __cdecl -[UINibEncoder encodeCGRect:forKey:](struct UINibEncoder *self, SEL a2, struct CGRect a3, id a4)
{
    __int64 *v4; // rbx@1
    __int64 v5; // rax@1
    __m256i v6; // [sp+0h] [bp-30h]@1
    __int64 v7; // [sp+20h] [bp-10h]@1
    
    v4 = __stack_chk_guard_ptr;
    v7 = *__stack_chk_guard_ptr;
    v6 = a3;
    objc_msgSend_ptr(
                     self,
                     selRef_encodeArrayOfCGFloats_count_forKey_,
                     &v6,
                     4LL,
                     a4,
                     *&a3.var0.var0,
                     *&a3.var0.var1,
                     *&a3.var1.var0,
                     *&a3.var1.var1,
                     v7);
    v5 = *v4;
}
// B629D0: using guessed type __int64 *__stack_chk_guard_ptr;
// DBE950: using guessed type char *selRef_encodeArrayOfCGFloats_count_forKey_;

//----- (00000000004450C9) ----------------------------------------------------
// UINibEncoder - (void)encodeCGAffineTransform:(struct CGAffineTransform) forKey:(id)
void __cdecl -[UINibEncoder encodeCGAffineTransform:forKey:](struct UINibEncoder *self, SEL a2, struct CGAffineTransform a3, id a4)
{
    __int64 *v4; // rbx@1
    __int64 v5; // rax@1
    char v6[48]; // [sp+0h] [bp-40h]@1
    __int64 v7; // [sp+30h] [bp-10h]@1
    
    v4 = __stack_chk_guard_ptr;
    v7 = *__stack_chk_guard_ptr;
    *v6 = a3;
    objc_msgSend_ptr(
                     self,
                     selRef_encodeArrayOfCGFloats_count_forKey_,
                     v6,
                     6LL,
                     a4,
                     *&a3.var0,
                     *&a3.var1,
                     *&a3.var2,
                     *&a3.var3,
                     *&a3.var4,
                     *&a3.var5,
                     v7);
    v5 = *v4;
}
// B629D0: using guessed type __int64 *__stack_chk_guard_ptr;
// DBE950: using guessed type char *selRef_encodeArrayOfCGFloats_count_forKey_;

//----- (0000000000445129) ----------------------------------------------------
// UINibEncoder - (void)encodeUIEdgeInsets:(struct UIEdgeInsets) forKey:(id)
void __cdecl -[UINibEncoder encodeUIEdgeInsets:forKey:](struct UINibEncoder *self, SEL a2, struct UIEdgeInsets a3, id a4)
{
    __int64 *v4; // rbx@1
    __int64 v5; // rax@1
    __m256i v6; // [sp+0h] [bp-30h]@1
    __int64 v7; // [sp+20h] [bp-10h]@1
    
    v4 = __stack_chk_guard_ptr;
    v7 = *__stack_chk_guard_ptr;
    v6 = a3;
    objc_msgSend_ptr(
                     self,
                     selRef_encodeArrayOfCGFloats_count_forKey_,
                     &v6,
                     4LL,
                     a4,
                     *&a3.var0,
                     *&a3.var1,
                     *&a3.var2,
                     *&a3.var3,
                     v7);
    v5 = *v4;
}
// B629D0: using guessed type __int64 *__stack_chk_guard_ptr;
// DBE950: using guessed type char *selRef_encodeArrayOfCGFloats_count_forKey_;

//----- (0000000000445181) ----------------------------------------------------
// UINibEncoder - (id)nextGenericKey
id __cdecl -[UINibEncoder nextGenericKey](struct UINibEncoder *self, SEL a2)
{
    ++self->recursiveState.nextAnonymousKey;
    return objc_msgSend_ptr(classRef_NSString, selRef_stringWithFormat_, &cfstr_Ld_3);
}
// BC6030: using guessed type __CFString cfstr_Ld_3;
// DA3558: using guessed type char *selRef_stringWithFormat_;
// DCEBF0: using guessed type __int64 *classRef_NSString;
// DDC830: using guessed type __int64 OBJC_IVAR___UINibEncoder_recursiveState;

//----- (00000000004451B8) ----------------------------------------------------
// UINibEncoder - (void)encodeObject:(id)
void __cdecl -[UINibEncoder encodeObject:](struct UINibEncoder *self, SEL a2, id a3)
{
    __int64 v3; // rax@0
    id v4; // r14@1
    void (__fastcall *v5)(struct UINibEncoder *, char *, id, void *); // r15@1
    void *v6; // rax@1
    
    v4 = a3;
    v5 = *objc_msgSend_ptr;
    v6 = objc_msgSend_ptr(self, selRef_nextGenericKey, v3);
    v5(self, selRef_encodeObject_forKey_, v4, v6);
}
// DA3670: using guessed type char *selRef_encodeObject_forKey_;
// DBE848: using guessed type char *selRef_nextGenericKey;

//----- (00000000004451F8) ----------------------------------------------------
// UINibEncoder - (void)encodeRootObject:(id)
void __cdecl -[UINibEncoder encodeRootObject:](struct UINibEncoder *self, SEL a2, id a3)
{
    __int64 v3; // rax@0
    id v4; // r14@1
    void (__fastcall *v5)(struct UINibEncoder *, char *, id, void *); // r15@1
    void *v6; // rax@1
    
    v4 = a3;
    v5 = *objc_msgSend_ptr;
    v6 = objc_msgSend_ptr(self, selRef_nextGenericKey, v3);
    v5(self, selRef_encodeObject_forKey_, v4, v6);
}
// DA3670: using guessed type char *selRef_encodeObject_forKey_;
// DBE848: using guessed type char *selRef_nextGenericKey;

//----- (0000000000445238) ----------------------------------------------------
// UINibEncoder - (void)encodeBycopyObject:(id)
void __cdecl -[UINibEncoder encodeBycopyObject:](struct UINibEncoder *self, SEL a2, id a3)
{
    __int64 v3; // rax@0
    id v4; // r14@1
    void (__fastcall *v5)(struct UINibEncoder *, char *, id, void *); // r15@1
    void *v6; // rax@1
    
    v4 = a3;
    v5 = *objc_msgSend_ptr;
    v6 = objc_msgSend_ptr(self, selRef_nextGenericKey, v3);
    v5(self, selRef_encodeObject_forKey_, v4, v6);
}
// DA3670: using guessed type char *selRef_encodeObject_forKey_;
// DBE848: using guessed type char *selRef_nextGenericKey;

//----- (0000000000445278) ----------------------------------------------------
// UINibEncoder - (void)encodeByrefObject:(id)
void __cdecl -[UINibEncoder encodeByrefObject:](struct UINibEncoder *self, SEL a2, id a3)
{
    __int64 v3; // rax@0
    id v4; // r14@1
    void (__fastcall *v5)(struct UINibEncoder *, char *, id, void *); // r15@1
    void *v6; // rax@1
    
    v4 = a3;
    v5 = *objc_msgSend_ptr;
    v6 = objc_msgSend_ptr(self, selRef_nextGenericKey, v3);
    v5(self, selRef_encodeObject_forKey_, v4, v6);
}
// DA3670: using guessed type char *selRef_encodeObject_forKey_;
// DBE848: using guessed type char *selRef_nextGenericKey;

//----- (00000000004452B8) ----------------------------------------------------
// UINibEncoder - (void)encodeConditionalObject:(id)
void __cdecl -[UINibEncoder encodeConditionalObject:](struct UINibEncoder *self, SEL a2, id a3)
{
    __int64 v3; // rax@0
    id v4; // r14@1
    void (__fastcall *v5)(struct UINibEncoder *, char *, id, void *); // r15@1
    void *v6; // rax@1
    
    v4 = a3;
    v5 = *objc_msgSend_ptr;
    v6 = objc_msgSend_ptr(self, selRef_nextGenericKey, v3);
    v5(self, selRef_encodeConditionalObject_forKey_, v4, v6);
}
// DA6768: using guessed type char *selRef_encodeConditionalObject_forKey_;
// DBE848: using guessed type char *selRef_nextGenericKey;

//----- (00000000004452F8) ----------------------------------------------------
// UINibEncoder - (void)encodeValuesOfObjCTypes:(const char *)
void __cdecl -[UINibEncoder encodeValuesOfObjCTypes:](struct UINibEncoder *self, SEL a2, const char *a3)
{
    void *(*v3)(void *, const char *, ...); // r13@1
    void *v4; // r12@1
    void *v5; // rax@1
    
    v3 = *objc_msgSend_ptr;
    v4 = objc_msgSend_ptr(classRef_NSAssertionHandler, selRef_currentHandler, a3);
    v5 = v3(classRef_NSString, selRef_stringWithUTF8String_, "/SourceCache/UIKit_Sim/UIKit-3318.16.14/UINibEncoder.m");
    v3(v4, selRef_handleFailureInMethod_object_file_lineNumber_description_, a2, self, v5, 456LL, &stru_B9FBB0);
}
// B9FBB0: using guessed type __CFString stru_B9FBB0;
// DA3538: using guessed type char *selRef_currentHandler;
// DA3540: using guessed type char *selRef_stringWithUTF8String_;
// DA3548: using guessed type char *selRef_handleFailureInMethod_object_file_lineNumber_description_;
// DCEBE8: using guessed type __int64 *classRef_NSAssertionHandler;
// DCEBF0: using guessed type __int64 *classRef_NSString;

//----- (00000000004453C5) ----------------------------------------------------
// UINibEncoder - (void)encodeArrayOfObjCType:(const char *) count:(uint64_t) at:(const void *)
void __cdecl -[UINibEncoder encodeArrayOfObjCType:count:at:](struct UINibEncoder *self, SEL a2, const char *a3, uint64_t a4, const void *a5)
{
    __int64 v5; // rax@0
    void *(*v6)(void *, const char *, ...); // r13@1
    void *v7; // r12@1
    void *v8; // rax@1
    
    v6 = *objc_msgSend_ptr;
    v7 = objc_msgSend_ptr(classRef_NSAssertionHandler, selRef_currentHandler, a3, a4, a5, v5);
    v8 = v6(classRef_NSString, selRef_stringWithUTF8String_, "/SourceCache/UIKit_Sim/UIKit-3318.16.14/UINibEncoder.m");
    v6(v7, selRef_handleFailureInMethod_object_file_lineNumber_description_, a2, self, v8, 460LL, &stru_B9FBB0);
}
// B9FBB0: using guessed type __CFString stru_B9FBB0;
// DA3538: using guessed type char *selRef_currentHandler;
// DA3540: using guessed type char *selRef_stringWithUTF8String_;
// DA3548: using guessed type char *selRef_handleFailureInMethod_object_file_lineNumber_description_;
// DCEBE8: using guessed type __int64 *classRef_NSAssertionHandler;
// DCEBF0: using guessed type __int64 *classRef_NSString;

//----- (0000000000445447) ----------------------------------------------------
// UINibEncoder - (void)encodeBytes:(const void *) length:(uint64_t)
void __cdecl -[UINibEncoder encodeBytes:length:](struct UINibEncoder *self, SEL a2, const void *a3, uint64_t a4)
{
    uint64_t v4; // r14@1
    const void *v5; // r15@1
    void (__fastcall *v6)(struct UINibEncoder *, char *, const void *, uint64_t, void *); // r12@1
    void *v7; // rax@1
    
    v4 = a4;
    v5 = a3;
    v6 = *objc_msgSend_ptr;
    v7 = objc_msgSend_ptr(self, selRef_nextGenericKey);
    v6(self, selRef_encodeBytes_length_forKey_, v5, v4, v7);
}
// DA5D30: using guessed type char *selRef_encodeBytes_length_forKey_;
// DBE848: using guessed type char *selRef_nextGenericKey;

//----- (000000000044548C) ----------------------------------------------------
// UINibEncoder - (void)encodeValueOfObjCType:(const char *) at:(const void *)
void __cdecl -[UINibEncoder encodeValueOfObjCType:at:](struct UINibEncoder *self, SEL a2, const char *a3, const void *a4)
{
    const char **v4; // r15@1
    const char *v5; // rbx@1
    signed int v6; // eax@2
    const char *v7; // rbx@4
    size_t v8; // r15@4
    void (__fastcall *v9)(struct UINibEncoder *, char *, const char *, size_t, void *); // r12@4
    void *v10; // rax@4
    const char *v11; // rbx@8
    double v12; // xmm0_8@12
    const char *v13; // rax@15
    void (__fastcall *v14)(struct UINibEncoder *, char *, const char *, void *); // r15@16
    void *v15; // rax@16
    char *v16; // rsi@16
    unsigned int v17; // ebx@18
    void (__fastcall *v18)(struct UINibEncoder *, char *, _QWORD, void *); // r15@18
    void *v19; // rax@18
    const char *v20; // xmm0_8@21
    void (__fastcall *v21)(struct UINibEncoder *, char *, void *); // rbx@22
    void *v22; // rax@22
    
    v4 = a4;
    v5 = a3;
    if ( strlen(a3) != 1 )
        return;
    v6 = *v5;
    if ( v6 <= 57 )
    {
        if ( v6 == 42 )
        {
            v7 = *v4;
            v8 = strlen(*v4) + 1;
            v9 = *objc_msgSend_ptr;
            v10 = objc_msgSend_ptr(self, selRef_nextGenericKey);
            v9(self, selRef_encodeBytes_length_forKey_, v7, v8, v10);
        }
        return;
    }
    v6 = v6;
    if ( v6 > 99 )
    {
        if ( v6 > 112 )
        {
            if ( v6 == 113 )
            {
                v11 = *v4;
            }
            else
            {
                if ( v6 != 115 )
                    return;
                v11 = *v4;
            }
        }
        else
        {
            if ( v6 == 100 )
            {
                v20 = *v4;
                goto LABEL_22;
            }
            if ( v6 == 102 )
            {
                v12 = *v4;
            LABEL_22:
                v21 = *objc_msgSend_ptr;
                v22 = objc_msgSend_ptr(self, selRef_nextGenericKey);
                v21(self, selRef_encodeDouble_forKey_, v22);
                return;
            }
            if ( v6 != 105 )
                return;
            v11 = *v4;
        }
        v14 = *objc_msgSend_ptr;
        v15 = objc_msgSend_ptr(self, selRef_nextGenericKey);
        v16 = selRef_encodeInteger_forKey_;
        goto LABEL_26;
    }
    if ( v6 == 58 )
    {
        LODWORD(v13) = NSStringFromSelector(*v4);
        v11 = v13;
        goto LABEL_16;
    }
    if ( v6 == 64 )
    {
        v11 = *v4;
    LABEL_16:
        v14 = *objc_msgSend_ptr;
        v15 = objc_msgSend_ptr(self, selRef_nextGenericKey);
        v16 = selRef_encodeObject_forKey_;
    LABEL_26:
        v14(self, v16, v11, v15);
        return;
    }
    if ( v6 == 66 )
    {
        v17 = *v4;
        v18 = *objc_msgSend_ptr;
        v19 = objc_msgSend_ptr(self, selRef_nextGenericKey);
        v18(self, selRef_encodeBool_forKey_, v17, v19);
    }
}
// 7E7A66: using guessed type int __fastcall NSStringFromSelector(_QWORD);
// DA3670: using guessed type char *selRef_encodeObject_forKey_;
// DA3678: using guessed type char *selRef_encodeBool_forKey_;
// DA5D28: using guessed type char *selRef_encodeInteger_forKey_;
// DA5D30: using guessed type char *selRef_encodeBytes_length_forKey_;
// DAEE20: using guessed type char *selRef_encodeDouble_forKey_;
// DBE848: using guessed type char *selRef_nextGenericKey;

//----- (000000000044565E) ----------------------------------------------------
// UINibEncoder - (id)delegate
id __cdecl -[UINibEncoder delegate](struct UINibEncoder *self, SEL a2)
{
    return *(&self->delegate + 4);
}

//----- (000000000044566F) ----------------------------------------------------
// UINibEncoder - (void)setDelegate:(id)
void __cdecl -[UINibEncoder setDelegate:](struct UINibEncoder *self, SEL a2, id a3)
{
    *(&self->delegate + 4) = a3;
}

//----- (0000000000445680) ----------------------------------------------------
// UINibStringIDTable - (id)initWithKeysTransferingOwnership:(id *) count:(uint64_t) 
id __cdecl -[UINibStringIDTable initWithKeysTransferingOwnership:count:](struct UINibStringIDTable *self, SEL a2, id *a3, uint64_t a4)
{
    uint64_t v4; // r15@1
    id *v5; // rbx@1
    struct objc_object *v6; // r12@1
    id *v7; // r14@2
    signed __int64 v8; // rcx@2
    size_t v9; // rbx@3
    __int64 v10; // r15@5
    void *v11; // rbx@5
    char *v12; // r13@6
    void *v13; // rax@6
    unsigned __int64 v14; // rax@6
    struct UINibStringIDTable *v16; // [sp+8h] [bp-38h]@1
    void *v17; // [sp+10h] [bp-30h]@1
    
    v4 = a4;
    v5 = a3;
    v16 = self;
    v17 = classRef_UINibStringIDTable_0;
    v6 = objc_msgSendSuper2(&v16, selRef_init);
    if ( v6 )
    {
        v7 = v5;
        v8 = 2LL;
        do
        {
            v9 = v8;
            v8 *= 2LL;
        }
        while ( v9 <= 2 * v4 );
        v6[1].isa = calloc(8uLL, v9);
        v6[2].isa = malloc(24 * v4);
        v6[3].isa = (v9 - 1);
        v6[4].isa = v4;
        if ( v4 )
        {
            v10 = 0LL;
            v11 = 0LL;
            do
            {
                v12 = v6[2].isa;
                v13 = objc_msgSend_ptr(v7[v11], selRef_hash);
                *&v12[v10 + 8] = v13;
                *&v12[v10] = v7[v11];
                v14 = v6[3].isa & v13;
                *&v12[v10 + 16] = *(v6[1].isa + v14);
                *(v6[1].isa + v14) = &v12[v10];
                v11 = v11 + 1;
                v10 += 24LL;
            }
            while ( v11 < v6[4].isa );
        }
    }
    return v6;
}
// DA37F0: using guessed type char *selRef_init;
// DA6148: using guessed type char *selRef_hash;
// DD2B58: using guessed type void *classRef_UINibStringIDTable_0;
// DDC848: using guessed type __int64 OBJC_IVAR___UINibStringIDTable_table;
// DDC850: using guessed type __int64 OBJC_IVAR___UINibStringIDTable_buckets;
// DDC858: using guessed type __int64 OBJC_IVAR___UINibStringIDTable_hashMask;
// DDC860: using guessed type __int64 OBJC_IVAR___UINibStringIDTable_count;

//----- (00000000004457CA) ----------------------------------------------------
// UINibStringIDTable - (void)dealloc
void __cdecl -[UINibStringIDTable dealloc](struct UINibStringIDTable *self, SEL a2)
{
    signed __int64 v2; // rax@1
    __int64 v3; // rbx@2
    unsigned __int64 v4; // r15@2
    signed __int64 v5; // r12@3
    struct UINibStringIDTable *v6; // [sp+8h] [bp-38h]@4
    void *v7; // [sp+10h] [bp-30h]@4
    
    v2 = 32LL;
    if ( self->count )
    {
        v3 = 0LL;
        v4 = 0LL;
        do
        {
            v5 = v2;
            objc_msgSend_ptr(self->buckets[v3].var0, selRef_release);
            v2 = v5;
            ++v4;
            ++v3;
        }
        while ( v4 < *&self->NSObject_opaque[v5] );
    }
    free(self->table);
    free(self->buckets);
    v6 = self;
    v7 = classRef_UINibStringIDTable_0;
    objc_msgSendSuper2(&v6, selRef_dealloc);
}
// DA3380: using guessed type char *selRef_release;
// DA3508: using guessed type char *selRef_dealloc;
// DD2B58: using guessed type void *classRef_UINibStringIDTable_0;
// DDC848: using guessed type __int64 OBJC_IVAR___UINibStringIDTable_table;
// DDC850: using guessed type __int64 OBJC_IVAR___UINibStringIDTable_buckets;
// DDC860: using guessed type __int64 OBJC_IVAR___UINibStringIDTable_count;

//----- (0000000000445876) ----------------------------------------------------
// UINibStringIDTable - (bool)lookupKey:(id) identifier:(int64_t *) 
bool __cdecl -[UINibStringIDTable lookupKey:identifier:](struct UINibStringIDTable *self, SEL a2, id a3, int64_t *a4)
{
    __int64 v4; // rax@0
    int64_t *v5; // r13@1
    id v6; // r12@1
    void *v7; // rbx@1
    struct UIStringIDTableBucket *v8; // r14@1
    bool v9; // bl@7
    void *(*v10)(void *, const char *, ...); // r15@9
    int64_t *v12; // [sp+0h] [bp-30h]@2
    
    v5 = a4;
    v6 = a3;
    v7 = objc_msgSend_ptr(a3, selRef_hash, v4);
    v8 = self->table[v7 & self->hashMask];
    if ( v8 )
    {
        v12 = v5;
        while ( v8->var1 != v7 || v8->var0 != v6 && !objc_msgSend_ptr(v8->var0, selRef_isEqualToString_, v6, v12) )
        {
            v8 = v8->var2;
            if ( !v8 )
                goto LABEL_7;
        }
        *v12 = 0xAAAAAAAAAAAAAAABLL * ((v8 - self->buckets) >> 3);
        v9 = 1;
        if ( v8->var0 != v6 )
        {
            v10 = *objc_msgSend_ptr;
            objc_msgSend_ptr(v8->var0, selRef_release, v12);
            v8->var0 = v10(v6, selRef_copy);
        }
    }
    else
    {
    LABEL_7:
        v9 = 0;
    }
    return v9;
}
// DA3380: using guessed type char *selRef_release;
// DA3418: using guessed type char *selRef_isEqualToString_;
// DA38B0: using guessed type char *selRef_copy;
// DA6148: using guessed type char *selRef_hash;
// DDC848: using guessed type __int64 OBJC_IVAR___UINibStringIDTable_table;
// DDC850: using guessed type __int64 OBJC_IVAR___UINibStringIDTable_buckets;
// DDC858: using guessed type __int64 OBJC_IVAR___UINibStringIDTable_hashMask;

//----- (000000000044595B) ----------------------------------------------------
// UINibStringIDTable - (int64_t)count
int64_t __cdecl -[UINibStringIDTable count](struct UINibStringIDTable *self, SEL a2)
{
    return self->count;
}
// DDC860: using guessed type __int64 OBJC_IVAR___UINibStringIDTable_count;
*/
@end
