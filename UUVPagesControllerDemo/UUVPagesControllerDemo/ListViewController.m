//
//  DetailViewController.m
//  UUVPagesControllerDemo
//
//  Created by Admin on 16/3/28.
//  Copyright © 2016年 SC. All rights reserved.
//

#import "ListViewController.h"
#import "DetailViewController.h"

#define TableViewCellIdentifier @"TableViewCellIdentifier"

@interface ListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _label.text = self.title;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TableViewCellIdentifier];
    [_tableView setContentInset:UIEdgeInsetsMake(64.f, 0, 0, 0)];
    [_tableView setScrollIndicatorInsets:UIEdgeInsetsMake(64, 0, 0, 0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView delegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DetailViewController *detailVC = [DetailViewController new];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - tableView data source methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
    cell.textLabel.text = [NSString stringWithFormat:@"row %zd",indexPath.row];
    return cell;
}

@end
