//
//  TweetDetailViewController.h
//  twitter
//
//  Created by Haley Zeng on 7/5/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "TweetCell.h"

@protocol TweetDetailViewControllerDelegate
- (void) didSendReplyInDetailView;
- (void) didTapRetweetInDetailView:(TweetCell *)cell;
- (void) didTapFavoriteInDetailView:(TweetCell *)cell;
@end

@interface TweetDetailViewController : UIViewController
@property (strong, nonatomic) TweetCell *sourceCell;
@property (strong, nonatomic) Tweet *tweet;
@property (weak, nonatomic) id<TweetDetailViewControllerDelegate> delegate;
@end
