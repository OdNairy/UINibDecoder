//
//  AANibStorage.h
//  TestNib
//
//  Created by AB on 5/8/16.
//  Copyright © 2016 Intellectsoft Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AANibDecoder;
@interface AANibStorage : NSObject
@property (nonatomic, strong) NSString *bundleResourceName;
@property (nonatomic, strong) NSString *bundleDirectoryName;
@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSString *identifierForStringsFile;
@property (nonatomic, strong) NSData *archiveData;
@property (nonatomic, strong) AANibDecoder *nibDecoder;

@property (nonatomic, assign) bool instantiatingForSimulator;
@property (nonatomic, assign) bool captureImplicitLoadingContextOnDecode;
@end
