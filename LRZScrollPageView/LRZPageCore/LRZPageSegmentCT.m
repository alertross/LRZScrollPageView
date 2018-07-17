//
//  LRZPageSegmentCT.m
//  LRZScrollPageView
//
//  Created by 刘强 on 2018/7/17.
//  Copyright © 2018年 LightReason. All rights reserved.
//

#import "LRZPageSegmentCT.h"

#define LRZRGBColor(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define LRZFont(fontValue) [UIFont systemFontOfSize:fontValue]

@interface LRZPageSegmentCT()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property(nonatomic,retain)UICollectionView *collectionView;
@property(nonatomic,retain)UIView *lineView;
@property(nonatomic,retain)NSArray *dataArray;
@property(nonatomic,retain)LRZPageSegmentParam *param;                                      //设置参数
@property(nonatomic,assign)CGFloat itemWidth;                                               //平均宽度
@property(nonatomic,assign)NSInteger selectedIndex;                                         //当前选择
@property(nonatomic,retain)NSMutableArray *cellArray;
@end

@implementation LRZPageSegmentCT
- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame setParam:nil data:nil];
}
- (instancetype)initWithFrame:(CGRect)frame setParam:(LRZPageSegmentParam *)param{
    return [self initWithFrame:frame setParam:param data:nil];
}
- (instancetype)initWithFrame:(CGRect)frame setParam:(LRZPageSegmentParam *)param data:(NSArray<NSString *> *)data
{
    self = [super initWithFrame:frame];
    if (self) {
        if (param == nil) {param = [LRZPageSegmentParam defaultParam];}
        self.selectedIndex = param.startIndex;
        self.param = param;
        self.dataArray = data;
        if (_dataArray) {[self collectionView];}
        self.backgroundColor = LRZRGBColor(param.bgColor);
    }
    return self;
}

#pragma mark - Getter && Setter
- (UICollectionView *)collectionView{
    if (_collectionView == nil) {
        CGFloat dh = self.frame.size.height;
        UICollectionViewFlowLayout *laout = [[UICollectionViewFlowLayout alloc] init];
        laout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        laout.sectionInset = UIEdgeInsetsMake(0, _param.margin_spacing, 0, _param.margin_spacing);
        laout.minimumLineSpacing = _param.spacing;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, dh) collectionViewLayout:laout];
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[LRZPageSegmentCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [self addSubview:_collectionView];
        [self lineView];
        
        UIView *bline = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, self.frame.size.width, 0.5)];
        bline.backgroundColor = LRZRGBColor(_param.botLineColor);
        UIView *tline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
        tline.backgroundColor = LRZRGBColor(_param.topLineColor);
        [self addSubview:bline];
        [self addSubview:tline];
    }
    return _collectionView;
}

- (UIView *)lineView{
    if (_lineView == nil) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(_param.margin_spacing+(self.itemWidth+_param.spacing)*_param.startIndex, self.collectionView.frame.size.height-2, self.itemWidth, 2)];
        _lineView.hidden = !_param.showLine;
        CGFloat lineW = self.param.lineWidth < 0 ? self.itemWidth*0.6 : self.param.lineWidth;
        UIView *sline = [[UIView alloc] initWithFrame:CGRectMake((_lineView.frame.size.width-lineW)*0.5, 0, lineW, _lineView.frame.size.height)];
        [_lineView addSubview:sline];
        sline.backgroundColor = self.param.lineColor;
        [self.collectionView addSubview:_lineView];
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:self.param.startIndex inSection:0] animated:true scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
    return _lineView;
}

- (CGFloat)itemWidth{
    if (_itemWidth <= 0) {
        switch (self.param.type) {
            case LRZPageContentLeft:
                _itemWidth = self.param.itemWidth;
                break;
            case LRZPageContentBetween:
                _itemWidth = (_collectionView.frame.size.width - 2*_param.margin_spacing - (_dataArray.count-1)*_param.spacing)/_dataArray.count;
                break;
            default:
                break;
        }
    }
    return _itemWidth;
}

#pragma mark - public Methods
- (void)updataDataArray:(NSArray<NSString *> *)data{
    self.dataArray = data;
    [[self collectionView] reloadData];
}

- (void)selectIndex:(NSInteger)index animated:(BOOL)animated{
    self.selectedIndex = index;
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:true scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (void)setAssociatedScroll{
    __weak LRZPageSegmentCT *weakSelf = self;
    self.associatedSscrollBlock = ^(UIScrollView *scrollView) {
        if (weakSelf.collectionView.contentSize.width <= 0) {return;}
        int page = scrollView.contentOffset.x / scrollView.frame.size.width;
        CGFloat dx = scrollView.contentOffset.x;
        if (dx < 0.0) {dx = 0;page = -1;}
        if (dx > scrollView.contentSize.width-scrollView.frame.size.width) {
            dx = scrollView.contentSize.width-scrollView.frame.size.width;
            page = -1;
        }
        CGFloat dw = weakSelf.collectionView.contentSize.width - weakSelf.param.margin_spacing;
        CGFloat lx = dx * dw / scrollView.contentSize.width;
        
        weakSelf.lineView.frame = CGRectMake(weakSelf.param.margin_spacing+lx, weakSelf.lineView.frame.origin.y, weakSelf.lineView.frame.size.width, weakSelf.lineView.frame.size.height);
        if (page >= 0) {
            CGFloat dspace = weakSelf.itemWidth + weakSelf.param.spacing;
            
            for (LRZPageSegmentCell *cell in [weakSelf cellArray]) {
                CGFloat scale = fabs(cell.center.x-weakSelf.lineView.center.x)/dspace;
                if (scale <= 1.0) {
                    CGFloat fontSize = weakSelf.param.selectedfontSize + (weakSelf.param.fontSize - weakSelf.param.selectedfontSize)*scale;
                    cell.textLabel.font = LRZFont(fontSize);
                    float sr = (float)((weakSelf.param.textSelectedColor & 0xFF0000) >> 16);
                    float sg = (float)((weakSelf.param.textSelectedColor & 0xFF00) >> 8);
                    float sb = (float)(weakSelf.param.textSelectedColor & 0xFF);
                    float r = (float)((weakSelf.param.textColor & 0xFF0000) >> 16);
                    float g = (float)((weakSelf.param.textColor & 0xFF00) >> 8);
                    float b = (float)(weakSelf.param.textColor & 0xFF);
                    cell.textLabel.textColor = [UIColor colorWithRed: (sr+(r-sr)*scale)/255.0 green:(sg+(g-sg)*scale)/255.0 blue:(sb+(b-sb)*scale)/255.0 alpha:1];
                }else{
                    cell.textLabel.textColor = LRZRGBColor(weakSelf.param.textColor);
                    cell.textLabel.font = LRZFont(weakSelf.param.fontSize);
                }
            }
        }
    };
}

#pragma mark - private Methods


#pragma mark - dataSouce && Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat dh = self.frame.size.height;
    return CGSizeMake(self.itemWidth, dh);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.associatedSscrollBlock == nil) {
        self.selectedIndex = indexPath.row;
        [collectionView reloadData];
    }
    if (self.didSelectedIndexBlock) {
        self.didSelectedIndexBlock(indexPath.row);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LRZPageSegmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell updateText:_dataArray[indexPath.row] param:self.param];
    [cell didSelected:(indexPath.row == self.selectedIndex)];
    if (self.cellArray == nil) {self.cellArray = [NSMutableArray array];}
    if (![self.cellArray containsObject:cell]) {[self.cellArray addObject:cell];}
    return cell;
}
@end



/******************************* Param ********************************/
@implementation LRZPageSegmentParam

+ (LRZPageSegmentParam *)defaultParam{
    return [[LRZPageSegmentParam alloc] init];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = LRZPageContentBetween;
        self.spacing = 5;
        self.margin_spacing = 5;
        self.textSelectedColor = 0xFF0000;
        self.textColor = 0x000000;
        self.showLine = true;
        self.lineWidth = -1;
        self.lineColor = [UIColor redColor];
        self.fontSize = 15;
        self.selectedfontSize = 15;
        self.startIndex = 0;
        self.bgColor = 0xfcfcfc;
        self.topLineColor = 0xcdcdcd;
        self.botLineColor = 0xcdcdcd;
        self.itemWidth = 80;
    }
    return self;
}

@end


/******************************* Cell *********************************/
@implementation LRZPageSegmentCell

- (void)updateText:(NSString *)text param:(LRZPageSegmentParam *)param{
    self.param = param;
    self.textLabel.frame = self.contentView.bounds;
    self.textLabel.text = text;
}

- (void)didSelected:(BOOL)selected{
    self.textLabel.textColor = selected ? LRZRGBColor(_param.textSelectedColor) : LRZRGBColor(_param.textColor);
    self.textLabel.font = selected ? LRZFont(_param.selectedfontSize) : LRZFont(_param.fontSize);
}

- (UILabel *)textLabel{
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:self.param.fontSize];
        _textLabel.textColor = LRZRGBColor(self.param.textColor);
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_textLabel];
    }
    return _textLabel;
}

@end
