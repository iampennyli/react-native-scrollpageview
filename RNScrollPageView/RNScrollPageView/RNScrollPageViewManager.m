//
//  RNScrollPageViewManager.m
//  RNScrollPageView
//
//  Created by pennyli on 2017/3/13.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "RNScrollPageViewManager.h"
#import "RNScrollPageView.h"

@implementation RNScrollPageViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
	return [[RNScrollPageView alloc] initWithBridge: self.bridge];
}

RCT_EXPORT_VIEW_PROPERTY(pages, NSArray)
RCT_EXPORT_VIEW_PROPERTY(curIndex, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(onPageViewDidAppearedAtIndex, RCTDirectEventBlock)

@end
