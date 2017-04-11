//
//  RNScrollPageView.m
//  RNScrollPageView
//
//  Created by pennyli on 2017/3/13.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "RNScrollPageView.h"
#import "RNScrollPageItem.h"

#import <React/RCTBridge.h>
#import <React/RCTAssert.h>
#import <React/RCTRootView.h>
#import <React/RCTComponent.h>
#import <React/RCTEventDispatcher.h>

@interface RNScrollPageView()
@property (nonatomic, copy) RCTDirectEventBlock onPageViewDidAppearedAtIndex;
@end

@implementation RNScrollPageView {
	RCTBridge *_bridge;
	
	NSMutableDictionary *_pageViewCaches;
	NSInteger _curIndex;
}

RCT_NOT_IMPLEMENTED(-initWithFrame:(CGRect)frame)
RCT_NOT_IMPLEMENTED(-initWithCoder:(NSCoder *)aDecoder)

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
	RCTAssertParam(bridge);
	RCTAssertParam(bridge.eventDispatcher);

	if (self = [super initWithFrame: CGRectZero]) {
		_bridge = bridge;
		while ([_bridge respondsToSelector:NSSelectorFromString(@"parentBridge")]
					 && [_bridge valueForKey:@"parentBridge"]) {
			_bridge = [_bridge valueForKey:@"parentBridge"];
		}
	}
	return self;
}

- (void)setPages:(NSMutableArray *)pages
{
	if (_pages == nil) {
		_pages = [NSMutableArray array];
	} else {
		[_pages removeAllObjects];
	}
	
	if (_pageViewCaches == nil) {
		_pageViewCaches = [NSMutableDictionary new];
	}
	
	_curIndex = 0;
	
	[pages enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		NSString *pageName = obj[@"label"] ? : @"default";
		NSString *reactRenderCell = obj[@"renderCell"];
		RNScrollPageItem *item = [RNScrollPageItem new];
		item.name = pageName;
		item.reactRenderCell = reactRenderCell;
		[_pages addObject: item];
	}];
	
	[self reloadPages];
}

- (void)setCurIndex:(NSInteger)curIndex
{
	if (curIndex < _pages.count && curIndex >= 0) {
		if (_curIndex != curIndex) {
			_curIndex = curIndex;
			_scrollView.contentOffset = CGPointMake(_curIndex * CGRectGetWidth(_scrollView.frame), 0);
			
			[self pageViewDidAppearedAtIndex: _curIndex];
		}
	}
}

- (void)reloadPages
{
	[_pageViewCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber *  _Nonnull key, RCTRootView *  _Nonnull obj, BOOL * _Nonnull stop) {
		[obj removeFromSuperview];
	}];
	
	[_pageViewCaches removeAllObjects];
	
	[self layoutScrollView];
	
}

- (void)layoutScrollView
{
	if (_scrollView == nil) {
		_scrollView = [[UIScrollView alloc] initWithFrame: self.bounds];
		_scrollView.pagingEnabled = YES;
		_scrollView.backgroundColor = [UIColor clearColor];
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.delegate = self;
		[self addSubview: _scrollView];
	}
	_scrollView.frame = self.bounds;
	_scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * _pages.count, CGRectGetHeight(self.bounds));
	
	[_scrollView setContentOffset: CGPointMake(_curIndex * CGRectGetWidth(_scrollView.frame), 0)];
	
	[_pageViewCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber *  _Nonnull key, RCTRootView *  _Nonnull obj, BOOL * _Nonnull stop) {
		NSInteger index = key.integerValue;
		obj.frame = CGRectMake(index * CGRectGetWidth(_scrollView.frame), 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
	}];
	
	[self pageViewDidAppearedAtIndex: _curIndex];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self layoutScrollView];
}

#pragma mark - Logic

- (void)pageViewDidAppearedAtIndex:(NSInteger)index
{
	[self _updatePageViewAtIndex: index];
}

- (void)_updatePageViewAtIndex:(NSInteger)index
{
	if (index < _pages.count && index >=0) {
		RCTRootView *pageView = _pageViewCaches[@(index)];
		RNScrollPageItem *item = _pages[index];
		if (pageView == nil && item) {
			RCTRootView *rootView = [[RCTRootView alloc] initWithBridge: _bridge moduleName: item.reactRenderCell initialProperties: @{@"index": @(index), @"label": item.name}];
			rootView.frame = CGRectMake(index * CGRectGetWidth(_scrollView.frame), 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
			
			[_scrollView addSubview: rootView];
			
			[_pageViewCaches setObject: rootView forKey: @(index)];
		} else {
			pageView.frame = CGRectMake(index * CGRectGetWidth(_scrollView.frame), 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
		}
	}
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGPoint offset = scrollView.contentOffset;
	_curIndex = offset.x / CGRectGetWidth(scrollView.frame);
	
	[self pageViewDidAppearedAtIndex: _curIndex];
	
	if (self.onPageViewDidAppearedAtIndex) {
		self.onPageViewDidAppearedAtIndex(@{@"index": @(_curIndex)});
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    RCTRootView *view = _pageViewCaches[@(_curIndex)];
    if (view) {
        [view cancelTouches];
    }
}


@end
