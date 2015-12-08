//
//  ViewController.m
//  TZPopInputView
//
//  Created by 谭真 on 15/11/26.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "ViewController.h"
#import "TZPopInputView.h"
#import "TZDatePickerView.h"
#import "TZTimePickerView.h"

#define mScreenWidth   ([UIScreen mainScreen].bounds.size.width)
#define mScreenHeight  ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()
@property (nonatomic, strong) TZPopInputView *inputView;    // 输入框
@property (nonatomic, strong) TZDatePickerView *datePicker; // 日期选择器
@property (nonatomic, strong) TZTimePickerView *timePicker; // 时间选择器
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建三个button + 一个button + 一个button
    [self createButtonWithY:100 title:@"1.1 一行输入框  手机号" tag:0];
    [self createButtonWithY:160 title:@"1.2 两行输入框  测试的" tag:1];
    [self createButtonWithY:220 title:@"1.3 三行输入框  支付宝" tag:2];

    [self createButtonWithY:320 title:@"2. 日期选择器  选日期" tag:3];
    
    [self createButtonWithY:420 title:@"3. 时间选择器  选时间" tag:4];
}

/* 
  之前是用懒加载的方式初始化inputView和datePicker，发现会有一定时间的延迟，约60ms，故将初始化方法在这里调用，这样则一点击按钮控件就能弹出来。
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_inputView) {
        self.inputView = [[TZPopInputView alloc] init];
    }
    if (!_datePicker) {
        self.datePicker = [[TZDatePickerView alloc] init];
    }
    if (!_timePicker) {
        self.timePicker = [[TZTimePickerView alloc] init];
    }
}

/** 创建button的方法 */
- (void)createButtonWithY:(CGFloat)y title:(NSString *)title tag:(NSInteger)tag{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(50, y, mScreenWidth - 100, 60);
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = tag;
    [self.view addSubview:button];
}

#pragma mark 点击事件

/** button的点击事件 */
- (void)buttonClick:(UIButton *)button {
    switch (button.tag) {
        case 0: // 一行输入框
            [self showInputViewType1];
            break;
        case 1: // 两行输入框
            [self showInputViewType2];
            break;
        case 2: // 三行输入框
            [self showInputViewType3];
            break;
        case 3: // 日期选择器
            [self showDatePicker];
            break;
        case 4: // 时间选择器
            [self showTimePicker];
            break;
        default:
            break;
    }
}

#pragma mark inputView相关

/*
    tips：
    1. 传进去的items数组的元素个数，决定inputView的输入框的个数
    2. 自定义键盘的代码需要在show之后，因为show的时候，键盘会设置一次。
    3. inputView的回调block，返回的数组，分别是三个输入框的文本值。如果有一个输入框没有值，那么返回的数组元素个数也少一个。
 */

/** 一行输入框 */
- (void)showInputViewType1 {
    // 1. 设置数据
    self.inputView.titleLable.text = @"修改手机号";
    [self.inputView setItems:@[@"输入新的手机号"]];
    // 2. show 显示
    [self.inputView show];
    // 3. 自定义键盘
    self.inputView.textFiled1.keyboardType = UIKeyboardTypeNumberPad;
    // 4. 定义回调block
    __weak typeof(self) weakSelf = self;
    self.inputView.okButtonClickBolck = ^(NSMutableArray *arr){
        [weakSelf.inputView hide];
    };
}

/** 两行输入框 */
- (void)showInputViewType2 {
    self.inputView.titleLable.text = @"修改XXX";
    [self.inputView setItems:@[@"测试一下",@"第二个输入框"]];
    [self.inputView show];
    
    __weak typeof(self) weakSelf = self;
    self.inputView.okButtonClickBolck = ^(NSMutableArray *arr){
        [weakSelf.inputView hide];
    };
}

/** 三行输入框 */
- (void)showInputViewType3 {
    self.inputView.titleLable.text = @"修改支付宝账号";
    [self.inputView setItems:@[@"原支付宝信息",@"新支付宝账号",@"新收款人姓名"]];
    [self.inputView setTextFieldItems:@[[NSString stringWithFormat:@"%@     %@",@"alipayAccount",@"name"]]];
    [self.inputView setPlaceholderItems:@[@"",@"手机号或邮箱",@""]];
    [self.inputView show];
    self.inputView.textFiled2.keyboardType = UIKeyboardTypeEmailAddress;
    
    __weak typeof(self) weakSelf = self;
    self.inputView.okButtonClickBolck = ^(NSMutableArray *arr){
        [weakSelf.inputView hide];
    };
}

#pragma mark datePicker相关

/* tip: datePicker的回调block，返回的数据，分别是用户选择的开始时间、结束时间。*/

/** 显示时间选择器 */
- (void)showDatePicker {
    [self.datePicker show];
    
    __weak typeof(self) weakSelf = self;
    self.datePicker.gotoSrceenOrderBlock = ^(NSString *beginDateStr,NSString *endDateStr){
        [weakSelf.datePicker hide];
    };
}

#pragma mark timePicker相关

/* tip: timePicker的回调block，返回的数据，分别是用户选择的日期string、时间string。*/

/** 显示时间选择器 */
- (void)showTimePicker {
    [self.timePicker show];
    
    __weak typeof(self) weakSelf = self;
    self.timePicker.okBtnClickBlock = ^(NSString *dateStr,NSString *timeStr){
        [weakSelf.timePicker hide];
    };
}

@end
