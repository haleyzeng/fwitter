//
//  TweetDetailViewController.m
//  twitter
//
//  Created by Haley Zeng on 7/5/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "APIManager.h"
#import "TimelineViewController.h"

@interface TweetDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@end

@implementation TweetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    // Do any additional setup after loading the view.
    self.displayNameLabel.text = self.tweet.user.name;
    self.screenNameLabel.text = [@"@" stringByAppendingString:self.tweet.user.screenName];
    self.dateLabel.text = self.tweet.createdAtDateAbsolute;
    self.tweetContentLabel.text = self.tweet.contentText;
    
    // set profile picture with fade
    if (self.tweet.user.profileURL != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.tweet.user.profileURL];
        __weak TweetDetailViewController *weakSelf = self;
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
    
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
    
    if (self.tweet.isRetweeted)
        self.retweetButton.selected = YES;
    else
        self.retweetButton.selected = NO;
    if (self.tweet.isFavorited)
        self.favoriteButton.selected = YES;
    else
        self.favoriteButton.selected = NO;
}

- (IBAction)didTapRetweet:(id)sender {
    [self.delegate didTapRetweetInDetailView:self.sourceCell];
    [self setupView];
}

- (IBAction)didTapFavorite:(id)sender {
    [self.delegate didTapFavoriteInDetailView:self.sourceCell];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
