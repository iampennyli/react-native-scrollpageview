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
    RCTEventDispatcher *_eventDispatcher;
    
    NSMutableDictionary <NSString *, RCTRootView *> *_pageViewCaches;
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
    [self mergePages: pages];
    
    _curIndex = _curIndex < _pages.count ? _curIndex : 0;
    
    [self _reloadPages];
}

- (void)setCurIndex:(NSInteger)curIndex
{
    if (curIndex < _pages.count && curIndex >= 0) {
        if (_curIndex != curIndex) {
            _curIndex = curIndex;
            _scrollView.contentOffset = CGPointMake(_curIndex * CGRectGetWidth(_scrollView.frame), 0);
            
            [self _updatePageViewAtIndex: _curIndex];
        }
    }
}

- (void)_reloadPages
{
    if (_pageViewCaches == nil) {
        _pageViewCaches = [NSMutableDictionary new];
    }
    [self layoutScrollView];
    [self _updatePageViewAtIndex: _curIndex];
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
    
    [_pageViewCaches enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, RCTRootView * _Nonnull page, BOOL * _Nonnull stop) {
        NSInteger index = [self indexOfPage: name];
        page.frame = CGRectMake(index * CGRectGetWidth(_scrollView.frame), 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
    }];
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
    
    if (self.onPageViewDidAppearedAtIndex) {
        self.onPageViewDidAppearedAtIndex(@{@"index": @(_curIndex)});
    }
}

- (void)_updatePageViewAtIndex:(NSInteger)index
{
    if (index < _pages.count && index >=0) {
        RNScrollPageItem *item = _pages[index];
        NSDictionary *props = @{@"index": @(index), @"label": item.name, @"data": item.data ? : @""};
        if (item.needDestoryAndRelayout) {
            RCTRootView *pageView = _pageViewCaches[item.name];
            if (pageView) {
                [pageView removeFromSuperview];
                [_pageViewCaches removeObjectForKey: item.name];
                pageView = nil;
            }
            item.needDestoryAndRelayout = NO;
            pageView = [[RCTRootView alloc] initWithBridge: _bridge moduleName: item.reactRenderCell initialProperties: props];
            pageView.frame = CGRectMake(index * CGRectGetWidth(_scrollView.frame), 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
            
            [_scrollView addSubview: pageView];
            
            [_pageViewCaches setObject: pageView forKey: item.name];
            
        } else if (item.needUpdate) {
            RCTRootView *pageView = _pageViewCaches[item.name];
            if (pageView == nil) {
                pageView = [[RCTRootView alloc] initWithBridge: _bridge moduleName: item.reactRenderCell initialProperties: props];
                [_pageViewCaches setObject: pageView forKey: item.name];
            }
            item.needUpdate = NO;
            pageView.frame = CGRectMake(index * CGRectGetWidth(_scrollView.frame), 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
            pageView.appProperties = props;
        } else {
            RCTRootView *pageView = _pageViewCaches[item.name];
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
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    RNScrollPageItem *item = _pages[_curIndex];
    
    RCTRootView *view = _pageViewCaches[item.name];
    if (view) {
        [view cancelTouches];
    }
}

#pragma mark - Private

- (NSInteger)indexOfPage:(NSString *)name
{
    for (NSInteger i = 0; i < _pages.count; i++) {
        RNScrollPageItem *item = _pages[i];
        if ([item.name isEqualToString: name]) {
            return i;
        }
    }
    return NSNotFound;
}

- (void)mergePages:(NSArray <NSDictionary *> *)pages
{
    if (_pages == nil) {
        _pages = [NSMutableArray array];
        
    }
    
    NSMutableArray *newPages = [NSMutableArray array];
    
    [pages enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *pageName = obj[@"label"];
        NSString *reactRenderCell = obj[@"renderCell"];
        NSString *data = obj[@"data"];
        
        if (reactRenderCell.length != 0) {
            RNScrollPageItem *item = [RNScrollPageItem new];
            item.name = pageName;
            item.reactRenderCell = reactRenderCell;
            item.data = data;
            item.needUpdate = NO;
            item.needDestoryAndRelayout = NO;
            [newPages addObject: item];
        }
    }];
    
    NSMutableArray *outputPages = [NSMutableArray array];
    
    for (RNScrollPageItem *newPage in newPages) {
        for (RNScrollPageItem *page in self.pages) {
            if ([newPages isEqual: page]) {
                if ([newPage.data isEqualToString: page.data]) { // 相同页相同数据
                    newPage.needUpdate = NO;
                    newPage.needDestoryAndRelayout = NO;
                } else { // 相同页不同数据
                    newPage.needUpdate = YES;
                    newPage.needDestoryAndRelayout = NO;
                    
                }
                [outputPages addObject: newPage];
                break;
            }
        }
        
        // 如果没找到，则认为是新数据，需要重新
        newPage.needDestoryAndRelayout = YES;
        [outputPages addObject: newPage];
    }
    
    _pages = outputPages;
}



@end
