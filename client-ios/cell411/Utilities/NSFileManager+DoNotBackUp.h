//
//  NSFileManager+DoNotBackUp.h
//  Executivo
//
//  Created by Milan Agarwal on 29/04/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (DoNotBackUp)
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end
