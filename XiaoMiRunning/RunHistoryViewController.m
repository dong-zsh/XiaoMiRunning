//
//  RunHistoryViewController.m
//  XiaoMiRunning
//
//  Created by 张东东 on 16/4/27.
//  Copyright © 2016年 zhangdongdong. All rights reserved.
//

#import "RunHistoryViewController.h"
#import "DataBaseHelper.h"
#import "ShowLocusViewController.h"

@interface RunHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *dataArray;
}
@property (weak, nonatomic) IBOutlet UITableView *historyTable;

@end

@implementation RunHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationitem];
    dataArray = [NSMutableArray array];
    dataArray = [DataBaseHelper queryAlltime];
    _historyTable.tableFooterView = [[UIView alloc] init];
    // Do any additional setup after loading the view from its nib.
}
- (void)setNavigationitem
{
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(popBack:)];
    leftItem.tintColor = [UIColor whiteColor];
    [self.navigationItem setBackBarButtonItem:leftItem];
    
}
- (void)popBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = dataArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShowLocusViewController *LocusVC = [[ShowLocusViewController alloc] init];
    LocusVC.time = dataArray[indexPath.row];
    [self.navigationController pushViewController:LocusVC animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
