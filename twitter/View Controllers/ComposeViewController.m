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

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.composeTextView.delegate = self;
    
    // Do any additional setup after loading the view.
}

// returns whether or not to change the text
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    int characterLimit = 140;
    NSString *newText = [self.composeTextView.text stringByReplacingCharactersInRange:range withString:text];
    return newText.length < characterLimit;
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
