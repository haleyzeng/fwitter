//
//  Tweet.m
//  twitter
//
//  Created by Haley Zeng on 7/2/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        // handle retweets
        NSDictionary *originalTweet = dictionary[@"retweeted_status"];
        if (originalTweet != nil) {
            /* set the "retweeted by who?" property to the user
               found in the main dictionary */
            self.retweetedByUser = [[User alloc] initWithDictionary:dictionary[@"user"]];
            
            /* set parameter "dictionary" to refer to the
               dictionary that is retweeted_status to allow us to
               get the properties of the tweet that was retweeted */
            dictionary = originalTweet;
        }
        
        self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
        self.idString = dictionary[@"id_str"];
        self.contentText = dictionary[@"text"];
        self.retweetCount = (int) dictionary[@"retweet_count"];
        self.favoriteCount = (int) dictionary[@"favorite_count"];
        self.isRetweeted = dictionary[@"retweeted"];
        self.isFavorited = dictionary[@"favorited"];

        // set created at property with formatting
        NSString *createdAtDateOriginalString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
        NSDate *date = [formatter dateFromString:createdAtDateOriginalString];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        self.createdAtDate = [formatter stringFromDate:date];
    }
    
    return self;
}

/* Given: array of dictionaries that represent tweets
   Returns: array of Tweet objects */
+ (NSMutableArray *)tweetsWithArray:(NSArray *)dictionaries {
    NSMutableArray *tweets = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:dictionary];
        [tweets addObject:tweet];
    }
    return tweets;
}

@end
