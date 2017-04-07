//
//  FilesFilter.h
//  master-plugin
//
//  Created by Bogdan Laukhin on 4/6/17.
//  Copyright © 2017 Bogdan Laukhin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeneticFile.h"


@interface FilesFilter : NSObject

+ (NSArray *)filterAllFiles:(NSArray *)allFilesArray;

@end
