//
//  NetworkManager.h
//  master-plugin
//
//  Created by Bogdan Laukhin on 4/6/17.
//  Copyright © 2017 Bogdan Laukhin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

- (void)getForFilesWithToken:(NSString *)accessToken
                   onSuccess:(void (^)(NSArray *))success
                   onFailure:(void (^)(NSError *))failure;
@end
