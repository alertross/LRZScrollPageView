//
//  LRZPageSegmentCT.h
//  LRZScrollPageView
//
//  Created by 刘强 on 2018/7/17.
//  Copyright © 2018年 LightReason. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LRZPageSegmentParam;
typedef NS_ENUM(NSInteger, LRZPageContentType) {
    LRZPageContentLeft = 0,                    //从左到右依次排列
    LRZPageContentBetween = 1,                 //平均排列一屏
};
@interface LRZPageSegmentCT : UIView

- (instancetype)initWithFrame:(CGRect)frame setParam:(LRZPageSegmentParam *)param;    //初始化
- (void)updataDataArray:(NSArray<NSString *> *)data;                                //更新数据源
- (void)setAssociatedScroll;                                                        //设置关联滚动
- (void)selectIndex:(NSInteger)index animated:(BOOL)animated;                       //设置选择
@property(nonatomic,copy)void(^didSelectedIndexBlock)(NSInteger index);             //选择回调
@property(nonatomic,copy)void(^associatedSscrollBlock)(UIScrollView *scrollView);   //关联滚动

@end


/******************************* Param ********************************/

@interface LRZPageSegmentParam : NSObject

+ (LRZPageSegmentParam *)defaultParam;

@property(nonatomic,assign)LRZPageContentType type;      //排列类型
@property(nonatomic,assign)CGFloat margin_spacing;     //左右边缘间距
@property(nonatomic,assign)CGFloat spacing;            //中间间距
@property(nonatomic,assign)int textSelectedColor;      //16进制选中的颜色
@property(nonatomic,assign)int textColor;              //16进制正常的颜色
@property(nonatomic,assign)BOOL showLine;              //显示底部线
@property(nonatomic,assign)CGFloat lineWidth;          //底部线宽
@property(nonatomic,retain)UIColor *lineColor;         //底部线颜色
@property(nonatomic,assign)CGFloat fontSize;           //字体大小
@property(nonatomic,assign)CGFloat selectedfontSize;   //选择字体大小
@property(nonatomic,assign)NSInteger startIndex;       //默认选中的item
@property(nonatomic,assign)int bgColor;                //16进制背景颜色
@property(nonatomic,assign)int topLineColor;           //16进制上边框颜色
@property(nonatomic,assign)int botLineColor;           //16进制下边框颜色
@property(nonatomic,assign)CGFloat itemWidth;          //宽度

@end

/******************************* Cell *********************************/

@interface LRZPageSegmentCell : UICollectionViewCell
@property(nonatomic,weak)LRZPageSegmentParam *param;
- (void)updateText:(NSString *)text param:(LRZPageSegmentParam *)param;
- (void)didSelected:(BOOL)selected;
@property(nonatomic,retain)UILabel *textLabel;

@end
