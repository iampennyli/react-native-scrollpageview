//
//  RNScrollPageViewManager.m
//  RNScrollPageView
//
//  Created by pennyli on 2017/3/13.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "RNScrollPageViewManager.h"
#import "RNScrollPageView.h"
#import <React/RCTUIManager.h>

@implementation RNScrollPageViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
	return [[RNScrollPageView alloc] initWithBridge: self.bridge];
}

RCT_EXPORT_VIEW_PROPERTY(pages, NSArray)
RCT_EXPORT_VIEW_PROPERTY(curIndex, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(onPageViewDidAppearedAtIndex, RCTDirectEventBlock)

RCT_EXPORT_METHOD(setPageIndex:(nonnull NSNumber *)reactTag
                  index:(NSNumber *)index)
{
    [self.bridge.uiManager addUIBlock:
     ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry){
         RNScrollPageView *view = (RNScrollPageView *)viewRegistry[reactTag];
         if (![view isKindOfClass:[RNScrollPageView class]]) {
             RCTLogError(@"Invalid view returned from registry, expecting RNScrollPageViewManager, got: %@", view);
         }
         [view setCurIndex: index.integerValue];
     }];
}

@end
