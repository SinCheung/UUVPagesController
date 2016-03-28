//
//  MainViewController.m
//  UUVPagesControllerDemo
//
//  Created by Admin on 16/3/28.
//  Copyright © 2016年 SC. All rights reserved.
//

#import "MainViewController.h"
#import "UUVPagesController.h"
#import "ListViewController.h"

@interface MainViewController ()<UUVListTopBarDelegate>
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UUVPagesController *pagesController;
@property (nonatomic, strong) NSMutableArray<UIViewController*> *viewControllers;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _viewControllers = [NSMutableArray array];
    [self.titles enumerateObjectsUsingBlock:^(NSString*  _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        ListViewController *listVC = [ListViewController new];
        listVC.title = title;
        [_viewControllers addObject:listVC];
    }];
    
    _pagesController = [UUVPagesController new];
    _pagesController.topBarPlace = self.navigationItem;
    _pagesController.topBarDelegate = self;
    _pagesController.viewControllers = _viewControllers;
    [_pagesController addParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - vars
- (NSArray *)titles
{
    if (!_titles) {
        _titles = @[@"赛事",@"攻略",@"花边",@"官方",@"外服测试",@"头条",@"科技",@"娱乐",@"热门推荐",@"其他"];
    }
    return _titles;
}

#pragma mark - PagesController delegate
- (void)itemAtIndex:(NSUInteger)index didSelectInTopBar:(UUVListTopBar *)bar
{
    
}

@end
