//
//  RNScrollPageItem.h
//  RNScrollPageView
//
//  Created by pennyli on 2017/3/14.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNScrollPageItem : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *reactRenderCell;
@property (nonatomic, strong) NSString *data;

@property (nonatomic, assign) BOOL needUpdate; // 需要更新页面

@property (nonatomic, assign) BOOL needDestoryAndRelayout; // 需要重新布局
@end
