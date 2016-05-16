//
//  AANib.m
//  TestNib
//
//  Created by AB on 5/8/16.
//  Copyright © 2016 Intellectsoft Group. All rights reserved.
//

#import "AANib.h"
#import "AANibStorage.h"
#import "AAProxyObject.h"
#import "AANibDecoder.h"

static NSObject *IBFirstResponderStandin = NULL;
static unsigned int _UIApplicationLinkedOnVersion = 0x80000;
static NSMutableArray *UICurrentNibLoadingBundles_stack = nil;
static NSMutableArray *UICurrentNibPaths_stack = nil;

@interface NSBundle (AANSBundleLocalizableStringAdditions)
@end

@implementation NSBundle (AANSBundleLocalizableStringAdditions)

+ (void)pushNibLoadingBundle:(NSBundle *)bundle
{
    if ( !UICurrentNibLoadingBundles_stack ) {
        UICurrentNibLoadingBundles_stack = [[NSMutableArray alloc] initWithCapacity:1];
    }
    [UICurrentNibLoadingBundles_stack addObject:bundle];
}

+ (void)popNibLoadingBundle
{
    if ( !UICurrentNibLoadingBundles_stack )
    {
        UICurrentNibLoadingBundles_stack = [[NSMutableArray alloc] initWithCapacity:1];
    }
    [UICurrentNibLoadingBundles_stack removeLastObject];
}

+ (void)pushNibPath:(NSString *)path
{
    if ( !UICurrentNibPaths_stack ) {
        UICurrentNibPaths_stack = [[NSMutableArray alloc] initWithCapacity:1];
    }
    [UICurrentNibPaths_stack addObject:(path ?: [NSNull null])];
}

+ (void)popNibPath
{
    if ( !UICurrentNibPaths_stack )
    {
        UICurrentNibPaths_stack = [[NSMutableArray alloc] initWithCapacity:1];
    }
    [UICurrentNibPaths_stack removeLastObject];
}

@end

@interface AANib ()
@property (nonatomic, strong) AANibStorage *storage;
@property (nonatomic, strong) NSString *bundleResourceName;
@end

static char __isObjectTaggingEnabled = 0;
static dispatch_once_t _UIApplicationLinkedOnVersionOnce;
static NSMutableDictionary *UINIBResrouceUniqueingTable_resourceUniquing;

char _UIAppearanceIsObjectTaggingEnabled()
{
    return __isObjectTaggingEnabled ^ 1;
}
void _UIAppearanceDisableObjectTagging()
{
    __isObjectTaggingEnabled = 1;
}
void _UIAppearanceEnableObjectTagging()
{
    __isObjectTaggingEnabled = 0;
}

bool __UIApplicationLinkedOnOrAfter(unsigned int version)
{
    if ( _UIApplicationLinkedOnVersionOnce != -1 ) {
        dispatch_once(&_UIApplicationLinkedOnVersionOnce, ^{
            //TODO:
        });
    }
    return _UIApplicationLinkedOnVersion >= version;
}

CFMutableDictionaryRef AACoderToBundleMap()
{
    static CFMutableDictionaryRef coderToBundleMap = nil;
    if (!coderToBundleMap) {
        coderToBundleMap = CFDictionaryCreateMutable(0LL, 0LL, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    return coderToBundleMap;
}

id AAResrouceBundleForNIBBeingDecodedWithCoder(NSCoder *coder)
{
    CFDictionaryRef map = AACoderToBundleMap();
    return CFDictionaryGetValue(map, (__bridge const void *)(coder));
}

CFMutableDictionaryRef AACoderToNibIdentifierForStringsFileMap()
{
    static CFMutableDictionaryRef dictionary = NULL;
    if (!dictionary) {
        dictionary = CFDictionaryCreateMutable(0LL, 0LL, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    return dictionary;
}

id UIResourceIdentifierForStringsFileForNIBBeingDecodedWithCoder(NSCoder *coder)
{
    CFDictionaryRef dictionary = AACoderToNibIdentifierForStringsFileMap();
    id object = CFDictionaryGetValue(dictionary, (__bridge const void *)(coder));
    if (![object isEqual:[NSNull null]]) {
        return object;
    }
    return nil;
}

bool AADataLooksLikeNibArchive(NSData *data)
{
    NSUInteger length = data.length;
    bool result = length > 3;
    if ( length >= 4 )
    {
        char chars[10];
        [data getBytes:&chars length:10];
        result = memcmp(&chars, "NIBArchive", 0xA) == 0;
    }
    return result;
}

void AAResourceBeginDeocdingNIBWithCoderFromBundleAndIdentifierForStringsFile(NSString *identifier, NSCoder *coder, NSBundle *bundle)
{
    CFMutableDictionaryRef dictionary = AACoderToBundleMap();
    CFDictionarySetValue(dictionary, (__bridge const void *)(coder), (__bridge const void *)(bundle));
    CFMutableDictionaryRef map = AACoderToNibIdentifierForStringsFileMap();
    if ( !identifier ) {
        identifier = (NSString *)[NSNull null];
    }
    CFDictionarySetValue(map, (__bridge const void *)(coder), (__bridge const void *)(identifier));
}

NSUInteger AAResourceFinishDeocdingNIBWithCoder(NSCoder *coder)
{
    CFMutableDictionaryRef dictionary = AACoderToBundleMap();
    CFDictionaryRemoveValue(dictionary, (__bridge const void *)(coder));
    dictionary = AACoderToNibIdentifierForStringsFileMap();
    CFDictionaryRemoveValue(dictionary, (__bridge const void *)(coder));
    dictionary = AACoderToBundleMap();
    NSUInteger count = CFDictionaryGetCount(dictionary);
    if ( !count )
    {
        if ( !UINIBResrouceUniqueingTable_resourceUniquing )
        {
            UINIBResrouceUniqueingTable_resourceUniquing = [[NSMutableDictionary alloc] init];
        }
        [UINIBResrouceUniqueingTable_resourceUniquing removeAllObjects];
    }
    return count;
}

@implementation AANib
- (NSData* )nibDataForPath:(NSString *)path {
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    if (!data) {
        NSString *pathO80 = [path stringByAppendingPathComponent:@"objects-8.0+.nib"];
        data = [[NSData alloc] initWithContentsOfFile:pathO80];
        if (!data) {
            NSString *pathONib = [path stringByAppendingPathComponent:@"objects.nib"];
            data = [[NSData alloc] initWithContentsOfFile:pathONib];
            if (!data) {
                NSString *pathRuntime = [path stringByAppendingPathComponent:@"runtime.nib"];
                data = [[NSData alloc] initWithContentsOfFile:pathRuntime];
            }
        }
    }
    return data;
}

- (instancetype) initWithBundle:(NSBundle *)bundle {
    self = [super init];
    if (self) {
        self.storage = [[AANibStorage alloc] init];
        [self.storage setBundle:bundle];
    }
    return self;
}

- (instancetype) initWithData:(NSData *)data bundle:(NSBundle *)bundle {
    if (!data) {
        //TODO: invalide parameter exception
    }
    self = [self initWithBundle:bundle];
    if (self) {
        [self.storage setArchiveData:data];
    }
    return self;
}

- (instancetype) initWithNibName:(NSString *)name directory:(NSString *)directory bundle:(NSBundle *)bundle {
    if (!name || !name.length) {
        //TODO: exception
    }
    self = [self initWithBundle:bundle];
    if (self) {
        [self.storage setBundleResourceName:name];
        [self.storage setBundleDirectoryName:directory];
        [self registerForMemoryWarningIfNeeded];
    }
    return self;
}

- (instancetype) initWithContentsOfFile:(NSString *)filePath {
    NSData *data = [self nibDataForPath:filePath];
    return [self initWithData:data bundle:nil];
}

+ (instancetype) nibWithNibName:(NSString *)name bundle:(NSBundle *)bundle {
    return [[AANib alloc] initWithNibName:name directory:nil bundle:bundle];
}

+ (instancetype) nibWithData:(NSData *)data bundle:(NSBundle *)bundle {
    return [[AANib alloc] initWithData:data bundle:bundle];
}

- (instancetype) initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        NSBundle *bundle = nil;
        NSString *bundleID = [coder decodeObjectForKey:@"bundleID"];
        if (bundleID) {
            bundle = [NSBundle bundleWithIdentifier:bundleID];
            if (!bundle) {
                NSLog(@"An instance of UINib could not be decoded because the referenced bundle with identifier \"%@\" could not be found.", bundleID);
                return nil;
            }
        }
        else {
            if ([coder decodeBoolForKey:@"captureEnclosingNIBBundleOnDecode"]) {
                bundle = AAResrouceBundleForNIBBeingDecodedWithCoder(coder);
                UIResourceIdentifierForStringsFileForNIBBeingDecodedWithCoder(coder);
                if (!bundle) {
                    NSLog(@"An instance of UINib could not be decoded because it expected a containing NIB bundle during decoding.");
                    return nil;
                }
            }
        }
        
        self.storage = [AANibStorage new];
        [self.storage setBundle:bundle];
        
        NSString *resourceName = [coder decodeObjectForKey:@"bundleResourceName"];
        [self setBundleResourceName:resourceName];
        [self.storage setIdentifierForStringsFile:resourceName];
        
        if (self.storage.bundleResourceName) {
            self.storage.bundleDirectoryName = [coder decodeObjectForKey:@"bundleDirectoryName"];
        }
        else {
            self.storage.archiveData = [coder decodeObjectForKey:@"archiveData"];
        }
        [self registerForMemoryWarningIfNeeded];
    }
    return self;
}

- (void)encodeWithEncoder:(NSCoder *)coder {
    if (self.storage.bundle) {
        [coder encodeObject:self.storage.bundle.bundleIdentifier forKey:@"bundleID"];
    }
    if (self.storage.identifierForStringsFile) {
        [coder encodeObject:self.storage.identifierForStringsFile forKey:@"identifierForStringsFile"];
    }
    if (self.captureImplicitLoadingContextOnDecode) {
        [coder encodeBool:self.captureImplicitLoadingContextOnDecode forKey:@"captureEnclosingNIBBundleOnDecode"];
    }
    if (self.bundleResourceName) {
        [coder encodeObject:self.bundleResourceName forKey:@"bundleResourceName"];
        if (!self.storage.bundleDirectoryName) {
            return;
        }
        [coder encodeObject:self.storage.bundleDirectoryName forKey:@"bundleDirectoryName"];
    }
    else if (self.storage.archiveData) {
        [coder encodeObject:self.storage.archiveData forKey:@"archiveData"];
    }
}

- (void)dealloc {
    if (self.storage.bundleResourceName) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:[UIApplication sharedApplication]];
    }
    self.storage = nil;
}

- (void)registerForMemoryWarningIfNeeded {
    if (self.storage.bundleResourceName) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:[UIApplication sharedApplication]];
    }
}

- (bool)instantiatingForSimulator {
    return [self.storage instantiatingForSimulator];
}

- (void)setInstantiatingForSimulator:(bool)simulator {
    [self.storage setInstantiatingForSimulator:simulator];
}

- (bool)captureImplicitLoadingContextOnDecode {
    return self.storage.captureImplicitLoadingContextOnDecode;
}

- (void)setCaptureImplicitLoadingContextOnDecode:(bool)captureImplicitLoadingContextOnDecode {
    [self.storage setCaptureImplicitLoadingContextOnDecode:captureImplicitLoadingContextOnDecode];
}

- (NSBundle *)effectiveBundle {
    NSBundle *bundle = self.storage.bundle;
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
    return bundle;
}

- (void)setIdentifierForStringsFile:(NSString *)identifierForStringsFile {
    [self.storage setIdentifierForStringsFile:identifierForStringsFile];
}

- (NSString *)identifierForStringsFile {
    return self.storage.identifierForStringsFile;
}

- (NSString *)bundleResourcePath {
    if (self.storage.bundleResourceName && self.storage.bundleDirectoryName) {
        NSBundle *bundle = [self effectiveBundle];
        return [bundle pathForResource:self.storage.bundleResourceName ofType:@"nib" inDirectory:self.storage.bundleDirectoryName];
    }
    else if (self.storage.bundleResourceName) {
        NSBundle *bundle = [self effectiveBundle];
        return [bundle pathForResource:self.storage.bundleResourceName ofType:@"nib"];
    }
    return nil;
}

- (NSData*)lazyArchiveData {
    if (!self.storage.archiveData) {
        if (!self.storage.bundleResourceName) {
            //TODO: exception
        }
        if (self.bundleResourcePath) {
            self.storage.archiveData = [self nibDataForPath:self.bundleResourcePath];
        }
    }
    return self.storage.archiveData;
}

- (NSKeyedUnarchiver *)unarchiverForInstantiatingReturningError:(NSError **)error {
    id decoder = self.storage.nibDecoder;
    NSError *returningError = nil;
    if (!decoder) {
        NSData *data = [self lazyArchiveData];
        if (data) {
            if (AADataLooksLikeNibArchive(data)) {
                decoder = [[AANibDecoder alloc] initForReadingWithData:data error:&returningError];
                self.storage.nibDecoder = decoder;
                self.storage.archiveData = nil;
            }
            else {
                decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            }
        }
        else {
            NSBundle *bundle = [self effectiveBundle];
            NSString *bundleResourceName = self.storage.bundleResourceName;
            NSString *bundleDirectoryName = self.storage.bundleDirectoryName;
            NSString *text;
            if (bundleDirectoryName && bundleResourceName) {
                text = [NSString stringWithFormat:@"Could not load NIB in bundle: '%@' with name '%@' and directory '%@'", bundle, bundleResourceName, bundleDirectoryName];
            }
            else {
                text = [NSString stringWithFormat:@"Could not load NIB in bundle: '%@' with name '%@'", bundle, bundleResourceName];
            }
            NSDictionary *dictionary = @{NSLocalizedDescriptionKey:text};
            returningError = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:dictionary];
        }
    }
    if (error) {
        *error = returningError;
    }
    return decoder;
}

- (NSArray *)instantiateWithOwner:(nullable id)ownerOrNil options:(nullable NSDictionary *)optionsOrNil {
    
    NSString *path = self.storage.identifierForStringsFile;
    if (!path) {
        path = self.bundleResourcePath;
    }
    
    NSBundle *bundle = [self effectiveBundle];
    [NSBundle pushNibLoadingBundle:bundle];
    [NSBundle pushNibPath:path];
    
    BOOL taggingEnabled = _UIAppearanceIsObjectTaggingEnabled();
    _UIAppearanceDisableObjectTagging();
    
    NSMutableArray *nibArray = nil;
    
    @autoreleasepool {
        NSError *error = nil;
        NSKeyedUnarchiver *unarchiver = [self unarchiverForInstantiatingReturningError:&error];
        if (!unarchiver) {
            //TODO: exception NSInternalInconsistencyException
            //goto label71
        }
        
        NSString *identifierForStringsFile = path;
        NSDictionary *externalObjects = optionsOrNil[UINibExternalObjects];
        if (!externalObjects) {
            externalObjects = optionsOrNil[@"UINibProxiedObjects"];
        }
        
        NSMutableSet *objectsSet = [[NSMutableSet alloc] initWithCapacity:externalObjects.count + 2];
        if ( !IBFirstResponderStandin ) {
            IBFirstResponderStandin = [NSObject new];
        }
        
        if (!ownerOrNil && (!(_UIApplicationLinkedOnVersion && _UIApplicationLinkedOnVersion < 0x30001) || __UIApplicationLinkedOnOrAfter(0x30001))) {
/*            if (_UIApplicationLinkedOnVersion) {
                if (_UIApplicationLinkedOnVersion < 0x30001)
                    goto label16;
            }
            else if (!__UIApplicationLinkedOnOrAfter(0x30001u)) {
                goto label16;
            }*/
            
            ownerOrNil = [NSObject new];
        }
        if (ownerOrNil) {
            [objectsSet addObject:ownerOrNil];
            [AAProxyObject addMappingFromIdentifier:@"IBFilesOwner" toObject:ownerOrNil forCoder:unarchiver];
        }
        
//    label16:
        [AAProxyObject addMappingFromIdentifier:@"IBFirstResponder" toObject:IBFirstResponderStandin forCoder:unarchiver];

        int loc_20100 = 0;//TODO
        if ( (!_UIApplicationLinkedOnVersion || !(_UIApplicationLinkedOnVersion < &loc_20100)) &&
            (_UIApplicationLinkedOnVersion || __UIApplicationLinkedOnOrAfter(&loc_20100)) ) {
            [objectsSet addObject: IBFirstResponderStandin];
        }
/*        if (_UIApplicationLinkedOnVersion) {
            if ( _UIApplicationLinkedOnVersion < &loc_20100 )
                goto LABEL_21;
        }
        else if ( !__UIApplicationLinkedOnOrAfter(&loc_20100) )
        {
            goto LABEL_21;
        }*/
        [objectsSet addObject: IBFirstResponderStandin];
    label21:

        if (externalObjects.count) {
            NSArray *values = [externalObjects allValues];
            if ( _UIApplicationLinkedOnVersion )
            {
                if ( _UIApplicationLinkedOnVersion >= 0x50000 ) {
                    [objectsSet addObjectsFromArray:values];
                }
                else {
                    [objectsSet addObject:values];
                }
            }
            else {
                if ( !__UIApplicationLinkedOnOrAfter(0x50000u) ) {
                    [objectsSet addObject:values];
                }
                else {
                    [objectsSet addObjectsFromArray:values];
                }
            }
            [AAProxyObject addMappings: externalObjects forCoder:unarchiver];
        }

        NSBundle *effectiveBundle = [self effectiveBundle];
        AAResourceBeginDeocdingNIBWithCoderFromBundleAndIdentifierForStringsFile(                                                                                 identifierForStringsFile, unarchiver, effectiveBundle);
        
        NSArray *connections = [unarchiver decodeObjectForKey:@"UINibConnectionsKey"];
        NSArray *topLevelObjects = [unarchiver decodeObjectForKey:@"UINibTopLevelObjectsKey"];
        NSArray *visibleWindows = [unarchiver decodeObjectForKey:@"UINibVisibleWindowsKey"];
        
        NSArray *nibObjects = [unarchiver decodeObjectForKey:@"UINibObjectsKey"];
        NSArray *v25 = [unarchiver decodeObjectForKey:@"UINibAccessibilityConfigurationsKey"];
        NSArray *keyValuePairs = [unarchiver decodeObjectForKey:@"UINibKeyValuePairsKey"];
        NSArray *traitStorageListsKey = [unarchiver decodeObjectForKey:@"UINibTraitStorageListsKey"];
        
        //TODO:
        /*for(id key in traitStorageListsKey) {
            id object = [key topLevelObject];
            [object _setTraitStorageList:key];
        }*/
        
        //TODO: [v51 makeObjectsPerformSelector:@selector(applyConfiguration)];
        if ( self.storage.instantiatingForSimulator ) {
            [keyValuePairs makeObjectsPerformSelector:@selector(applyForSimulator)];
            [connections makeObjectsPerformSelector:@selector(connectForSimulator)];
        }
        else {
            [keyValuePairs makeObjectsPerformSelector:@selector(apply)];
            [connections makeObjectsPerformSelector:@selector(connect)];
        }
        
        nibArray = [NSMutableArray new];
        for(id object in topLevelObjects) {
            if (![objectsSet containsObject:object]) {
                [nibArray addObject:object];
            }
        }

        if ( taggingEnabled ) {
            if ( _UIApplicationLinkedOnVersion && (_UIApplicationLinkedOnVersion >= 0x80000) ) {
                _UIAppearanceEnableObjectTagging();
            }
            else if ( !_UIApplicationLinkedOnVersion && __UIApplicationLinkedOnOrAfter(0x80000u) ) {
                _UIAppearanceEnableObjectTagging();
            }
            
/*            if ( _UIApplicationLinkedOnVersion )
            {
                if ( _UIApplicationLinkedOnVersion >= 0x80000 )
                    goto LABEL_53;
            }
            else if ( __UIApplicationLinkedOnOrAfter(0x80000u) )
            {
            LABEL_53:
                _UIAppearanceEnableObjectTagging();
                goto LABEL_54;
            }*/
        }
//LABEL_54:
        for(id object in nibObjects) {
            if (![objectsSet containsObject:object]) {
                [object awakeFromNib];
            }
        }
        
        _UIAppearanceDisableObjectTagging();
        
        for (id windows in visibleWindows) {
            [windows makeKeyAndVisible];
        }

        objectsSet = nil;
        AAResourceFinishDeocdingNIBWithCoder(unarchiver);
        [AAProxyObject removeMappingsForCoder:unarchiver];
        [unarchiver finishDecoding];
    }
//label71
    
    if ( taggingEnabled ) {
        _UIAppearanceEnableObjectTagging();
    }
    
    [NSBundle popNibPath];
    [NSBundle popNibLoadingBundle];
    return nibArray;
}

- (void)didReceiveMemoryWarning:(id)sender {
    self.storage.nibDecoder = nil;
    self.storage.archiveData = nil;
}

@end
