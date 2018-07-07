//
//  APIManager.h
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "BDBOAuth1SessionManager.h"
#import "BDBOAuth1SessionManager+SFAuthenticationSession.h"
#import "Tweet.h"

@interface APIManager : BDBOAuth1SessionManager

+ (instancetype)shared;

- (void)getHomeTimelineTweetsOlderThan:(NSString *)tweetID
                        withCompletion:(void(^)(NSArray *tweets, NSError *error))completion;

- (void)postStatusWithText:(NSString *)text
                 inReplyTo:(Tweet *)replyingToTweet
            withCompletion:(void (^)(Tweet *tweet, NSError *error))completion;

- (void)postFavoriteStatus:(Tweet *)tweet
            withCompletion:(void (^)(Tweet *tweet, NSError *error))completion;

- (void)postRetweetStatus:(Tweet *)tweet
           withCompletion:(void (^)(Tweet *tweet, NSError *error))completion;

@end
