//
//  FilesFilter.m
//  master-plugin
//
//  Created by Bogdan Laukhin on 4/6/17.
//  Copyright © 2017 Bogdan Laukhin. All rights reserved.
//

#import "FilesFilter.h"


@implementation FilesFilter

+ (NSArray *)filterAllFiles:(NSArray *)allFilesArray {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *fileDIct in allFilesArray) {
        
        if ([fileDIct objectForKey:@"Sex"] != [NSNull null]) {
            GeneticFile *geneticFile = [[GeneticFile alloc] init];
            geneticFile.name    = [fileDIct objectForKey:@"FriendlyDesc1"];
            geneticFile.nameExplained = [fileDIct objectForKey:@"FriendlyDesc2"];
            geneticFile.fileID  = [fileDIct objectForKey:@"Id"];
            geneticFile.sex     = [fileDIct objectForKey:@"Sex"];
            [tempArray addObject:geneticFile];
        }
    }
    return [NSArray arrayWithArray:tempArray];
}

@end
