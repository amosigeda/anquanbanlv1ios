//
//  QuestionAndHelpViewController.m
//  KuBaoBei
//
//  Created by zhanshengshu on 2019/3/20.
//  Copyright © 2019年 HH. All rights reserved.
//

#import "QuestionAndHelpViewController.h"
#import "NSString+Tools.h"
#import "Masonry.h"

@interface QuestionAndHelpViewController ()

@property (nonatomic, weak) YUFoldingTableView *foldingTableView;
@property(nonatomic,strong) NSArray *titleArray;
@property(nonatomic,strong) NSArray *contentArray;

@end

@implementation QuestionAndHelpViewController

-(NSArray *)titleArray{
    if (!_titleArray) {
        _titleArray = @[NSLocalizedString(@"question_text1", nil),NSLocalizedString(@"question_text2", nil),NSLocalizedString(@"question_text3", nil),NSLocalizedString(@"question_text4", nil),NSLocalizedString(@"question_text5", nil),NSLocalizedString(@"question_text6", nil),NSLocalizedString(@"question_text7", nil),NSLocalizedString(@"question_text8", nil),NSLocalizedString(@"question_text9", nil),NSLocalizedString(@"question_text10", nil),NSLocalizedString(@"question_text11", nil),NSLocalizedString(@"question_text12", nil),NSLocalizedString(@"question_text13", nil),NSLocalizedString(@"question_text14", nil),NSLocalizedString(@"question_text15", nil),NSLocalizedString(@"question_text16", nil),NSLocalizedString(@"question_text17", nil),NSLocalizedString(@"question_text18", nil),NSLocalizedString(@"question_text19", nil),NSLocalizedString(@"question_text20", nil),NSLocalizedString(@"question_text21", nil)];
    }
    return _titleArray;
}

-(NSArray *)contentArray{
    if (!_contentArray) {
        _contentArray = @[NSLocalizedString(@"question_content1", nil),NSLocalizedString(@"question_content2", nil),NSLocalizedString(@"question_content3", nil),NSLocalizedString(@"question_content4", nil),NSLocalizedString(@"question_content5", nil),NSLocalizedString(@"question_content6", nil),NSLocalizedString(@"question_content7", nil),NSLocalizedString(@"question_content8", nil),NSLocalizedString(@"question_content9", nil),NSLocalizedString(@"question_content10", nil),NSLocalizedString(@"question_content11", nil),NSLocalizedString(@"question_content12", nil),NSLocalizedString(@"question_content13", nil),NSLocalizedString(@"question_content14", nil),NSLocalizedString(@"question_content15", nil),NSLocalizedString(@"question_content16", nil),NSLocalizedString(@"question_content17", nil),NSLocalizedString(@"question_content18", nil),NSLocalizedString(@"question_content19", nil),NSLocalizedString(@"question_content20", nil),NSLocalizedString(@"question_content21", nil)];
    }
    return _contentArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    // 创建tableView
    [self setupFoldingTableView];
}

- (void)setviewinfo{
    [self.navigationController popViewControllerAnimated:YES];
}

// 创建tableView
- (void)setupFoldingTableView{
    self.automaticallyAdjustsScrollViewInsets = NO;
//    CGFloat topHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + 44;
    YUFoldingTableView *foldingTableView = [[YUFoldingTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _foldingTableView = foldingTableView;
    UIView *headerView = [UIView new];
    UILabel *lbTitle = [UILabel new];
    UILabel *lbTips = [UILabel new];
    UILabel *lbInfo = [UILabel new];
    UILabel *lbContent = [UILabel new];
    lbTitle.font = [UIFont systemFontOfSize:20];
    lbTips.font = [UIFont systemFontOfSize:17];
    lbInfo.font = [UIFont systemFontOfSize:15];
    lbContent.font = [UIFont systemFontOfSize:14];
    lbTitle.textColor = [UIColor blackColor];
    lbTips.textColor = [UIColor redColor];
    lbInfo.textColor = [UIColor redColor];
    lbContent.textColor = [UIColor blackColor];
    lbTitle.text = NSLocalizedString(@"help_title", nil);
    lbTips.text = NSLocalizedString(@"help_tips", nil);
    lbInfo.text = NSLocalizedString(@"help_info", nil);
    lbContent.text = NSLocalizedString(@"help_content", nil);
    lbTitle.numberOfLines = 0;
    lbTips.numberOfLines = 0;
    lbInfo.numberOfLines = 0;
    lbContent.numberOfLines = 0;
    [headerView addSubview:lbTitle];
    [headerView addSubview:lbTips];
    [headerView addSubview:lbInfo];
    [headerView addSubview:lbContent];
    [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView.mas_top).mas_offset(16);
        make.leading.equalTo(headerView.mas_leading).mas_offset(16);
        make.trailing.equalTo(headerView.mas_trailing).mas_offset(16);
    }];
    [lbTips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbTitle.mas_bottom).mas_offset(16);
        make.leading.equalTo(lbTitle.mas_leading);
        make.trailing.equalTo(lbTitle.mas_trailing);
    }];
    [lbInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbTips.mas_bottom).mas_offset(16);
        make.leading.equalTo(lbTitle.mas_leading);
        make.trailing.equalTo(lbTitle.mas_trailing);
    }];
    [lbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbInfo.mas_bottom).mas_offset(16);
        make.leading.equalTo(lbTitle.mas_leading);
        make.trailing.equalTo(lbTitle.mas_trailing);
    }];
    // 文字宽度
    CGFloat textW = [UIScreen mainScreen].bounds.size.width - 2 * 16;
    // 文字高度
    CGFloat textH = [lbTitle.text sizeWithFont:lbTitle.font maxW:textW].height + [lbTips.text sizeWithFont:lbTips.font maxW:textW].height + [lbInfo.text sizeWithFont:lbInfo.font maxW:textW].height + [lbContent.text sizeWithFont:lbContent.font maxW:textW].height;
    headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, textH + 80);
    foldingTableView.tableHeaderView = headerView;
    [self.view addSubview:foldingTableView];
    [foldingTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
    }];
    foldingTableView.foldingDelegate = self;
    
    if (self.arrowPosition) {
        foldingTableView.foldingState = YUFoldingSectionStateShow;
    }
    if (self.index == 2) {
        foldingTableView.sectionStateArray = @[@"1", @"0", @"0"];
    }
}

#pragma mark - YUFoldingTableViewDelegate / required（必须实现的代理）
- (NSInteger )numberOfSectionForYUFoldingTableView:(YUFoldingTableView *)yuTableView{
    return self.titleArray.count;
}

- (NSInteger )yuFoldingTableView:(YUFoldingTableView *)yuTableView numberOfRowsInSection:(NSInteger )section{
    return 1;
}

- (CGFloat )yuFoldingTableView:(YUFoldingTableView *)yuTableView heightForHeaderInSection:(NSInteger )section{
    // 文字宽度
    CGFloat textW = [UIScreen mainScreen].bounds.size.width - 40;
    // 文字高度
    CGFloat textH = [self.titleArray[section] sizeWithFont:[UIFont systemFontOfSize:17.0] maxW:textW].height;
    return textH + 16;
}

- (CGFloat )yuFoldingTableView:(YUFoldingTableView *)yuTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 文字宽度
    CGFloat textW = [UIScreen mainScreen].bounds.size.width - 2 * 16;
    // 文字高度
    CGFloat textH = [self.contentArray[indexPath.section] sizeWithFont:[UIFont systemFontOfSize:15.0] maxW:textW].height;
    return textH + 16;
}

- (UITableViewCell *)yuFoldingTableView:(YUFoldingTableView *)yuTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [yuTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = self.contentArray[indexPath.section];
    return cell;
}

#pragma mark - YUFoldingTableViewDelegate / optional （可选择实现的）

- (NSString *)yuFoldingTableView:(YUFoldingTableView *)yuTableView titleForHeaderInSection:(NSInteger)section{
    return self.titleArray[section];
}

- (void )yuFoldingTableView:(YUFoldingTableView *)yuTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [yuTableView deselectRowAtIndexPath:indexPath animated:YES];
}

// 返回箭头的位置
- (YUFoldingSectionHeaderArrowPosition)perferedArrowPositionForYUFoldingTableView:(YUFoldingTableView *)yuTableView{
    // 没有赋值，默认箭头在左
    return YUFoldingSectionHeaderArrowPositionRight;
}

- (NSString *)yuFoldingTableView:(YUFoldingTableView *)yuTableView descriptionForHeaderInSection:(NSInteger )section{
    return @"";
}

-(UIFont *)yuFoldingTableView:(YUFoldingTableView *)yuTableView fontForTitleInSection:(NSInteger)section{
    return [UIFont systemFontOfSize:17];
}

//- (UIColor *)yuFoldingTableView:(YUFoldingTableView *)yuTableView backgroundColorForHeaderInSection:(NSInteger)section{
//    return [UIColor groupTableViewBackgroundColor];
////    return self.arrowPosition ? [UIColor whiteColor] : [UIColor colorWithRed:102/255.f green:102/255.f blue:255/255.f alpha:1.f];
//}
//
//- (UIColor *)yuFoldingTableView:(YUFoldingTableView *)yuTableView textColorForTitleInSection:(NSInteger)section{
//    return [UIColor blueColor];
////    return self.arrowPosition ? [UIColor redColor] : [UIColor blueColor];
//}

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
