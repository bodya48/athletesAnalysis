//
//  NetworkManager.m
//  master-plugin
//
//  Created by Bogdan Laukhin on 4/6/17.
//  Copyright © 2017 Bogdan Laukhin. All rights reserved.
//

#import "NetworkManager.h"
#import "FilesHttpHelper.h"


@implementation NetworkManager

- (void)getForFilesWithToken:(NSString *)accessToken
                   onSuccess:(void (^)(NSArray *))success
                   onFailure:(void (^)(NSError *))failure {
    NSString *apiUrlForFiles = [[NSString alloc] initWithFormat:@"%@%@", @"https://api.sequencing.com", @"/DataSourceList?all=true"];
    [FilesHttpHelper execHttpRequestWithUrl:apiUrlForFiles
                                    andMethod:@"GET"
                                   andHeaders:nil
                                  andUsername:nil
                                  andPassword:nil
                                     andToken:accessToken
                                 andAuthScope:@"Bearer"
                                andParameters:nil
                                   andHandler:^(NSString* responseText, NSURLResponse* response, NSError* error) {
                                       
                                       if (response) {
                                           
                                           if ([[responseText lowercaseString] rangeOfString:@"exception"].location != NSNotFound ||
                                               [[responseText lowercaseString] rangeOfString:@"invalid"].location != NSNotFound ||
                                               [[responseText lowercaseString] rangeOfString:@"error"].location != NSNotFound) {
                                               
                                               NSLog(@"Error: %@", responseText);
                                               if (success) {
                                                   success(nil);
                                               }
                                               
                                           } else {
                                               
                                               NSError *jsonError;
                                               NSData *jsonData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
                                               NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                                       options:0
                                                                                                         error:&jsonError];
                                               if (jsonError != nil) {
                                                   NSLog(@"Error: %@", jsonError);
                                                   if (success) {
                                                       success(nil);
                                                   }
                                               } else {
                                                   if (success) {
                                                       success(parsedObject);
                                                   }
                                               }
                                           }
                                           
                                       } else if (failure) {
                                           failure(error);
                                       }
                                   }];
}





@end
