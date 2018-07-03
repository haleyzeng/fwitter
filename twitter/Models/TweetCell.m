//
//  TweetCell.m
//  twitter
//
//  Created by Haley Zeng on 7/3/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"

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
    [self.profilePictureView setImageWithURL:self.tweet.user.profileURL];
    
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
    
}

@end
