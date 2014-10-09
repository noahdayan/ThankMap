//
//  TMQueryHelper.h
//  ThankMap
//
//  Created by Noah Dayan on 9/14/14.
//  Copyright (c) 2014 Noah Dayan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMQueryHelper : NSObject

/**
 Query the Yelp API with a given term and location and displays the progress in the log
 
 @param term: The term of the search, e.g: dinner
 @param location: The location in which the term should be searched for, e.g: San Francisco, CA
 */
- (void)queryTopBusinessInfoForTerm:(NSString *)term location:(NSString *)location completionHandler:(void (^)(NSDictionary *jsonResponse, NSError *error))completionHandler;

- (void)queryTopBusinessInfoForTerm:(NSString *)term latitude:(NSString *)latitude longitude:(NSString *)longitude completionHandler:(void (^)(NSDictionary *jsonResponse, NSError *error))completionHandler;

@end
