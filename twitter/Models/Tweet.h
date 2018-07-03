//
//  Tweet.h
//  twitter
//
//  Created by Haley Zeng on 7/2/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *contentText;
@property (nonatomic, strong) NSString *createdAtDate;
@property (nonatomic) int retweetCount;
@property (nonatomic) int favoriteCount;
@property (nonatomic) BOOL isRetweeted;
@property (nonatomic) BOOL isFavorited;

@property (nonatomic, strong) User *retweetedByUser;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

+ (NSMutableArray *)tweetsWithArray:(NSArray *)dictionaries;

@end
