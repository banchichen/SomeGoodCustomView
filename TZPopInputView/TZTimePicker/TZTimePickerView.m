//
//  TZTimePickerView.m
//
//  Created by 谭真 on 15/11/4.
//  Copyright © 2015年 memberwine. All rights reserved.
//  时间选择器（选择某个时间段）

#import "TZTimePickerView.h"

@interface TZTimePickerView ()

#define mScreenWidth   ([UIScreen mainScreen].bounds.size.width)
#define mScreenHeight  ([UIScreen mainScreen].bounds.size.height)
#define mTitleColorDisabled  [UIColor colorWithRed:181/255.0 green:181/255.0 blue:181/255.0 alpha:1.0]
#define mBgColorDisabled     [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0]

/** 背景cover */
@property (nonatomic, strong) UIView *bgView;
/** 上部工具bar */
@property (weak, nonatomic) IBOutlet UIButton *lastDayBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextDayBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
/** 时间格子button */
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;
@property (weak, nonatomic) IBOutlet UIButton *btn4;
@property (weak, nonatomic) IBOutlet UIButton *btn5;
@property (weak, nonatomic) IBOutlet UIButton *btn6;
@property (weak, nonatomic) IBOutlet UIButton *btn7;
@property (weak, nonatomic) IBOutlet UIButton *btn8;
@property (weak, nonatomic) IBOutlet UIButton *btn9;
@property (weak, nonatomic) IBOutlet UIButton *btn10;
@property (weak, nonatomic) IBOutlet UIButton *btn11;
@property (weak, nonatomic) IBOutlet UIButton *btn12;
@property (nonatomic, strong) NSArray *btnArr;     // 按钮数组
/** 当天是否可预约的时间数据 */
@property (nonatomic, copy) NSArray *isShowingArr; // 当前日期的各个时间点是否可预约的数组，直接和界面进行交互
/** 下标 */
@property (nonatomic, assign) NSInteger index;
/** 当前展示的日期 */
@property (nonatomic, copy) NSString *currentDateStr;
/** 时间格式转换器 yyyy-MM-dd */
@property (nonatomic, copy) NSDateFormatter *formatter;
/** 用户当前选择的时间点 */
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, weak) UIButton *selectedButton;

@end

@implementation TZTimePickerView

#pragma mark 配置界面

/* 每一个自定义控件，都需要一定的数据，这个数据一般由控制器传过来，控件根据数据的不同进行不同的展示。之后若将该控件移植到其他项目中，由新的控制器给它数据就行 */

/*
 关于数据的设计：
 
 假设这个控件应用在这样的场景：用户预约医生进行视频一对一咨询，用户选择未来7天内的某个时间点。那么这个控件需要什么数据呢？
 
 我们需要知道 用户选择的某个时间点里 专家是否有空，从而展示在界面上的效果是，这个按钮能否被点击。
 
 这个控件一共有12个按钮，7天的可选择日期。
 思考1：每一天里，这12个按钮的enable状态，需要一个有12个元素的数组，也就是这里的 _isShowingArr。
 思考2：这里一共7天，那么需要7个这样的数组，就是一个有7个子数组元素的大数组，也就是这里的 _allDaysArr。
 
 tip1: _allDaysArr是一个大数组，装着可选择日期范围内，每个时间点是否可预约的数据，_allDaysArr的count是可选择的范围大小。
       它的每个元素又是一个有12个元素的小数组，代表一天中共12个时间点是否可预约。
       "1" : 表示该时间点专家有空，可以预约；
       "0" : 表示该时间点专家没空，不可预约。
 tip2: 总的大数组数据原本要结合服务器返回的 [哪些时间段已被预定] 的数据进行更新的
       这里由于条件限制，暂只和当前时间点对比，只能选择以后的时间
 
 用户点击 上一天/下一天 按钮时，只要改变_isShowingArr就行，这12个按钮的enable状态总是由_isShowingArr决定。先改变数据，再刷新界面。所以代码如下：
 
 */

- (NSArray *)allDaysArr {
    if (_allDaysArr == nil) {
        NSMutableArray *allDaysArr = [NSMutableArray array];
        // 允许用户选择未来7天内的时间
        for (NSInteger i = 0; i < 7; i++) {
            NSArray *array =  @[@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1"];
            [allDaysArr addObject:array];
        }
        _allDaysArr = allDaysArr;
    }
    return _allDaysArr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"TZTimePickerView" owner:self options:nil] lastObject];
        // 初始化设置
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        self.frame = CGRectMake(20 + mScreenWidth, (mScreenHeight - 240) / 2, mScreenWidth - 40, 240);
        [window addSubview:self.bgView];
        [window addSubview:self];
    }
    return self;
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _bgView.hidden = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_bgView addGestureRecognizer:tap];
    }
    return _bgView;
}

- (void)awakeFromNib {
    // 一次性的设置
    self.layer.cornerRadius = 8;
    self.layer.borderWidth = 0.5;
    CGFloat rgb = 188 / 255.0;
    UIColor *borderColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    self.layer.borderColor = borderColor.CGColor;
    self.clipsToBounds = YES;
    
    // 当前日期相关
    _currentDateStr = nil;
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [_formatter setDateFormat:@"yyyy-MM-dd"];
    
    // 获取当天可选时间段数据
    [self refreshAllDaysArr];
    
    // 初始化界面
    _btnArr = @[_btn1,_btn2,_btn3,_btn4,_btn5,_btn6,_btn7,_btn8,_btn9,_btn10,_btn11,_btn12];
    [self setTimeBtnUI];
    [self refreshTimeBtnEnable];
    [self refrshLastAndNextBtnEnable];
    [self refreshTitleLable];
    
}

/** 设置每个按钮Disabled状态的标题颜色和背景图片 */
- (void)setTimeBtnUI {
    for (UIButton *btn in _btnArr) {
        [btn setTitleColor:mTitleColorDisabled forState:UIControlStateDisabled];
        [btn setBackgroundImage:[self createImageWithColor:mBgColorDisabled] forState:UIControlStateDisabled];
    }
}

/** 获取当天可选时间段数据 */
- (void)refreshAllDaysArr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HHmm";
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    // 获取当天可选时间段数据
    NSInteger timeInt = dateStr.integerValue;
    NSMutableArray *arr = [NSMutableArray array];
    if (timeInt >= 830)  { [arr addObject:@"0"]; } else { [arr addObject:@"1"]; };
    if (timeInt >= 900)  { [arr addObject:@"0"]; } else { [arr addObject:@"1"]; };
    if (timeInt >= 930)  { [arr addObject:@"0"]; } else { [arr addObject:@"1"]; };
    if (timeInt >= 1000) { [arr addObject:@"0"]; } else { [arr addObject:@"1"]; };
    if (timeInt >= 1030) { [arr addObject:@"0"]; } else { [arr addObject:@"1"]; };
    if (timeInt >= 1200) { [arr addObject:@"0"]; } else { [arr addObject:@"1"]; };
    
    if (timeInt >= 1230) { [arr addObject:@"0"]; } else { [arr addObject:@"1"]; };
    if (timeInt >= 1330) { [arr addObject:@"0"]; } else { [arr addObject:@"1"]; };
    if (timeInt >= 1430) { [arr addObject:@"0"]; } else { [arr addObject:@"1"]; };
    if (timeInt >= 1530) { [arr addObject:@"0"]; } else { [arr addObject:@"1"]; };
    if (timeInt >= 1630) { [arr addObject:@"0"]; } else { [arr addObject:@"1"]; };
    if (timeInt >= 1830) { [arr addObject:@"0"]; } else { [arr addObject:@"1"]; };
   
    // 替换数据
    self.allDaysArr[0] = arr;
    self.isShowingArr = self.allDaysArr[0];
}

#pragma mark 功能方法

/** 显示 */
- (void)show {
    [self checkSelectedButton];
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bgView.hidden = NO;
        
        CGPoint center = self.center;
        center.x = mScreenWidth / 2;
        self.center = center;
    } completion:nil];
}

/** 隐藏 */
- (void)hide {
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:0 animations:^{
        self.bgView.hidden = YES;
        
        CGPoint center = self.center;
        center.x = mScreenWidth / 2 + mScreenWidth;
        self.center = center;
    } completion:nil];
}

#pragma mark 点击事件

/** tip： MVC思想 1、数据决定界面的展示内容  2、如果要刷新界面，必须先修改数据，再调用刷新界面的方法。 */

/** 上一天 */
- (IBAction)lastDay:(id)sender {
    // 1、改变数据
    self.index --;
    self.isShowingArr = self.allDaysArr[self.index];
    // 2、刷新界面
    [self refreshTimeBtnEnable];
    [self refrshLastAndNextBtnEnable];
    [self refreshTitleLable];
}

/** 下一天 */
- (IBAction)nextDay:(id)sender {
    // 1、改变数据
    self.index ++;
    self.isShowingArr = self.allDaysArr[self.index];
    // 2、刷新界面
    [self refreshTimeBtnEnable];
    [self refrshLastAndNextBtnEnable];
    [self refreshTitleLable];
}

/** 时间按钮点击时间 */
- (IBAction)timeButtonClick:(UIButton *)sender {
    // 重置上一次选择的按钮的UI
    if (_selectedButton) {
        [_selectedButton setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_selectedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    // 记录用户选择的数据，再次选择时特殊显示
    _selectedIndex = _index;
    _selectedButton = sender;
    
    if (self.okBtnClickBlock) { // 返回    时间     和      日期
        self.okBtnClickBlock(sender.titleLabel.text,self.titleLable.text);
    }
}

#pragma mark 私有方法

/** 刷新标题Lable */
- (void)refreshTitleLable {
    self.currentDateStr = [_formatter stringFromDate:[self getCurrentDate]];
    self.titleLable.text = [NSString stringWithFormat:@"%@  %@",self.currentDateStr,[self getCurrentWeekDay]];
}

/** 刷新 上一天/下一天 按钮的enable状态 */
- (void)refrshLastAndNextBtnEnable {
    self.lastDayBtn.enabled = self.index > 0 ? YES : NO;
    self.nextDayBtn.enabled = self.index < (self.allDaysArr.count - 1) ? YES : NO;
}

/** 刷新每个按钮的enable状态 */
- (void)refreshTimeBtnEnable {
    UIButton *btn;
    for (NSInteger i = 0; i < _btnArr.count; i++) {
       btn = _btnArr[i];
       btn.enabled = [self.isShowingArr[i] isEqualToString:@"1"] ? YES : NO;
    }
    [self checkSelectedButton];
}

/** 检测是否有选中过的按钮，有则特殊显示出来 */
- (void)checkSelectedButton {
    if (_selectedButton) {
        if ( _selectedIndex == _index) {
            UIColor *bgColor = [UIColor colorWithRed:92 / 255.0 green:217 / 255.0 blue:95 / 255.0 alpha:1.0];
            [_selectedButton setBackgroundImage:[self createImageWithColor:bgColor] forState:UIControlStateNormal];
            [_selectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            [_selectedButton setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            [_selectedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}

/** 根据当前的时间currentDateStr,计算星期几 */
- (NSString *)getCurrentWeekDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *weekComp = [calendar components:NSCalendarUnitWeekday fromDate:[self getCurrentDate]];
    NSInteger weekDayEnum = [weekComp weekday];
    
    NSString *weekDays = nil;
    switch (weekDayEnum) {
        case 1: weekDays = @"星期日"; break;
        case 2: weekDays = @"星期一"; break;
        case 3: weekDays = @"星期二"; break;
        case 4: weekDays = @"星期三"; break;
        case 5: weekDays = @"星期四"; break;
        case 6: weekDays = @"星期五"; break;
        case 7: weekDays = @"星期六"; break;
        default: break;
    }
    return weekDays;
}

/** 根据index，计算当前需要展示的日期 */
- (NSDate *)getCurrentDate {
    return [NSDate dateWithTimeInterval:((60*60*24) * self.index) sinceDate:[NSDate date]];
}

/** 用颜色生成一张图片 */
- (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


/** tip: 带去使用时，记得拿走Assets.xcassets里的四张图片 */

@end
