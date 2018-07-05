//
//  APIManager.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "APIManager.h"
#import "Tweet.h"

static NSString * const baseURLString = @"https://api.twitter.com";
static NSString * const consumerKey = @"gPydzbIWWrI12B1RPiQeGNz4m";
static NSString * const consumerSecret = @"uuaB1tnnrhggOHP1D2UWmoqrWdgjcfTmZZ5rBaO1GK5LWonDCi";

@interface APIManager()

@end

@implementation APIManager

+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    NSString *key = consumerKey;
    NSString *secret = consumerSecret;
    
    // Check for launch arguments override
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"]) {
        key = [[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"];
    }
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-secret"]) {
        secret = [[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-secret"];
    }
    
    self = [super initWithBaseURL:baseURL consumerKey:key consumerSecret:secret];
    if (self) {
        
    }
    return self;
}

- (void)getHomeTimelineOlderThan:(NSString *)tweetID withCompletion:(void(^)(NSArray *tweets, NSError *error))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setObject:@20 forKey:@"count"];
    if (tweetID)
        [parameters setObject:tweetID forKey:@"max_id"];
    
    [self GET:@"1.1/statuses/home_timeline.json"
    parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
      //  NSLog(@"The return of the API Call: %@", tweetDictionaries);
       NSArray *tweets = [Tweet tweetsWithArray:tweetDictionaries];
       completion(tweets, nil);
       
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       completion(nil, error);
   }];
}

- (void)postStatusWithText:(NSString *)text withCompletion:(void (^)(Tweet *tweet, NSError *error))completion {
    
    NSString *urlString = @"1.1/statuses/update.json";
    
    // what to send in POST request
    NSDictionary *parameters = @{@"status": text};
    
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        completion(tweet, nil);
        }
       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
       }];
}

- (void)postFavoriteStatus:(Tweet *)tweet withCompletion:(void (^)(Tweet *tweet, NSError *error))completion {
    
    NSString *urlString;
    if (tweet.isFavorited) // if we are posting a Favorite
        urlString = @"1.1/favorites/create.json";
    else // if we are posting an Unfavorite
        urlString = @"1.1/favorites/destroy.json";
    
    NSDictionary *parameters = @{@"id": tweet.idString};
    
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)postRetweetStatus:(Tweet *)tweet withCompletion:(void (^)(Tweet *, NSError *))completion {
    NSString *urlString;
    
    if (tweet.isRetweeted) // if we are posting a Retweet
        urlString = [NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweet.idString];
    else
        urlString = [NSString stringWithFormat:@"1.1/statuses/unretweet/%@.json", tweet.idString];
    
    NSLog(@"Posting retweet status to network...");
    NSLog(@"%@", urlString);
    
    NSDictionary *parameters = nil;
    
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        NSLog(@"retweet api call succeeded");
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"retweet api call failed");
        completion(nil, error);
    }];
    
}

@end
