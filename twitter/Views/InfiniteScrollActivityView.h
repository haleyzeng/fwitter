//
//  InfiniteScrollActivityView.h
//  twitter
//
//  Created by Haley Zeng on 7/5/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfiniteScrollActivityView : UIView

- (void)startAnimating;
- (void)stopAnimating;
+ (CGFloat)defaultHeight;

@end
