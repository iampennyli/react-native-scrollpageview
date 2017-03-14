//
//  RNScrollPageView.h
//  RNScrollPageView
//
//  Created by pennyli on 2017/3/13.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCTBridge;

@interface RNScrollPageView : UIView <UIScrollViewDelegate>

- (instancetype)initWithBridge:(RCTBridge *)bridge;

@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, strong) UIScrollView *scrollView;

@end
