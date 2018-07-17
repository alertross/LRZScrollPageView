//
//  LRZNestScrollPageView.m
//  LRZScrollPageView
//
//  Created by 刘强 on 2018/7/17.
//  Copyright © 2018年 LightReason. All rights reserved.
//

#import "LRZNestScrollPageView.h"

@interface LRZNestScrollPageView()<UIScrollViewDelegate>
@property(nonatomic,retain,readwrite)LRZScrollPageView *pageView;
@property(nonatomic,retain)LRZSMGRScrollView *scrollView;
@property(nonatomic,retain)LRZNestParam *param;
@property(nonatomic,retain)NSArray<LRZScrollPageItemBaseView *> *dataViews;
@property(nonatomic,retain)NSMutableArray<UIScrollView *> *scrollArray;
@property(nonatomic,retain)UIView *headView;
@property(nonatomic,assign)BOOL scrollTag;
@property(nonatomic,assign)CGFloat lastDy;
@property(nonatomic,assign)BOOL nextReturn;
@property(nonatomic,assign)CGFloat stayHeight;

@end

@implementation LRZNestScrollPageView

- (instancetype)initWithFrame:(CGRect)frame headView:(UIView *)headView subDataViews:(NSArray<LRZScrollPageItemBaseView *> *)dataViews setParam:(LRZNestParam *)param{
    self = [super initWithFrame:frame];
    if (self) {
        self.headView = headView;
        if (headView == nil) {_headView = [[UIView alloc] init];}
        CGFloat headHeight = ceil(_headView.frame.size.height);
        _headView.frame = CGRectMake(0, 0, frame.size.width, headHeight);
        self.param = param;
        self.dataViews = dataViews;
        if (self.param == nil) {self.param = [LRZNestParam defaultParam];}
        self.stayHeight = _headView.frame.size.height - fabs(_param.yOffset);
        [self pageView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame headView:(UIView *)headView subDataViews:(NSArray<LRZScrollPageItemBaseView *> *)dataViews{
    return [self initWithFrame:frame headView:headView subDataViews:dataViews setParam:nil];;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self pageView];
    }
    return self;
}

#pragma mark Getter && Setter
- (UIScrollView *)eScrollView{
    return _scrollView;
}

- (LRZScrollPageView *)pageView{
    if (_pageView == nil) {
        __weak LRZNestScrollPageView *weakSelf = self;
        id block = ^(UIScrollView *scrollView,NSInteger index){
            scrollView.tag = index;
            if (![weakSelf.scrollArray containsObject:scrollView]) {
                [weakSelf.scrollArray addObject:scrollView];
                [scrollView addObserver:weakSelf forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
            }
        };
        for (LRZScrollPageItemBaseView *sv in self.dataViews) {
            sv.didAddScrollViewBlock = block;
        }
        _pageView = [[LRZScrollPageView alloc] initWithFrame:CGRectMake(0,
                                                                        self.headView.frame.size.height, self.frame.size.width, self.frame.size.height-fabs(_param.yOffset))
                                                   dataViews:self.dataViews
                                                   setParam:self.param.scrollParam];
        [self.scrollView addSubview:_pageView];
        [self.scrollView addSubview:_headView];
    }
    return _pageView;
}

- (LRZSMGRScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[LRZSMGRScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsVerticalScrollIndicator = false;
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(0, self.frame.size.height + _stayHeight);
        _scrollView.viewArray = self.scrollArray;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (NSMutableArray<UIScrollView *> *)scrollArray{
    if (_scrollArray == nil) {
        _scrollArray = [[NSMutableArray alloc] init];
    }
    return _scrollArray;
}


#pragma mark delegate && obsever
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview == nil) {
        for (UIScrollView *sc in _scrollArray) {
            [sc removeObserver:self forKeyPath:@"contentOffset"];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    BOOL show = false;
    CGFloat dh = scrollView.contentOffset.y;
    if (dh >= _stayHeight) {
        scrollView.contentOffset = CGPointMake(0, _stayHeight);
        _lastDy = scrollView.contentOffset.y;
        show = true;
    }
    UIScrollView *currenSubScrollView = nil;
    for (UIScrollView *sc in self.scrollArray) {
        if (sc.tag == self.pageView.currenIndex) {
            currenSubScrollView = sc;
            break;
        }
    }
    if (currenSubScrollView == nil) {return;}
    if (currenSubScrollView.contentOffset.y > 0 && (self.scrollView.contentOffset.y < _stayHeight) && !self.scrollTag) {
        scrollView.contentOffset = CGPointMake(0, _lastDy);
        show = true;
    }
    _lastDy = scrollView.contentOffset.y;
    currenSubScrollView.showsVerticalScrollIndicator = show;
    if (self.didScrollBlock) {
        self.didScrollBlock(scrollView.contentOffset.y);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"]){
        if (_nextReturn) {_nextReturn = false;return;}
        CGFloat new = [change[@"new"] CGPointValue].y;
        CGFloat old = [change[@"old"] CGPointValue].y;
        if (new == old) {return;}
        CGFloat dh = new - old;
        if (dh < 0) {
            //向下
            if(((UIScrollView *)object).contentOffset.y < 0){
                _nextReturn = true;
                ((UIScrollView *)object).contentOffset = CGPointMake(0, 0);
            }
            self.scrollTag = false;
        }else{
            //向上
            if (self.scrollView.contentOffset.y < _stayHeight) {
                _nextReturn = true;
                self.scrollTag = true;
                ((UIScrollView *)object).contentOffset = CGPointMake(0, old);
            }else{
                self.scrollTag = false;
            }
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

/**************************  参数  *****************************/
@implementation LRZNestParam
+ (LRZNestParam *)defaultParam{
    return [[LRZNestParam alloc] init];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollParam = [LRZScrollPageParam defaultParam];
        self.yOffset = 0;
    }
    return self;
}
@end

/********************** 多手势同时识别 ***************************/
@implementation LRZSMGRScrollView
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if ([self.viewArray containsObject:otherGestureRecognizer.view]) {
        return true;
    }
    return false;
}

@end



