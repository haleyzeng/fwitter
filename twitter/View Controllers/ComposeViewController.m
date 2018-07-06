//
//  ComposeViewController.m
//  twitter
//
//  Created by Haley Zeng on 7/3/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"

@interface ComposeViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *composeTextView;
@property (weak, nonatomic) IBOutlet UILabel *characterCountLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tweetButton;

@end

@implementation ComposeViewController

NSInteger characterLimit = 140;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.composeTextView.delegate = self;
    
    // Do any additional setup after loading the view.
}

- (void)textViewDidChange:(UITextView *)textView {
 
    NSInteger charactersUsed = (NSInteger) [textView.text length];
    NSInteger charactersLeft = characterLimit - charactersUsed;
        NSLog(@"%ld", charactersLeft);
    
    self.characterCountLabel.text = [NSString stringWithFormat:@"%ld", charactersLeft];
    NSInteger characterWarningThreshold = 20;
    

    if (charactersLeft > characterWarningThreshold) {
        self.characterCountLabel.alpha = 0;
        self.tweetButton.enabled = YES;
    }
    else if (charactersLeft >= 0) {
        self.characterCountLabel.alpha = 1;
        self.characterCountLabel.textColor = [UIColor blackColor];
        self.tweetButton.enabled = YES;
    }
    else {
        self.characterCountLabel.alpha = 1;
        self.characterCountLabel.textColor = [UIColor redColor];
        self.tweetButton.enabled = NO;
    }
        
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closeModal:(id)sender {
    [self closeComposeView];
}

- (void) closeComposeView {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)postTweet:(id)sender {
    [[APIManager shared] postStatusWithText:self.composeTextView.text withCompletion:^(Tweet *tweet, NSError *error) {
         if (error != nil) {
             NSLog(@"Error posting tweet: %@", error.localizedDescription);
         }
         else {
             NSLog(@"Tweet sent: %@", tweet.contentText);
             [self closeComposeView];
             [self.delegate didTweet:tweet];
         }
     }];
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
