//
//  LRZNestScrollPageView.h
//  LRZScrollPageView
//
//  Created by 刘强 on 2018/7/17.
//  Copyright © 2018年 LightReason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRZScrollPageView.h"

@class LRZNestParam;
@class LRZScrollPageItemBaseView;
@class LRZScrollPageParam;

@interface LRZNestScrollPageView : UIView

@property(nonatomic,retain,readonly)LRZScrollPageView *pageView;      //分页
- (UIScrollView *)eScrollView;                                      //返回scrollview
@property(nonatomic,copy)void(^didScrollBlock)(CGFloat dy);         //滚动回调

- (instancetype)initWithFrame:(CGRect)frame headView:(UIView *)headView subDataViews:(NSArray<LRZScrollPageItemBaseView *> *)dataViews;
- (instancetype)initWithFrame:(CGRect)frame headView:(UIView *)headView subDataViews:(NSArray<LRZScrollPageItemBaseView *> *)dataViews setParam:(LRZNestParam *)param;
@end


/**************************  参数  *****************************/
@interface LRZNestParam:NSObject
@property(nonatomic,retain)LRZScrollPageParam *scrollParam;     //分页设置的参数
@property(nonatomic,assign)CGFloat yOffset;                   //停留位置

+ (LRZNestParam *)defaultParam;
@end


/********************** 多手势同时识别 ***************************/
@interface LRZSMGRScrollView : UIScrollView
@property(nonatomic,weak)NSArray *viewArray;     //自己和viewArray上的首饰
@end
