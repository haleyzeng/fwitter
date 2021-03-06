//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "ComposeViewController.h"
#import "LoginViewController.h"
#import "TweetDetailViewController.h"
#import "InfiniteScrollActivityView.h"
#import "APIManager.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "AppDelegate.h"

@interface TimelineViewController () <UITableViewDelegate, UITableViewDataSource, ComposeViewControllerDelegate, UIScrollViewDelegate, TweetDetailViewControllerDelegate>

@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (strong, nonatomic) InfiniteScrollActivityView *activityIndicator;

@end

@implementation TimelineViewController
BOOL isMoreDataLoading = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self fetchTimeline];
    
    // initialize refresh controller
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    // attach refresh controller to refresh functionality
    [refreshControl addTarget:self
                       action:@selector(beginRefresh:)
             forControlEvents:UIControlEventValueChanged];
    
    // add refresh controller to view
    [self.tableView insertSubview:refreshControl atIndex:0];
    
    // initialize infinite scroll activity indicator
    CGRect frame = CGRectMake(0,
                              self.tableView.contentSize.height,
                              self.tableView.bounds.size.width,
                              [InfiniteScrollActivityView defaultHeight]);
    self.activityIndicator = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    
    // hide and add activity indicator to view
    self.activityIndicator.hidden = YES;
    [self.tableView addSubview:self.activityIndicator];
    
    // add edge space to bottom of tableView
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom = [InfiniteScrollActivityView defaultHeight];
    self.tableView.contentInset = insets;
}

- (void)fetchTimeline {
    // Get timeline
    [[APIManager shared] getHomeTimelineTweetsOlderThan:nil
                                         withCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"Successfully loaded home timeline");
            self.timelineTweets = tweets;
        } else {
            NSLog(@"Error getting home timeline: %@", error.localizedDescription);
        }
        [self.tableView reloadData];
    }];
}

- (void)fetchOlderTimeline {
    // get id of the oldest tweet in the timeline
    Tweet *lastTweet = self.timelineTweets[self.timelineTweets.count - 1];
    NSString *lastTweetID = lastTweet.idString;
    
    [[APIManager shared] getHomeTimelineTweetsOlderThan:lastTweetID
                                         withCompletion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog(@"Error getting older home timeline: %@", error.localizedDescription);
        }
        else {
            self.timelineTweets = [self.timelineTweets arrayByAddingObjectsFromArray:tweets];
            [self.activityIndicator stopAnimating];
            self.isMoreDataLoading = NO;
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)didTapLogout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    
    [[APIManager shared] logout];
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self fetchTimeline];
    [refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Infinite Scroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isMoreDataLoading) {
        int totalContentHeight = self.tableView.contentSize.height;
        int oneScreenHeight = self.tableView.bounds.size.height;
        int scrollViewOffsetThreshold = totalContentHeight - oneScreenHeight;
        if (scrollView.contentOffset.y > scrollViewOffsetThreshold && self.tableView.isDragging) {
            
            // update position of loading wheel and animate
            CGRect frame = CGRectMake(0,
                                      self.tableView.contentSize.height,
                                      self.tableView.bounds.size.width,
                                      [InfiniteScrollActivityView defaultHeight]);
            self.activityIndicator.frame = frame;
            [self.activityIndicator startAnimating];
            
            self.isMoreDataLoading = YES;
            [self fetchOlderTimeline];
        }
    }
}

#pragma mark - UITableViewDelegate

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Tweet *tweet = self.timelineTweets[indexPath.row];
    TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    cell.tweet = tweet;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.timelineTweets.count;
}

#pragma mark - ComposeViewControllerDelegate

// tweeted from compose view
- (void)didTweet:(Tweet *)tweet {
    [self fetchTimeline];
}

#pragma mark - TweetDetailViewControllerDelegate
- (void)didSendReplyInDetailView {
    [self fetchTimeline];
}

- (void)didTapRetweetInDetailView:(TweetCell *)cell {
    NSLog(@"Retweet in detail view tapped");
    [cell handleRetweet];
}

- (void)didTapFavoriteInDetailView:(TweetCell *)cell {
    [cell handleFavorite];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    NSLog(@"Segueing...");
    
    // segue from tapping a tweet to the detail view
    if ([segue.identifier isEqualToString:@"tweetDetail"]) {
        TweetCell *tappedCell = sender;
        TweetDetailViewController *tweetDetailViewController = [segue destinationViewController];
        tweetDetailViewController.sourceCell = tappedCell;
        tweetDetailViewController.tweet = tappedCell.tweet;
        tweetDetailViewController.delegate = self;
    }
    else {
        UINavigationController *navigationController = [segue destinationViewController];
    
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
        
        if ([segue.identifier isEqualToString:@"reply"]) {
            UIButton *button = sender;
            TweetCell *tappedCell = (TweetCell *) [[button superview] superview];
            
            composeController.replyingToTweet = tappedCell.tweet;
        }
            
    }
}







@end
