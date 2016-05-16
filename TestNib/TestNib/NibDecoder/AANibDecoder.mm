//
//  AANibDecoder.m
//  TestNib
//
//  Created by AB on 5/8/16.
//  Copyright © 2016 Intellectsoft Group. All rights reserved.
//

#import "AANibDecoder.h"
#import "AAProxyObject.h"
#import <objc/runtime.h>

const int UIMaximumCompatibleFormatVersion = 9000;

typedef NS_ENUM(int, AANibType) {
    AANibTypeInt8 =  0,
    AANibTypeInt16 = 1,
    AANibTypeInt32 = 2,
    AANibTypeInt64 = 3,
    AANibTypeFalse = 4,
    AANibTypeTrue  = 5,
    AANibTypeFloat = 6,
    AANibTypeDouble= 7,
    AANibTypeData  = 8,
    AANibTypeNull  = 9,
    AANibTypeUID   = 10,
};

int UIFixedByteLengthForType_table[11] = { 1LL, 2LL, 4LL, 8LL, 0LL, 0LL, 4LL, 8LL, -1LL, 0LL, 4LL };


typedef struct UIKeyToKeyIDCache {
    NSString *previousKey[64];
    void *previousKeyID[64];
    BOOL previousKeyExists[64];
    NSInteger hashHits;
    NSInteger hashHotMisses;
    NSInteger hashColdMisses;
} UIKeyToKeyIDCache;

void UIFreeMissingClasses(__unsafe_unretained id* objects, uint32_t count)
{
    if (*objects) {
        for (int i = 0; i < count; i++) {
            objects[i] = nil;
        }
        free((void *)objects);
        *objects = nil;
    }
}

int AAFixedByteLengthForType(unsigned char type)
{
    int result;
    result = -2;
    if ( (type & 0x80) == 0 && type <= 0xA ) {
        result = UIFixedByteLengthForType_table[type];
    }
    return result;
}

@implementation AANibDecoder {
    Class arrayClass;
    Class setClass;
    Class dictionaryClass;
    Class* classes; //32?
    __unsafe_unretained id* missingClasses; //40
    UINibDecoderObjectEntry* objects; //48
    UINibDecoderValue* values; //56
    char* valueTypes; //64
    void* valueData; //72
    NSUInteger valueDataSize; //80
    UINibDecoderHeader _header; //88 + 52(56)
    __strong id* objectsByObjectID; //144
    unsigned* longObjectClassIDs; //152
    char* shortObjectClassIDs; //160
    unsigned* keyMasks; //168
    NSInteger inlinedValueKey; //176
    UINibDecoderRecursiveState recursiveState; //184 + 24
    AANibStringIDTable* keyIDTable; //208  //26?
    id delegate; //216
    UIKeyToKeyIDCache* keyIDCache; //224
    UIKeyAndScopeToValueCache* valueCache; //232
    NSInteger lookupRounds; //240
    NSInteger maxPossibleLookupRounds; //248
    NSInteger failedByKeyMask; //256
    NSInteger savedByKeyMask; //264
}

- (instancetype)initForReadingWithData:(NSData *)data error:(NSError **)error
{
    self = [super init];
    if (self) {
        NSError *resultError = nil;
        if (data && [self validateAndIndexData:data error:&resultError]) {
            
            self->recursiveState.objectID = 0; //self->23 = 0;
            //TODO: self->335 = [self->keyIDTable count] + 1;
            if (![self->keyIDTable lookupKey:@"NSInlinedValue" identifier:&self->inlinedValueKey]) {
                self->inlinedValueKey = [self->keyIDTable count] + 1; //self->22 = [self->keyIDTable count] + 1;
            }
            
            arrayClass = [NSArray class];
            setClass = [NSSet class];
            dictionaryClass = [NSDictionary class];
        }
        else {
            if (error) {
                *error = resultError;
            }
            return nil;
        }
    }
    return self;
}

- (instancetype)initForReadingWithData:(NSData *)data
{
    return [self initForReadingWithData:data error:nil];
}

- (void)dealloc
{
    //TODO: if (self != -224) { //?
        for (int i = 0; i < 64; i++) {
            //keyIDCache.previousKey[i] = nil; //release
        }
    //}
    if (objectsByObjectID && _header.objects.count) {
        for (int i = 0; i < _header.objects.count; i++) {
            //objectsByObjectID[i] = nil;
        }
    }
    
    UIFreeMissingClasses(missingClasses, _header.classes.count);
    free(self->classes);
    free(self->objects);
    free(self->values);
    free(self->valueData);
    free(self->objectsByObjectID);
    free(self->shortObjectClassIDs);
    free(self->longObjectClassIDs);
    free(self->valueTypes);
    free(self->keyMasks);
    self->keyIDTable = nil; //release
}

- (bool)validateAndIndexData:(NSData *)data error:(NSError **)error
{
    const char *bytes = (const char *)data.bytes;
    NSUInteger length = data.length;
    NSString *errorMessage = nil;
    BOOL success = NO;
    if (length >= 10) {
        memcpy(_header.type, bytes, 10);
        if ((length - 10) >= 4) {
            _header.formatVersion = *(bytes + 10);
            if ( length >= 0xE && (length - 14) >= 4 ) {
                _header.coderVersion = *(int *)(bytes + 0xE);
                if ( length >= 0x12 && (length - 18) >= 4 ) {
                    _header.objects.count = *(int *)(bytes  +0x12);
                    if ( length >= 0x16 && (length - 22) >= 4 ) {
                        _header.objects.offset = *(int *)(bytes + 0x16);
                        if ( length >= 0x1A && (length - 26) >= 4 ) {
                            _header.keys.count = *(int *)(bytes + 0x1A);
                            if ( length >= 0x1E && (length - 30) >= 4 ) {
                                _header.keys.offset = *(int *)(bytes + 0x1E);
                                if ( length >= 0x22 && (length - 34) >= 4 ) {
                                    _header.values.count = *(int *)(bytes + 0x22);
                                    if ( length >= 0x26 && (length - 38) >= 4 ) {
                                        _header.values.offset = *(int *)(bytes + 0x26);
                                        if ( length >= 0x2A && (length - 42) >= 4 ) {
                                            _header.classes.count = *(int *)(bytes + 0x2A);
                                            if ( length >= 0x2E && (length - 46) >= 4 ) {
                                                _header.classes.offset = *(int *)(bytes + 0x2E);
                                                if (!memcmp(_header.type, "NIBArchive", 10)) {
                                                    if (_header.formatVersion > UIMaximumCompatibleFormatVersion) {
                                                        errorMessage = @"The NIB data is too new for this version of iOS.";
                                                    }
                                                    else {
                                                        if (![self validateAndIndexClasses:bytes length:length]) {
                                                            errorMessage = @"The class data is invalid.";
                                                        }
                                                        else {
                                                            if (![self validateAndIndexKeys:bytes length:length]) {
                                                                errorMessage = @"The key data is invalid.";
                                                            }
                                                            else {
                                                                if (![self validateAndIndexValues:bytes length:length]) {
                                                                    errorMessage = @"The value data is invalid.";
                                                                }
                                                                else {
                                                                    success = [self validateAndIndexObjects:bytes length:length];
                                                                    if (!success) {
                                                                        errorMessage = @"The object data is invalid.";
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    if (error && !success) {
        NSString *message = errorMessage ?: @"The NIB data is invalid.";
        *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:message}];
    }
    return success;
}

inline bool readInt(const void *buffer, unsigned long length, int pos, int* pvalue) {
    const char *chars = (const char *)buffer;
    unsigned long left = length - pos;
    if (left < 5) {
        int32_t value = 0;
        memcpy(&value, &chars[pos], left);
        *pvalue = value;

        switch (left) {
            case 1:
                if ( (value & 0x80) == 0 )
                    return false;
            case 2:
                if ( (value & 0x8000) == 0)
                    return false;
            case 3:
                if ( (value & 0x800000) == 0)
                    return false;
            case 4:
                if ( (value & 0x80000000) == 0)
                    return false;
            default:
                return false;
        }
    }
    else {
        *pvalue = *(int32_t*)&chars[pos];
    }
    return true;
}

inline int decodeIntValue(int value, const void *buffer, unsigned int *poffset) {
    const char *chars = (const char *)buffer;
    int result;
    if ( value & 0x80 )
    {
        result = value & 0x7F;
        *poffset += 1;
    }
    else if ( value & 0x8000 )
    {
        result = ((value >> 1) & 0x3F80) | (value & 0x7F);
        *poffset += 2;
    }
    else if ( value & 0x800000 )
    {
        result = ((value >> 2) & 0x1FC000) | ((value >> 1) & 0x3F80) | (value & 0x7F);
        *poffset += 3;
    }
    else if ( value & 0x80000000 )
    {
        result = ((value >> 1) & 0x3F80) | ((value >> 3) & 0xFE00000) | ((value >> 2) & 0x1FC000) | (value & 0x7F);
        *poffset += 4;
    }
    else
    {
        result = (chars[*poffset + 4] << 28) | ((value >> 1) & 0x3F80) | ((value >> 2) & 0x1FC000) | ((value >> 3) & 0xFE00000) | (value & 0x7F);
        *poffset += 5;
    }
    return result;
}

- (bool)validateAndIndexClasses:(const void *)bytesPtr length:(unsigned long)bytesLength
{
    UINibDecoderHeader header;
    header.classes.count = _header.classes.count;
    header.classes.offset = _header.classes.offset;
    bool result = header.classes.offset <= bytesLength;
    
    unsigned long bytesLength_local = bytesLength;
    const char *bytesPtr_local = (const char *)bytesPtr;
    
    NSLog(@"START: %d", header.classes.offset);
    
    BOOL hasMissingClasses = 0; //v75
    int v74allocated = 0;
    int allocatedClasses = 0;

    for (int index = 0; index < header.classes.count; index++) {
        if (index == allocatedClasses) {
            if ( header.classes.count <= allocatedClasses + 128 ) {
                allocatedClasses = header.classes.count;
            }
            else {
                allocatedClasses += 128;
            }
            self->classes = (Class*)realloc(self->classes, sizeof(Class) * allocatedClasses);
            self->missingClasses = (__unsafe_unretained id *)realloc(self->missingClasses, sizeof(id) * allocatedClasses);
        }

        if (header.classes.offset > bytesLength_local) {
            result = false;
            break;
        }
        
        int readValue = 0;
        if (!readInt(bytesPtr_local, bytesLength_local, header.classes.offset, &readValue)) {
            result = false;
            break;
        }

        int length = decodeIntValue(readValue, bytesPtr_local, &header.classes.offset);
        if ( header.classes.offset > bytesLength_local ) {
            result = false;
            break;
        }
        
        readValue = 0;
        if (!readInt(bytesPtr_local, bytesLength_local, header.classes.offset, &readValue)) {
            result = false;
            break;
        }
        
        unsigned int newOffset = header.classes.offset;
        int count = decodeIntValue(readValue, bytesPtr_local, &newOffset);
        unsigned int nameOffset = newOffset;
        
        if (newOffset > bytesLength_local || (bytesLength_local - newOffset < 4 * count)) {
            result = false;
            break;
        }
        
        nameOffset = 4 * count + newOffset;
        NSLog(@"offset: %d, count: %d, nameOffset: %d", newOffset, count, nameOffset);
        if (nameOffset > bytesLength_local || (bytesLength_local - nameOffset < length)) {
            result = false;
            break;
        }
        
        header.classes.offset = nameOffset + length;
        if ( !length ) {
            result = false;
            break;
        }

        int nameLength = (length - 1);
        if ( bytesPtr_local[nameOffset + nameLength] ) {
            result = false;
            break;
        }
        
        unsigned int nextOffset = nameOffset + length;
        const char *name = &bytesPtr_local[nameOffset];
        NSString *className = [[NSString alloc] initWithBytes:name length:nameLength encoding:4];
        if (!className) {
            result = false;
            break;
        }
        
        NSLog(@"CLASS: %@", className);
        self->classes[index] = [NSKeyedUnarchiver classForClassName:className];
        if ( !self->classes[index])
        {
            self->classes[index] = objc_lookUpClass(name);
        }
        Class classVar = self->classes[index];
        NSString *missingClass = nil;
        if ( !classVar )
        {
            missingClass = className;
        }
        hasMissingClasses = hasMissingClasses || (classVar == nil);
        missingClasses[index] = missingClass;
        v74allocated = index + 1;
        
        header.classes.offset = nextOffset;
    }

    if (result) {
        //TODO: later
        if (hasMissingClasses) {
            
            unsigned int currentOffset = _header.classes.offset;
            result = currentOffset <= bytesLength_local;
            int v82 = 0;
            
            if ( _header.classes.count )
            {
                if ( currentOffset <= bytesLength_local )
                {
                    v82 = 0;
                    while ( 1 )
                    {
                        if ( currentOffset > bytesLength_local )
                        {
                            result = false;
                            break;
                        }
                        
                    breakLabel:
                        int v51;
                        if (!readInt(bytesPtr_local, bytesLength_local, currentOffset, &v51)) {
                            return false;
                        }
                        
                        int v54 = decodeIntValue(v51, bytesPtr_local, &currentOffset);
                        if ( currentOffset > bytesLength_local )
                        {
                            result = false;
                            break;
                        }
                        
                        int v81 = v54;
                        int v56;
                        if (!readInt(bytesPtr_local, bytesLength_local, currentOffset, &v56)) {
                            result = false;
                            break;
                        }
                        
                        int v59 = decodeIntValue(v56, bytesPtr_local, &currentOffset);
                        
                        int v85 = v59;
                        bool v60 = true;
                        int v61 = 0;
                        int v62 = 0;
                        if ( v59 )
                        {
                            do
                            {
                                Class *v63 = self->classes;
                                if ( v63[v82] )
                                    goto breakLabel;
                                
                                if ( v60 )
                                {
                                    v60 = false;
                                    if ( currentOffset <= bytesLength_local && bytesLength_local - currentOffset >= 4 )
                                    {
                                        //TODO:
/*                                        int v64 = *(int *)&bytesPtr_local[currentOffset];
                                        currentOffset += 4;
                                        v60 = v64 < *(&self->missingClasses + 88 + 4);
                                        if ( v64 < *(&self->missingClasses + 88 + 4) )
                                        {
                                            v65 = v63[v64];
                                            if ( v65 )
                                            {
                                                v63[v82] = v65;
                                                //objc_msgSend_ptr(v45->missingClasses[v82], selRef_release);
                                                self->missingClasses[v82] = 0;
                                            }
                                        }*/
                                        v59 = v85;
                                    }
                                }
                                ++v61;
                            }
                            while ( v59 > v61 );
                            v62 = v59;
                            if ( !v60 ) {
                                result = false;
                                break;
                            }
                        }
                        int v67 = v62 - v61;
                        result = false;
                        if ( currentOffset <= bytesLength_local )
                        {
                            int v68 = 4 * v67;
                            if ( bytesLength_local - currentOffset >= v68 )
                            {
                                int v69 = currentOffset + v68;
                                int v70 = v81;
                                result = v69 <= bytesLength_local && bytesLength_local - v69 >= v81;
                                if ( !result ) {
                                    v70 = 0LL;
                                }
                                //TODO:
                                /*if ( ++v82 < *(&self->missingClasses + 88 + 4) )
                                {
                                    currentOffset = v69 + v70;
                                    if ( stop )
                                        continue;
                                }*/
                            }
                        }
                        return result;
                    }
                }
            }
        }
    }
    else {
        UIFreeMissingClasses(missingClasses, v74allocated);
    }
    return result;
}

//----- (000000000043FBA8) ----------------------------------------------------
// UINibDecoder - (bool)validateAndIndexObjects:(const void *) length:(uint64_t)
- (bool)validateAndIndexObjects:(const void *)bytesPtr length:(unsigned long)bytesLength
{
    unsigned long v4length = bytesLength;
    //v5 = self;
    //v7 = self->header.objects.count;
    unsigned int v8offset = _header.objects.offset;
    bool v9result = v8offset <= v4length;
    int v10index = 0;
    int v11allocated = 0;

    NSLog(@"START OBJECT: %d", v8offset);
    for (int v10index = 0; v10index < _header.objects.count; v10index++)
    {
        if ( v10index == v11allocated )
        {
            v11allocated = v11allocated + 128;
            if ( _header.objects.count <= v11allocated ) {
                v11allocated = _header.objects.count;
            }
            self->objects = (UINibDecoderObjectEntry *)realloc(self->objects, sizeof(UINibDecoderObjectEntry) * v11allocated);
            if ( self->_header.classes.count <= 255 )
            {
                self->shortObjectClassIDs = (char *)realloc(self->shortObjectClassIDs, v11allocated);
            }
            else
            {
                self->longObjectClassIDs = (unsigned int *)realloc(self->longObjectClassIDs, sizeof(unsigned int) * v11allocated);
            }
            self->keyMasks = (unsigned int *)realloc(self->keyMasks, sizeof(unsigned int) * v11allocated);
        }

        if ( v8offset > v4length ) {
            return false;
        }
        
        int readValue;
        if (!readInt(bytesPtr, v4length, v8offset, &readValue)) {
            return false;
        }
        
        int classID = decodeIntValue(readValue, bytesPtr, &v8offset);
        if ( v8offset > v4length ) {
            return false;
        }
        
        if (!readInt(bytesPtr, v4length, v8offset, &readValue)) {
            return false;
        }

        int value = decodeIntValue(readValue, bytesPtr, &v8offset);
        self->objects[v10index].x1 = value;

        if ( v8offset > v4length ) {
            return false;
        }
        
        if (!readInt(bytesPtr, v4length, v8offset, &readValue)) {
            return false;
        }
        
        int value2 = decodeIntValue(readValue, bytesPtr, &v8offset);
        self->objects[v10index].x2 = value2;
        if ( classID >= _header.classes.count ) {
            return false;
        }

        if ( self->objects[v10index].x1 + self->objects[v10index].x2 <= _header.values.count )
        {
            if ( self->shortObjectClassIDs )
            {
                self->shortObjectClassIDs[v10index] = classID;
            }
            else
            {
                self->longObjectClassIDs[v10index] = classID;
            }
            int v52 = self->objects[v10index].x2;
            if ( v52 )
            {
                int v53 = self->objects[v10index].x1;
                int v56 = 0; //self->keyMasks[v10index];
                do
                {
                    v56 |= 1 << ((self->values[v53].valueID) & 0xFF);
                    self->keyMasks[v10index] = v56;
                    ++v53;
                    --v52;
                }
                while ( v52 );
            }
            
            NSLog(@"OBJECT: %d, %d, %d, %u", classID, self->objects[v10index].x1, self->objects[v10index].x2, self->keyMasks[v10index]);
        }
    }
    
    if ( v9result )
    {
        if ( _header.objects.count )
        {
            self->objectsByObjectID = (__strong id *)calloc(_header.objects.count, 8);
        }
        
        if ( v11allocated > _header.objects.count )
        {
            self->objects = (UINibDecoderObjectEntry *)realloc(self->objects, 8 * _header.objects.count);
            if ( self->shortObjectClassIDs )
            {
                self->shortObjectClassIDs = (char *)realloc(self->shortObjectClassIDs, _header.objects.count);
            }
            else
            {
                self->longObjectClassIDs = (unsigned int*)realloc(self->longObjectClassIDs, 4 * _header.objects.count);
            }
            self->keyMasks = (unsigned int *)realloc(self->keyMasks, 4 * _header.objects.count);
        }
        
        return true;
    }
    return false;
}

- (bool)validateAndIndexValues:(const void *)bytesPtr length:(unsigned long)bytesLength
{
    const char *charsPtr = (const char *)bytesPtr;
    int count = _header.values.count; //v5
    unsigned int offset = _header.values.offset; //v6
    bool result = offset <= bytesLength;
    
    int allocated = 0; //v61
    int index = 0; //v8
    int v67 = 0;
    
    NSLog(@"START VALUES: %d", offset);
    
    for (int index = 0; index < _header.values.count && result; index++) {

        if ( index == allocated )
        {
            allocated = allocated + 128;
            if ( _header.values.count <= allocated )
                allocated = _header.values.count;
            self->values = (UINibDecoderValue *)realloc(self->values, sizeof(UINibDecoderValue) * allocated);
            self->valueTypes = (char *)realloc(self->valueTypes, allocated);
        }
        
        //v12 = v69;
        int flag = false; //TODO:
        if ( offset <= bytesLength )
        {
            int v16;
            if (readInt(bytesPtr, bytesLength, offset, &v16)) {
                self->values[index].valueID = decodeIntValue(v16, bytesPtr, &offset);
                
                if ( offset < bytesLength )
                {
                    self->valueTypes[index] = charsPtr[offset];
                    offset = offset + 1;
                    flag = true;
                }
                
                NSLog(@"VALUEID: %d, offset: %d, type: %d", self->values[index].valueID, offset, self->valueTypes[index]);
            }
        }
        
        //        LABEL_34:
        int fixedLength = AAFixedByteLengthForType(self->valueTypes[index]);
        int len = fixedLength;
        result  = flag & (fixedLength != -2);
        if ( !result ) {
            break;
        }
        
        int len21 = 0;
        if ( fixedLength == -1 )
        {
            if ( offset > bytesLength )
            {
                result = NO;
                break;
            }
            
            int v27;
            if (!readInt(bytesPtr, bytesLength, offset, &v27)) {
                result = NO;
                break;
            }
            
            len = decodeIntValue(v27, bytesPtr, &offset);
            len21 = len;
            //v21 = v48 = v19;
        }
        
        result = false;
        if ( offset <= bytesLength && bytesLength - offset >= len )
        {
            int v25 = v67;
            self->values[index].offset = v67;
            if ( fixedLength == -1 )
            {
                int v28 = len21 & 0x7F;
                int v66 = v28 + 128;
                
                int v29 = (v28 | 2 * len21) & 0x7F00;
                int v63 = v29 + 0x8000;
                
                int v30 = (v29 | 4 * len21) & 0x7F0000;
                int v62 = v30 + 0x800000;
                
                int v60 = (v30 | 8 * len21) & 0x7F000000;
                
                int v59 = len21 >> 28;
                int v71, v35;
                for ( ; ; )
                {
                    int v34 = v63;
                    if ( len21 < 0x80 )
                        v34 = v66;
                    v35 = (len21 > 0x7F) + 1LL;
                    if ( len21 >= 0x4000 )
                        v34 = v62;
                    if ( len21 >= 0x4000 )
                        v35 = 3LL;
                    if ( len21 >= 0x200000 )
                        v34 = v60 + 2147483648;
                    if ( len21 >= 0x200000 )
                        v35 = 4LL;
                    unsigned long valueSize = self->valueDataSize;
                    if ( len21 >= 0x10000000 )
                    {
                        v34 = v60;
                        v35 = 5;
                    }
                    v71 = v34;
                    if ( valueSize >= v67 && valueSize - v67 >= v35 )
                        break;
                    
                    unsigned long newValueSize = valueSize + 512;
                    self->valueDataSize = newValueSize;
                    self->valueData = realloc(self->valueData, newValueSize);
                }
                memcpy((char *)self->valueData + v67, &v71, v35);
                v25 = v35 + v67;
            }
            
            const char *pdata = (const char *)&charsPtr[offset];
            offset += len;
            bool v40 = self->valueDataSize < v25;
            unsigned long v41 = self->valueDataSize - v25;
            
            if ( v40 || v41 < len )
            {
                bool v40;
                unsigned long v46;
                do
                {
                    do
                    {
                        self->valueDataSize += 512;
                        self->valueData = realloc(self->valueData, self->valueDataSize);
                        v40 = self->valueDataSize < v25;
                        v46 = self->valueDataSize - v25;
                    }
                    while ( v40 );
                }
                while ( v46 < len );
            }

            memcpy((char *)self->valueData + v25, pdata, len);
            v67 = len + v25;
            result = YES;
        }
    }
    
    if ( result )
    {
        if ( allocated > _header.values.count )
        {
            self->values = (UINibDecoderValue *)realloc(self->values, sizeof(UINibDecoderValue) * _header.values.count);
            self->valueTypes = (char *)realloc(self->valueTypes, _header.values.count);
        }
        if ( v67 < self->valueDataSize && v67 ) {
            self->valueData = realloc(self->valueData, v67);
        }
    }
    return result;
}

//----- (0000000000440C40) ----------------------------------------------------
// UINibDecoder - (bool)validateAndIndexKeys:(const void *) length:(uint64_t)
- (bool)validateAndIndexKeys:(const void *)bytesPtr length:(NSUInteger)bytesLength
{
    unsigned int offset = 0;
    if ( _header.keys.offset <= bytesLength ) {
        offset = _header.keys.offset;
    }
    int keysCount = _header.keys.count;

    NSInteger indexes[0x100];
    NSString *keys[0x100];
    
    NSInteger *pindexes = keysCount <= 0x100 ? indexes : (NSInteger *)malloc(sizeof(NSInteger) * keysCount);
    NSString * __strong * pkeys = keysCount <= 0x100 ? keys : (NSString* __strong *)calloc(sizeof(NSString *), keysCount);
    
    NSLog(@"START KEYS: %d", _header.keys.offset);
    bool result = _header.keys.offset <= bytesLength;
    memset(pkeys, 0, sizeof(NSInteger) * keysCount);
    for (NSInteger index = 0; index < keysCount; index++) {
        result = false;
        
        if ( offset > bytesLength ) {
            break;
        }
        
        int readValue;
        if (!readInt(bytesPtr, bytesLength, offset, &readValue)) {
            break;
        }
        
        int len = decodeIntValue(readValue, bytesPtr, &offset);
        if ( offset > bytesLength ) {
            break;
        }
        if ( bytesLength - offset < len ) {
            break;
        }
        
        NSString *key = [[NSString alloc] initWithBytes:((char *)bytesPtr + offset) length:len encoding:NSUTF8StringEncoding];
        if (!key) {
            break;
        }
        
        NSLog(@"KEY: %@", key);
        
        pkeys[index] = key;
        pindexes[index] = index;
        
        offset += len;
        result = true;
    }
    
    if ( result )
    {
        self->keyIDTable = [[AANibStringIDTable alloc] initWithKeysTransferingOwnership:pkeys count:_header.keys.count];
        result = true;
    }
    
    if ( pindexes != indexes ) {
        free(pindexes);
    }
    if ( pkeys != keys ) {
        free(pkeys);
    }
    return result;
}


+ (instancetype)unarchiveObjectWithData:(NSData *)data
{
    AANibDecoder *decoder = [[AANibDecoder alloc] initForReadingWithData:data];
    [decoder decodeObjectForKey:@"object"];
    [decoder finishDecoding];
    return decoder;
}

+ (instancetype)unarchiveObjectWithFile:(NSString *)path
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    if (data) {
        return [self unarchiveObjectWithData:data];
    }
    return nil;
}

- (NSString *)nextGenericKey
{
    return [NSString stringWithFormat:@"$%ld", ++self->recursiveState.nextGenericKey];
}

- (void)replaceObject:(id)arg1 withObject:(id)arg2
{
    if (arg1 != arg2) {
        int v4 = self->recursiveState.objectID;
        if (self->objectsByObjectID[v4] == arg1) {
            self->objectsByObjectID[v4] = arg2;
            self->recursiveState.replaced = true;
        }
        else {
            [NSException raise:NSGenericException format:@"This coder only supports replacing the object currently being decoded."];
        }
    }
}

- (bool)allowsKeyedCoding
{
    return true;
}

bool _bittest(int *a, NSInteger b)
{
    return *a & (1 << b);
}

- (bool)containsValueForKey:(id)key
{
    NSInteger v15;
    if (![self->keyIDTable lookupKey:key identifier:&v15]) {
        return false;
    }
    
    int objectID = self->recursiveState.objectID;
    int mask = self->keyMasks[objectID];
    bool result = false;
    
    if ( _bittest(&mask, v15) )
    {
        int x1 = self->objects[objectID].x1;
        int x2 = self->objects[objectID].x2;
        int nextIndex = self->recursiveState.nextValueSearchIndex;
        int index;
        if ( nextIndex >= x2 )
        {
        LABEL_7:
            if ( !nextIndex )
            {
            LABEL_11:
                self->recursiveState.nextValueSearchIndex = nextIndex + 1;
                result = false;
                if ( self->recursiveState.nextValueSearchIndex >= x2 )
                {
                    self->recursiveState.nextValueSearchIndex = 0;
                    result = false;
                }
                return result;
            }
            int v13 = 0;
            while ( 1 )
            {
                index = x1 + v13;
                if ( self->values[index].valueID == v15 )
                    break;
                if ( ++v13 >= nextIndex )
                    goto LABEL_11;
            }
            self->recursiveState.nextValueSearchIndex = v13;
        }
        else
        {
            int v11 = self->recursiveState.nextValueSearchIndex;
            while ( 1 )
            {
                index = x1 + v11;
                if ( self->values[index].valueID == v15 )
                    break;
                if ( ++v11 >= x2 )
                    goto LABEL_7;
            }
            self->recursiveState.nextValueSearchIndex = v11;
        }
        result = &self->values[index];
    }
    return result;
}

static int indent = 0;

- (id)decodeObjectForKey:(NSString *)key
{
    NSInteger v17;
    int v12, v13, v14;
    id result = nil;
    NSString *spaces = [@"" stringByPaddingToLength:indent withString:@" " startingAtIndex:0];

    NSLog(@"%@DECODE OBJECT: %@", spaces, key);
    indent+=2;
    if ( [self->keyIDTable lookupKey:key identifier:&v17] )
    {
        int objectID = self->recursiveState.objectID;
        int mask = self->keyMasks[objectID];
        NSLog(@"FOUND OID=%d, ID:%ld, MASK:%d, SUCCESS:%@", objectID, v17, mask, [NSNumber numberWithBool:_bittest(&mask, v17)]);
        if ( _bittest(&mask, v17) )
        {
            int x1 = self->objects[objectID].x1;
            int x2 = self->objects[objectID].x2;
            int nextIndex = self->recursiveState.nextValueSearchIndex;
            if ( nextIndex >= x2 )
            {
            LABEL_7:
                if ( !nextIndex )
                {
                LABEL_11:
                    self->recursiveState.nextValueSearchIndex = nextIndex + 1;
                    result = 0LL;
                    if ( self->recursiveState.nextValueSearchIndex >= x2 )
                    {
                        self->recursiveState.nextValueSearchIndex = 0;
                        result = 0LL;
                    }
                    indent -= 2;
                    return result;
                }
                v14 = 0;
                while ( 1 )
                {
                    v13 = x1 + v14;
                    if ( self->values[v13].valueID == v17 )
                        break;
                    if ( ++v14 >= nextIndex )
                        goto LABEL_11;
                }
                self->recursiveState.nextValueSearchIndex = v14;
            }
            else
            {
                v12 = self->recursiveState.nextValueSearchIndex;
                while ( 1 )
                {
                    v13 = x1 + v12;
                    if ( self->values[v13].valueID == v17 )
                        break;
                    if ( ++v12 >= x2 )
                        goto LABEL_7;
                }
                self->recursiveState.nextValueSearchIndex = v12;
            }
            result = nil;
            if ( &self->values[v13] ) {
                result = UINibDecoderDecodeObjectForValue(self, &self->values[v13], self->valueTypes[v13]);
                NSLog(@"%@RESULT: %@", spaces, result);
            }
        }
    }
    indent-=2;
    return result;
}

id UINibDecoderDecodeObjectForValue(AANibDecoder *decoder, UINibDecoderValue *value, int valueType)
{
    UINibDecoderRecursiveState recursiveState;
    id v77buffer[0x41];
    id v78buffer[0x41];
    
    id result = nil;
    int v31 = 0;
    id __strong * pdata;
    id __strong * pvalues;
    int count;
    id v70 = nil;
    
    if ( valueType == 10 )
    {
        NSInteger objectID = ((char *)decoder->valueData)[value->offset]; //v6
        result = 0LL;
        if ( objectID < decoder->_header.objects.count /*108*/ )
        {
            result = decoder->objectsByObjectID[objectID];
            if ( !result )
            {
                NSInteger classID;
                if ( decoder->longObjectClassIDs )
                    classID = decoder->longObjectClassIDs[objectID];
                else
                    classID = decoder->shortObjectClassIDs[objectID];
                if ( !decoder->classes[classID] )
                {
                    //TODO: decoder->classes[classID] = [decoder->delegate nibDecoder:self cannotDecodeObjectOfClassName:self->missingClasses[classID]];
                    if ( !decoder->classes[classID] ) {
                        [NSException raise:NSInvalidUnarchiveOperationException format:@"Could not instantiate class named %@", decoder->missingClasses[classID]];
                    }
                }
                
                recursiveState = decoder->recursiveState; //v76,v75,v74

                decoder->recursiveState.objectID = objectID;
                decoder->recursiveState.nextGenericKey = 0;
                decoder->recursiveState.nextValueSearchIndex = 0;
                decoder->recursiveState.replaced = NO;
                
                Class classObj = decoder->classes[classID]; //v10
                if ([NSStringFromClass(classObj) isEqualToString:@"UIProxyObject"]) {
                    classObj = [AAProxyObject class];
                }

                if ( !(decoder->objects[objectID].x2) || decoder->values[decoder->objects[objectID].x1].valueID != decoder->inlinedValueKey ) {
                    decoder->objectsByObjectID[objectID] = [classObj alloc];
                    id v20 = [decoder->objectsByObjectID[objectID] initWithCoder:decoder];
                    if (decoder->recursiveState.replaced && decoder->objectsByObjectID[objectID] != v20) {
                        [NSException raise:NSGenericException format:@"This coder requires that replaced objects be returned from initWithCoder:"];
                    }
                    decoder->objectsByObjectID[objectID] = v20;
                    decoder->objectsByObjectID[objectID] = [decoder->objectsByObjectID[objectID] awakeAfterUsingCoder:decoder];
                
                    result = decoder->objectsByObjectID[objectID];
                    decoder->recursiveState = recursiveState;
                    if (result == nil) {
                        NSLog(@"FAILED1");
                    }
                    return result;
                }
                
                if ([classObj isSubclassOfClass:decoder->arrayClass]) {
                    decoder->objectsByObjectID[objectID] = [classObj allocWithZone:NULL];
                    v70 = decoder->objectsByObjectID[objectID];
                    NSInteger objID = decoder->recursiveState.objectID;
                    int v15 = decoder->objects[objID].x1;
                    int v16 = decoder->objects[objID].x2;
                    count = (v16 - 1);
                    if ( count < 0x21 )
                    {
                        pdata = (id __strong*)&v77buffer;
                    }
                    else
                    {
                        pdata = (id __strong*)calloc(sizeof(id), count);
                    }
                    if ( v16 < 2 ) {
                        id v63 = [v70 initWithObjects:pdata count:count];
                        if ( pdata != (id __strong *)&v77buffer ) {
                            free(pdata);
                        }
                        decoder->objectsByObjectID[objectID] = v63;
                        result = decoder->objectsByObjectID[objectID];
                        decoder->recursiveState = recursiveState;
                        return result;
                    }
                    else {
                        int v30 = v15 + 1;
                        v31 = 0;
                        
                        for (int i = 0; i < count; i++, v30++) {
                            pdata[i] = UINibDecoderDecodeObjectForValue(decoder, &decoder->values[v30], decoder->valueTypes[v30]);
                            v31 = v31 | (pdata[i] == 0);
                        }
                    }
                }
                else if ([classObj isSubclassOfClass:decoder->dictionaryClass]) {
                    decoder->objectsByObjectID[objectID] = [classObj allocWithZone:NULL];
                    id v21 = decoder->objectsByObjectID[objectID];
                    NSInteger v22 = decoder->recursiveState.objectID;
                    int v24 = decoder->objects[v22].x2;
                    id v41;
                    if ( v24 & 1 )
                    {
                        int v25 = decoder->objects[v22].x1;
                        int v26 = v24 >> 1;
                        if ( v24 <= 0x41 )
                        {
                            pdata = (id __strong *)&v77buffer;
                            pvalues = (id __strong *)&v78buffer;
                        }
                        else
                        {
                            pdata = (id __strong *)calloc(8, v26);
                            pvalues = (id __strong *)malloc(8 * v26);
                        }
                        int v47 = 0;
                        int v50;
                        if ( v26 ) {
                            int v45 = v25 + 2;
                            int v46 = 0LL;
                            do
                            {
                                pdata[v46] = UINibDecoderDecodeObjectForValue(decoder,
                                                                              &decoder->values[v45 - 1],
                                                                              decoder->valueTypes[v45 - 1]);
                                pvalues[v46] = UINibDecoderDecodeObjectForValue(decoder, &decoder->values[v45], decoder->valueTypes[v45]);
                                
                                v50 = v47 == 0;
                                v47 = 1;
                                if ( v50 ) {
                                    v47 = pdata[v46] == 0LL || pvalues[v46] == 0;
                                }
                                ++v46;
                                v45 += 2;
                            }
                            while ( v46 < v26 );
                        }
                        v50 = v47 == 0;
                        if ( v50 )
                        {
                            v41 = [v21 initWithObjects:pvalues forKeys:pdata count:v26];
                        }
                        else
                        {
                            [v21 init];
                            v41 = NULL;
                        }
                        if ( pdata != (id __strong *)&v77buffer ) {
                            free(pdata);
                        }
                        if ( pvalues != (id __strong *)&v78buffer ) {
                            free(pvalues);
                        }
                    }
                    else
                    {
                        v41 = NULL;
                        [NSException raise:NSGenericException format:@"Invalid NSDictionary in archive. Illegal quantity of Keys and Values"];
                        [v21 init];
                    }
                    decoder->objectsByObjectID[objectID] = v41;
                    result = decoder->objectsByObjectID[objectID];
                    decoder->recursiveState = recursiveState;
                    if (result == nil) {
                        NSLog(@"FAILED2");
                    }
                    return result;
                }
                else if ([classObj isSubclassOfClass:decoder->setClass]) {
                    decoder->objectsByObjectID[objectID] = [classObj allocWithZone:NULL];
                    v70 = decoder->objectsByObjectID[objectID];
                    int v36 = decoder->recursiveState.objectID;
                    int v38 = decoder->objects[v36].x1;
                    int v39 = decoder->objects[v36].x2;
                    count = (v39 - 1);
                    if ( count < 0x21 )
                    {
                        pdata = (id __strong*)&v77buffer;
                    }
                    else
                    {
                        pdata = (id __strong*)calloc(sizeof(id), count);
                    }
                    if ( v39 < 2 ) {
                        id v63 = [v70 initWithObjects:pdata count:count];
                        if ( pdata != (id __strong *)&v77buffer ) {
                            free(pdata);
                        }
                        decoder->objectsByObjectID[objectID] = v63;
                        result = decoder->objectsByObjectID[objectID];
                        decoder->recursiveState = recursiveState;
                        return result;
                    }
                    int v55 = v38 + 1;
                    v31 = 0;
                    for (int i = 0; i < count; i++, v55++) {
                        pdata[i] = UINibDecoderDecodeObjectForValue(decoder, &decoder->values[v55], decoder->valueTypes[v55]);
                        v31 = v31 | (pdata[i] == 0);
                    }
                }
                else {
                    [NSException raise:NSGenericException format:@"Unkown special cased class %@", classObj];
                };
                
                if ( v31 )
                {
                    [v70 init];
                    if ( pdata != (id __strong*)&v77buffer ) {
                        free(pdata);
                    }
                    decoder->objectsByObjectID[objectID] = NULL;
                    result = decoder->objectsByObjectID[objectID];
                    decoder->recursiveState = recursiveState;
                    return result;
                }
                else {
                    id v63 = [v70 initWithObjects:pdata count:count];
                    if ( pdata != (id __strong*)&v77buffer ) {
                        free(pdata);
                    }
                    decoder->objectsByObjectID[objectID] = v63;
                    
                    result = decoder->objectsByObjectID[objectID];
                    decoder->recursiveState = recursiveState;
                    if (result == nil) {
                        NSLog(@"FAILED3");
                    }
                    return result;
                }
            }
        }
    }
    if (result == nil) {
        NSLog(@"FAILED4");
    }
    return result;
}

inline static bool findValue(AANibDecoder *decoder, NSString *key, NSInteger *pValueIndex) {
    NSInteger identifier;
    NSInteger valueIndex;
    if (![decoder->keyIDTable lookupKey:key identifier:&identifier]) {
        return false;
    }
    
    NSInteger objectID = decoder->recursiveState.objectID;
    int mask = decoder->keyMasks[objectID];
    if (!_bittest(&mask, identifier)) {
        return false;
    }
    
    unsigned int v8 = decoder->objects[objectID].x1;
    unsigned int v9 = decoder->objects[objectID].x2;
    unsigned int nextValueIndex = decoder->recursiveState.nextValueSearchIndex;
    
    if (nextValueIndex < v9) {
        for (unsigned int i = nextValueIndex; i < v9; i++) {
            valueIndex = v8 + i;
            if (decoder->values[valueIndex].valueID == identifier) {
                decoder->recursiveState.nextValueSearchIndex = i;
                *pValueIndex = valueIndex;
                return true;
            }
        }
    }
    
    for (unsigned int i = 0; i < nextValueIndex; i++) {
        valueIndex = v8 + i;
        if (decoder->values[valueIndex].valueID == identifier) {
            decoder->recursiveState.nextValueSearchIndex = i;
            *pValueIndex = valueIndex;
            return true;
        }
    }
    
    decoder->recursiveState.nextValueSearchIndex = nextValueIndex + 1;
    if ( decoder->recursiveState.nextValueSearchIndex >= v9 )
        decoder->recursiveState.nextValueSearchIndex = 0;
    return false;
}

- (const uint8_t *)decodeBytesForKey:(NSString *)key returnedLength:(NSUInteger *)lengthp
{
    const uint8_t *result = nil;
    NSUInteger length = 0;
    NSInteger valueIndex;
    if (findValue(self, key, &valueIndex)) {
        char valueType = self->valueTypes[valueIndex];
        UINibDecoderValue *pValue = &self->values[valueIndex];
        if (pValue) {
            if (valueType == AANibTypeData) {
                /*NSUInteger*/unsigned int offset = pValue->offset;
                /*NSUInteger*/int left = self->valueDataSize - offset;
                int v25;
                if (self->valueDataSize < offset) {
                    length = 0;
                }
                else if (readInt(self->valueData, left, offset, &v25)) {
                    length = decodeIntValue(v25, self->valueData, &offset);
                }
                result = (const uint8_t *)self->valueData + offset;
            }
        }
    }
    if (lengthp) {
        *lengthp = length;
    }
    return result;
}

- (bool)decodeBoolForKey:(NSString *)key
{
    bool result = false;
    NSInteger valueIndex;
    if (findValue(self, key, &valueIndex)) {
        char valueType = self->valueTypes[valueIndex];
        UINibDecoderValue *pValue = &self->values[valueIndex];
        if (pValue) {
            switch(valueType) {
                case AANibTypeTrue:
                    return true;
                case AANibTypeFalse:
                    return false;
                case AANibTypeInt8:
                    return *(__uint8_t *)((char *)self->valueData + pValue->offset) != 0;
                case AANibTypeInt16:
                    return *(__uint16_t *)((char *)self->valueData + pValue->offset) != 0;
                case AANibTypeInt32:
                    return *(__uint32_t *)((char *)self->valueData + pValue->offset) != 0;
                case AANibTypeInt64:
                    return *(__uint64_t *)((char *)self->valueData + pValue->offset) != 0;
                default:
                    break;
            }
        }
    }
    return result;
}

- (float)decodeFloatForKey:(NSString *)key
{
    float result = 0;
    NSInteger valueIndex;
    if (findValue(self, key, &valueIndex)) {
        char valueType = self->valueTypes[valueIndex];
        UINibDecoderValue *pValue = &self->values[valueIndex];
        if (pValue && valueType == AANibTypeFloat) {
            result = *(float *)((const char *)self->valueData + pValue->offset);
        }
        else if (pValue && valueType == AANibTypeDouble) {
            result = *(double *)((const char *)self->valueData + pValue->offset);
        }
    }
    return result;
}

- (double)decodeDoubleForKey:(NSString *)key
{
    double result = 0;
    NSInteger valueIndex;
    if (findValue(self, key, &valueIndex)) {
        char valueType = self->valueTypes[valueIndex];
        UINibDecoderValue *pValue = &self->values[valueIndex];
        if (pValue && valueType == AANibTypeDouble) {
            result = *(double *)((const char *)self->valueData + pValue->offset);
        }
    }
    return result;
}

- (int64_t)decodeInt64ForKey:(NSString *)key
{
    int64_t result = 0;
    NSInteger valueIndex;
    if (findValue(self, key, &valueIndex)) {
        char valueType = self->valueTypes[valueIndex];
        UINibDecoderValue *pValue = &self->values[valueIndex];
        if ( pValue )
        {
            switch(valueType) {
                case AANibTypeInt8:
                    return *(int8_t *)((char *)self->valueData + pValue->offset);
                case AANibTypeInt16:
                    return *(int16_t *)((char *)self->valueData + pValue->offset);
                case AANibTypeInt32:
                    return *(int32_t *)((char *)self->valueData + pValue->offset);
                case AANibTypeInt64:
                    return *(int64_t *)((char *)self->valueData + pValue->offset);
                default:
                    if ((valueType & 0xFE) == AANibTypeFalse) {
                        return (valueType == AANibTypeTrue);
                    }
            }
        }
    }
    return result;
}

- (NSInteger)decodeIntegerForKey:(NSString *)key
{
    NSInteger result = 0;
    NSInteger valueIndex;
    if (findValue(self, key, &valueIndex)) {
        char valueType = self->valueTypes[valueIndex];
        UINibDecoderValue *pValue = &self->values[valueIndex];
        if ( pValue )
        {
            switch(valueType) {
                case AANibTypeInt8:
                    return *(int8_t *)((char *)self->valueData + pValue->offset);
                case AANibTypeInt16:
                    return *(int16_t *)((char *)self->valueData + pValue->offset);
                case AANibTypeInt32:
                    return *(int32_t *)((char *)self->valueData + pValue->offset);
                case AANibTypeInt64:
                    return *(int64_t *)((char *)self->valueData + pValue->offset);
                default:
                    if ((valueType & 0xFE) == AANibTypeFalse) {
                        return (valueType == AANibTypeTrue);
                    }
            }
        }
    }
    return result;
}

- (int)decodeIntForKey:(NSString *)key
{
    int result = 0;
    NSInteger valueIndex;
    if (findValue(self, key, &valueIndex)) {
        char valueType = self->valueTypes[valueIndex];
        UINibDecoderValue *pValue = &self->values[valueIndex];
        if ( pValue )
        {
            switch(valueType) {
                case AANibTypeInt8:
                    return *(int8_t *)((char *)self->valueData + pValue->offset);
                case AANibTypeInt16:
                    return *(int16_t *)((char *)self->valueData + pValue->offset);
                case AANibTypeInt32:
                    return *(int32_t *)((char *)self->valueData + pValue->offset);
                case AANibTypeInt64:
                    return (int)*(int64_t *)((char *)self->valueData + pValue->offset);
                default:
                    if ((valueType & 0xFE) == AANibTypeFalse) {
                        return (valueType == AANibTypeTrue);
                    }
            }
        }
    }
    return result;
}

- (int)decodeInt32ForKey:(NSString *)key
{
    int result = 0;
    NSInteger valueIndex;
    if (findValue(self, key, &valueIndex)) {
        char valueType = self->valueTypes[valueIndex];
        UINibDecoderValue *pValue = &self->values[valueIndex];
        if ( pValue )
        {
            switch(valueType) {
                case AANibTypeInt8:
                    return *(int8_t *)((char *)self->valueData + pValue->offset);
                case AANibTypeInt16:
                    return *(int16_t *)((char *)self->valueData + pValue->offset);
                case AANibTypeInt32:
                    return *(int32_t *)((char *)self->valueData + pValue->offset);
                case AANibTypeInt64:
                    return (int)*(int64_t *)((char *)self->valueData + pValue->offset);
                default:
                    if ((valueType & 0xFE) == AANibTypeFalse) {
                        return (valueType == AANibTypeTrue);
                    }
            }
        }
    }
    return result;
}

- (BOOL)decodeArrayOfFloats:(float *)floatValues count:(NSInteger)count forKey:(NSString *)key
{
    NSUInteger length = 0;
    const uint8_t *data = [self decodeBytesForKey:key returnedLength:&length];
    if (!data) {
        return NO;
    }
    if (!length) {
        return NO;
    }
    if (*data == AANibTypeDouble) {
        if ( count * 8 == length - 1 )
        {
            int pos = 1;
            for (int i = 0; i < count; i++) {
                if (length >= pos && length - pos >= 8) {
                    floatValues[i] = (float)*(double *)(data + pos);
                    pos += 8;
                }
            }
            return YES;
        }
        return NO;
    }
    
    if (*data != AANibTypeFloat || (count * 4 != length - 1)) {
        return NO;
    }
    
    int pos = 1;
    for (int i = 0; i < count; i++) {
        if (length >= pos && length - pos >= 4) {
            floatValues[i] = *(float *)(data + pos);
            pos += 4;
        }
    }
    return YES;
}

- (BOOL)decodeArrayOfDoubles:(double *)doubleValues count:(NSInteger)count forKey:(NSString *)key
{
    NSUInteger length = 0;
    const uint8_t *data = [self decodeBytesForKey:key returnedLength:&length];
    if (!data) {
        return NO;
    }
    if (!length) {
        return NO;
    }
    if (*data == AANibTypeDouble) {
        if ( count * 8 == length - 1 )
        {
            int pos = 1;
            for (int i = 0; i < count; i++) {
                if (length >= pos && length - pos >= 8) {
                    doubleValues[i] = *(double *)(data + pos);
                    pos += 8;
                }
            }
            return YES;
        }
        return NO;
    }
    
    if (*data != AANibTypeFloat || (count * 4 != length - 1)) {
        return NO;
    }
    
    int pos = 1;
    for (int i = 0; i < count; i++) {
        if (length >= pos && length - pos >= 4) {
            doubleValues[i] = *(float *)(data + pos);
            pos += 4;
        }
    }
    return YES;
}

- (BOOL)decodeArrayOfCGFloats:(CGFloat *)floatValues count:(NSInteger)count forKey:(NSString *)key
{
    NSUInteger length = 0;
    const uint8_t *data = [self decodeBytesForKey:key returnedLength:&length];
    if (!data) {
        return NO;
    }
    if (!length) {
        return NO;
    }
    if (*data == AANibTypeDouble) {
        if ( count * 8 == length - 1 )
        {
            int pos = 1;
            for (int i = 0; i < count; i++) {
                if (length >= pos && length - pos >= 8) {
                    floatValues[i] = (CGFloat)*(double *)(data + pos);
                    pos += 8;
                }
            }
            return YES;
        }
        return NO;
    }
    
    if (*data != AANibTypeFloat || (count * 4 != length - 1)) {
        return NO;
    }
    
    int pos = 1;
    for (int i = 0; i < count; i++) {
        if (length >= pos && length - pos >= 4) {
            floatValues[i] = (CGFloat)*(float *)(data + pos);
            pos += 4;
        }
    }
    return YES;
}

- (CGPoint)decodeCGPointForKey:(NSString *)key
{
    CGFloat floats[2];
    CGPoint point;
    if ([self decodeArrayOfCGFloats:floats count:2 forKey:key]) {
        point.x = floats[0];
        point.y = floats[1];
    }
    else {
        point = CGPointMake(0, 0);
    }
    return point;
}

- (CGSize)decodeCGSizeForKey:(NSString *)key
{
    CGFloat floats[2];
    CGSize size;
    if ([self decodeArrayOfCGFloats:floats count:2 forKey:key]) {
        size.width = floats[0];
        size.height = floats[1];
    }
    else {
        size = CGSizeMake(0, 0);
    }
    return size;
}

- (CGRect)decodeCGRectForKey:(NSString *)key
{
    CGFloat floats[4];
    CGRect rect;
    if ([self decodeArrayOfCGFloats:floats count:4 forKey:key]) {
        rect = CGRectMake(floats[0], floats[1], floats[2], floats[3]);
    }
    else {
        rect = CGRectMake(0, 0, 0, 0);
    }
    return rect;
}

- (CGAffineTransform)decodeCGAffineTransformForKey:(NSString *)key
{
    CGFloat floats[6];
    CGAffineTransform transform;
    if ([self decodeArrayOfCGFloats:floats count:6 forKey:key]) {
        transform = CGAffineTransformMake(floats[0], floats[1], floats[2], floats[3], floats[4], floats[5]);
    }
    else {
        transform = CGAffineTransformIdentity;
    }
    return transform;
}

- (UIEdgeInsets)decodeUIEdgeInsetsForKey:(NSString *)key
{
    CGFloat floats[4];
    UIEdgeInsets insets;
    if ([self decodeArrayOfCGFloats:floats count:6 forKey:key]) {
        insets = UIEdgeInsetsMake(floats[0], floats[1], floats[2], floats[3]);
    }
    else {
        insets = UIEdgeInsetsZero;
    }
    return insets;
}

- (void)decodeValueOfObjCType:(const char *)type at:(void *)data
{
    NSAssert(strlen(type) == 1, @"The UINibDecoder doesn't decode this type. Please switch your NSCoding implementation to using keyed archiving.");
    
    if ( *type <= 57 )
    {
        if ( *type == 42 )
        {
            NSString *key = [self nextGenericKey];
            NSUInteger length = 0;
            const char *bytes = (const char *)[self decodeBytesForKey:key returnedLength:&length];
            *(char **)data = strdup(bytes);
            return;
        }
        
        NSAssert(NO, @"The UINibDecoder doesn't decode this type. Please switch your NSCoding implementation to using keyed archiving.");
    }
    
    if ( *type <= 99 )
    {
        if ( *type == 58 )
        {
            NSString *key = [self nextGenericKey];
            id object = [self decodeObjectForKey:key];
            if ([object isKindOfClass:[NSString class]]) {
                *(void **)data = NSSelectorFromString(object);
            }
            else {
                *(void **)data = 0;
            }
            return;
        }
        if ( *type != 64 )
        {
            if ( *type == 66 )
            {
                NSString *key = [self nextGenericKey];
                *(BOOL *)data = [self decodeBoolForKey:key];
                return;
            }
            NSAssert(NO, @"The UINibDecoder doesn't decode this type. Please switch your NSCoding implementation to using keyed archiving.");
        }
        
        NSString *key = [self nextGenericKey];
        *(void **)data = (__bridge void *)[self decodeObjectForKey:key];
        return;
    }
    
    if (*type > 112) {
        if (*type == 113) {
            if (*type == 115) {
                NSString *key = [self nextGenericKey];
                *(NSInteger *)data = [self decodeIntegerForKey:key];
                return;
            }
            NSAssert(NO, @"The UINibDecoder doesn't decode this type. Please switch your NSCoding implementation to using keyed archiving.");
        }
        NSString *key = [self nextGenericKey];
        *(NSInteger *)data = [self decodeIntegerForKey:key];
        return;
    }
    if (*type == 100) {
        NSString *key = [self nextGenericKey];
        *(double *)data = [self decodeDoubleForKey:key];
        return;
    }
    if (*type == 102) {
        NSString *key = [self nextGenericKey];
        *(double *)data = [self decodeDoubleForKey:key];
        return;
    }
    if (*type == 105) {
        NSString *key = [self nextGenericKey];
        *(NSInteger *)data = [self decodeIntegerForKey:key];
        return;
    }

    NSAssert(NO, @"The UINibDecoder doesn't decode this type. Please switch your NSCoding implementation to using keyed archiving.");
}

- (id)decodeNXObject
{
    NSAssert(FALSE, @"Unimplemented");
    return nil;
}

- (id)decodeDataObject
{
    NSAssert(FALSE, @"Unimplemented");
    return nil;
}

- (id)decodeObject
{
    struct objc_object *v3 = NULL;
    [self decodeValueOfObjCType:"@" at:&v3];
    //TODO: return v3;
    return nil;
}

- (id)decodePropertyList
{
    NSAssert(FALSE, @"Unimplemented");
    return nil;
}

- (void)decodeValuesOfObjCTypes:(const char *)types, ...
{
    NSAssert(FALSE, @"Unimplemented");
}

- (void)decodeArrayOfObjCType:(const char *)arg1 count:(NSUInteger)arg2 at:(void *)arg3
{
    NSAssert(FALSE, @"Unimplemented");
}

- (void *)decodeBytesWithReturnedLength:(NSUInteger *)lengthp
{
    NSAssert(FALSE, @"Unimplemented");
    return NULL;
}

- (unsigned int)systemVersion
{
    return 2000;
}

- (NSInteger)versionForClassName:(NSString *)className
{
    Class classObject = NSClassFromString(className);
    if(classObject) {
        return [classObject version];
    }
    return 0x7FFFFFFFFFFFFFFFLL;
}

- (void)finishDecoding
{
    int count = 0;
    for (; count < _header.objects.count; count++) {
        //TODO: objectsByObjectID[count] = nil;
    }
    memset(objectsByObjectID, 0, count);
    
    self->recursiveState.nextValueSearchIndex = 0;
    recursiveState.nextGenericKey = 0;
    recursiveState.objectID = 0;
}

@end
