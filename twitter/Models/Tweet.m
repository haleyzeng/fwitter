//
//  Tweet.m
//  twitter
//
//  Created by Haley Zeng on 7/2/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "Tweet.h"
#import "DateTools.h"

@implementation Tweet

- (void)toggleIsRetweeted {
    NSLog(@"toggling isRetweeted locally...");
    if (self.isRetweeted) self.retweetCount -= 1;
    else self.retweetCount += 1;
    
    self.isRetweeted = !self.isRetweeted;
}

- (void)toggleIsFavorited {
    NSLog(@"toggling isFavorited locally...");
    if (self.isFavorited) self.favoriteCount -= 1;
    else self.favoriteCount += 1;
    
    self.isFavorited = !self.isFavorited;
}

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
        self.retweetCount = [dictionary[@"retweet_count"] intValue];
        self.favoriteCount = [dictionary[@"favorite_count"] intValue];
        self.isRetweeted = [dictionary[@"retweeted"] boolValue];
        self.isFavorited = [dictionary[@"favorited"] boolValue];

        // get createdAt data
        NSString *createdAtDateOriginalString = dictionary[@"created_at"];
        // convert string to formatted Date
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
        NSDate *date = [formatter dateFromString:createdAtDateOriginalString];
        // convert date to string with relative date
        // ex. 5s, 3h
        NSString *relativeDate = [NSDate shortTimeAgoSinceDate:date];
        
      // formatter.dateStyle = NSDateFormatterShortStyle;
       // formatter.timeStyle = NSDateFormatterNoStyle;
      // self.createdAtDate = [formatter stringFromDate:date];
        
        self.createdAtDate = relativeDate;
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
