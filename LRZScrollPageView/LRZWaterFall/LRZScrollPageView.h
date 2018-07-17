//
//  LRZScrollPageView.h
//  LRZScrollPageView
//
//  Created by 刘强 on 2018/7/17.
//  Copyright © 2018年 LightReason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRZPageSegmentCT.h"

@class LRZScrollPageItemBaseView;
@class LRZScrollPageParam;
@class LRZPageSegmentParam;

@interface LRZScrollPageView : UIView

@property(nonatomic,assign)NSInteger currenIndex;

- (instancetype)initWithFrame:(CGRect)frame dataViews:(NSArray<LRZScrollPageItemBaseView *> *)dataViews;
- (instancetype)initWithFrame:(CGRect)frame dataViews:(NSArray<LRZScrollPageItemBaseView *> *)dataViews setParam:(LRZScrollPageParam *)param;

@end


/******************************每一项(子类继承)**************************/

@interface LRZScrollPageItemBaseView : UIView

- (instancetype)initWithPageTitle:(NSString *)title;
- (void)didAppeared;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,copy)void(^didAddScrollViewBlock)(UIScrollView *scrollView ,NSInteger index);

@end



/********************************* 设置参数 ****************************/

@interface LRZScrollPageParam : NSObject

+ (LRZScrollPageParam *)defaultParam;
@property(nonatomic,assign)CGFloat headerHeight;              //头部分栏高度
@property(nonatomic,retain)LRZPageSegmentParam *segmentParam;   //头部设置参数

@end
