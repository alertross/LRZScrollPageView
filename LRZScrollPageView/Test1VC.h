//
//  Test1VC.h
//  LRZScrollPageView
//
//  Created by 刘强 on 2018/7/17.
//  Copyright © 2018年 LightReason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRZNestScrollPageView.h"

@class LRZScrollPageItemBaseView;

@interface Test1VC : UIViewController

@end





/***************子类继承***********************/

@interface Test1ItemView:LRZScrollPageItemBaseView<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,retain)UITableView *tableView;
@end
