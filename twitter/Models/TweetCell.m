//
//  TweetCell.m
//  twitter
//
//  Created by Haley Zeng on 7/3/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "APIManager.h"

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    
    self.displayNameLabel.text = self.tweet.user.name;
    self.screenNameLabel.text = [@"@" stringByAppendingString:self.tweet.user.screenName];
    self.dateLabel.text = self.tweet.createdAtDate;
    self.tweetContentLabel.text = self.tweet.contentText;
 //   [self.profilePictureView setImageWithURL:self.tweet.user.profileURL];
    
    // set profile picture with fade
    if (self.tweet.user.profileURL != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.tweet.user.profileURL];
        __weak TweetCell *weakSelf = self;
        [self.profilePictureView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
            // imageResponse will be nil if the image is cached
            if (imageResponse) {
                weakSelf.profilePictureView.alpha = 0.0;
                weakSelf.profilePictureView.image = image;
                
                //Animate UIImageView back to alpha 1 over 0.3sec
                [UIView animateWithDuration:0.3 animations:^{
                    weakSelf.profilePictureView.alpha = 1.0;
                }];
            }
            else {
                weakSelf.profilePictureView.image = image;
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {}];
    }
    
    // set retweet and favorite counts;
    [self.retweetButton setTitle:[NSString stringWithFormat:@"%d", self.tweet.retweetCount] forState:UIControlStateNormal];
    [self.favoriteButton setTitle:[NSString stringWithFormat:@"%d", self.tweet.favoriteCount] forState:UIControlStateNormal];
}
- (IBAction)didTapReply:(id)sender {
}

- (IBAction)didTapRetweet:(id)sender {
    NSLog(@"Retweet button tapped");
    [self.tweet toggleIsRetweeted];
    
    // flip the "selected" boolean property
    self.retweetButton.selected = !self.retweetButton.selected;
    
    // reload the cell to update the contents of the tweet
    [self refreshData];
    
    [[APIManager shared] postRetweetStatus:self.tweet withCompletion:^(Tweet *tweet, NSError *error) {
        if (error) {
            NSLog(@"Error changing retweet status: %@", error.localizedDescription);
        }
        else {
            NSLog(@"Successfully changed retweet status");
        }
    }];
    
    
}

- (IBAction)didTapFavorite:(id)sender {
    NSLog(@"Favorite button tapped");
    [self.tweet toggleIsFavorited];
    
    // flip the "selected" boolean property
    self.favoriteButton.selected = !self.favoriteButton.selected;
    
    // reload the cell to update the contents of the tweet
    [self refreshData];
    
    [[APIManager shared] postFavoriteStatus:self.tweet withCompletion:^(Tweet *tweet, NSError *error) {
        if (error) {
            NSLog(@"Error changing favorite status: %@", error.localizedDescription);
        }
        else {
            NSLog(@"Successfully changed favorite status");
        }
    }];
     
     
}

- (void)refreshData {
    [self setTweet:self.tweet];
}



@end
