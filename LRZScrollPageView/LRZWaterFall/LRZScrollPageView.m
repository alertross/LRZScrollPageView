//
//  LRZScrollPageView.m
//  LRZScrollPageView
//
//  Created by 刘强 on 2018/7/17.
//  Copyright © 2018年 LightReason. All rights reserved.
//

#import "LRZScrollPageView.h"
#import <WebKit/WebKit.h>


@interface LRZScrollPageView()<UIScrollViewDelegate>
@property(nonatomic,retain)LRZPageSegmentCT *segmentCT;
@property(nonatomic,retain)NSArray<LRZScrollPageItemBaseView *> *dataViews;
@property(nonatomic,retain)LRZScrollPageParam *param;
@property(nonatomic,retain)UIScrollView *scrollView;

@end

@implementation LRZScrollPageView

- (instancetype)initWithFrame:(CGRect)frame dataViews:(NSArray<LRZScrollPageItemBaseView *> *)dataViews{
    return [self initWithFrame:frame dataViews:dataViews setParam:nil];
}

- (instancetype)initWithFrame:(CGRect)frame dataViews:(NSArray<LRZScrollPageItemBaseView *> *)dataViews setParam:(LRZScrollPageParam *)param
{
    self = [super initWithFrame:frame];
    if (self) {
        if (param == nil) {param = [LRZScrollPageParam defaultParam];}
        self.param = param;
        if (param.segmentParam.startIndex >= dataViews.count) {param.segmentParam.startIndex = 0;}
        self.currenIndex = param.segmentParam.startIndex;
        self.dataViews = dataViews;
        NSMutableArray *titles = [NSMutableArray array];
        for (int i = 0; i < _dataViews.count; ++i) {
            _dataViews[i].index = i;
            NSString *title = _dataViews[i].title;
            [titles addObject:(title == nil ? [NSString stringWithFormat:@"%d",i] : title)];
            _dataViews[i].frame = CGRectMake(
                                             i*self.scrollView.frame.size.width,
                                             0,
                                             self.scrollView.frame.size.width,
                                             self.scrollView.frame.size.height
                                             );
            [self.scrollView addSubview:_dataViews[i]];
            if (i == param.segmentParam.startIndex) {
                [_dataViews[i] didAppeared];
            }
        }
        self.scrollView.contentSize = CGSizeMake(_dataViews.count*self.scrollView.frame.size.width, 0);
        [self.segmentCT updataDataArray:titles];
        [self.segmentCT setAssociatedScroll];
        
        if (param.segmentParam.startIndex > 0) {
            [self.scrollView setContentOffset:CGPointMake(param.segmentParam.startIndex * self.scrollView.frame.size.width , 0) animated:false];
        }
    }
    return self;
}

- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(
                                                                     0,
                                                                     self.param.headerHeight,
                                                                     self.frame.size.width,
                                                                     self.frame.size.height-self.param.headerHeight
                                                                     )];
        _scrollView.pagingEnabled = true;
        _scrollView.directionalLockEnabled = true;
        _scrollView.showsHorizontalScrollIndicator = false;
        
        [self addSubview:_scrollView];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (LRZPageSegmentCT *)segmentCT{
    if (_segmentCT == nil) {
        _segmentCT = [[LRZPageSegmentCT alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.param.headerHeight) setParam:self.param.segmentParam];
        __weak LRZScrollPageView *weakSelf = self;
        _segmentCT.didSelectedIndexBlock = ^(NSInteger index) {
            [weakSelf.scrollView setContentOffset:CGPointMake(index * weakSelf.scrollView.frame.size.width , 0) animated:true];
        };
        [self addSubview:_segmentCT];
    }
    return _segmentCT;
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.segmentCT.associatedSscrollBlock) {
        self.segmentCT.associatedSscrollBlock(scrollView);
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self dealWithScroll];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self dealWithScroll];
}
- (void)dealWithScroll{
    int index = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    LRZScrollPageItemBaseView *view = [self.dataViews objectAtIndex:index];
    [view didAppeared];
    [self.segmentCT selectIndex:index animated:false];
    
    self.currenIndex = index;
}

@end


/*************************** 每一项 ******************************/
@implementation LRZScrollPageItemBaseView
- (instancetype)initWithPageTitle:(NSString *)title{
    self = [super init];
    if (self) {
        self.title = title;
    }
    return self;
}
- (void)didAddSubview:(UIView *)subview{
    [super didAddSubview:subview];
    if ([subview isKindOfClass:[UIScrollView class]]) {
        if (self.didAddScrollViewBlock) {
            self.didAddScrollViewBlock((UIScrollView *)subview,_index);
        }
    }else if ([subview isKindOfClass:[WKWebView class]]){
        if (self.didAddScrollViewBlock) {
            self.didAddScrollViewBlock(((WKWebView *)subview).scrollView,_index);
        }
    }else if ([subview isKindOfClass:[UIWebView class]]){
        if (self.didAddScrollViewBlock) {
            self.didAddScrollViewBlock(((UIWebView *)subview).scrollView,_index);
        }
    }else{
        for (UIView *sview in [subview subviews]) {
            if ([sview isKindOfClass:[UIScrollView class]]) {
                if (self.didAddScrollViewBlock) {
                    self.didAddScrollViewBlock((UIScrollView *)sview,_index);
                }
            }
        }
    }
}
- (void)didAppeared{}
@end

/*************************** 设置参数 ****************************/
@implementation LRZScrollPageParam
+ (LRZScrollPageParam *)defaultParam{
    return [[LRZScrollPageParam alloc] init];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.headerHeight = 40;
        self.segmentParam = [LRZPageSegmentParam defaultParam];
    }
    return self;
}
@end
