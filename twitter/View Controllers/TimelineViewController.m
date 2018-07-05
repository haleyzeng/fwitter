//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "APIManager.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "ComposeViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TweetDetailViewController.h"

@interface TimelineViewController () <UITableViewDelegate, UITableViewDataSource, ComposeViewControllerDelegate, UIScrollViewDelegate, TweetDetailViewControllerDelegate>

@property (assign, nonatomic) BOOL isMoreDataLoading;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self fetchTimeline];
    
    // initialize refresh controller
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    // attach refresh controller to refresh functionality
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    
    // add 
    [self.tableView insertSubview:refreshControl atIndex:0];
}

- (void)fetchTimeline {
    // Get timeline
    [[APIManager shared] getHomeTimelineOlderThan:nil withCompletion:^(NSArray *tweets, NSError *error) {
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
    // get id of the last tweet in the timeline
    Tweet *lastTweet = self.timelineTweets[self.timelineTweets.count - 1];
    NSLog(@"Before refresh count: %lu", (unsigned long)self.timelineTweets.count);
    NSString *lastTweetID = lastTweet.idString;
    
    [[APIManager shared] getHomeTimelineOlderThan:lastTweetID withCompletion:^(NSArray *tweets, NSError *error) {
        if (error) {}
        else {
            
            self.timelineTweets = [self.timelineTweets arrayByAddingObjectsFromArray:tweets];
             NSLog(@"After refresh count: %lu", (unsigned long)self.timelineTweets.count);
            self.isMoreDataLoading = NO;
            [self.tableView reloadData];
        }
    }];
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self fetchTimeline];
    [refreshControl endRefreshing];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Tweet *tweet = self.timelineTweets[indexPath.row];
    TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    cell.tweet = tweet;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timelineTweets.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isMoreDataLoading) {
        int totalContentHeight = self.tableView.contentSize.height;
        int oneScreenHeight = self.tableView.bounds.size.height;
        int scrollViewOffsetThreshold = totalContentHeight - oneScreenHeight;
        if (scrollView.contentOffset.y > scrollViewOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = YES;
            [self fetchOlderTimeline];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// tweeted from compose view
- (void)didTweet:(Tweet *)tweet {
    [self fetchTimeline];
}

- (void)didTapRetweetInDetailView:(TweetCell *)cell {
    NSLog(@"Retweet in detail view tapped");
    [cell handleRetweet];
}

- (void)didTapFavoriteInDetailView:(TweetCell *)cell {
    [cell handleFavorite];
}

- (IBAction)didTapLogout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    
    [[APIManager shared] logout];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // segue from tapping a tweet to the detail view
    if ([segue.identifier isEqualToString:@"tweetDetail"]) {
        TweetCell *tappedCell = sender;
        TweetDetailViewController *tweetDetailViewController = [segue destinationViewController];
        tweetDetailViewController.sourceCell = tappedCell;
        tweetDetailViewController.tweet = tappedCell.tweet;
        tweetDetailViewController.delegate = self;
    }
    // segue from tapping compose button to compose screen
    else {
        UINavigationController *navigationController = [segue destinationViewController];
    
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
    }
}







@end
