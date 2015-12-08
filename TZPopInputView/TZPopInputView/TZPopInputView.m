//
//  TZPopInputView.m
//  ZM_MiniSupply
//
//  Created by 谭真 on 15/11/19.
//  Copyright © 2015年 上海千叶网络科技有限公司. All rights reserved.
//  自定义输入框

#import "TZPopInputView.h"

#define mScreenWidth   ([UIScreen mainScreen].bounds.size.width)
#define mScreenHeight  ([UIScreen mainScreen].bounds.size.height)
#define mBlueColor [UIColor colorWithRed:50.0/255.0 green:162.0/255.0 blue:248.0/255.0 alpha:1.0]
#define mGrayColor [UIColor colorWithRed:165/255.0 green:165/255.0 blue:165/255.0 alpha:1.0]

@interface TZPopInputView ()<UITextFieldDelegate>
@property (nonatomic, strong) UIView *bgView;

/** 标题背景View */
@property (weak, nonatomic) IBOutlet UIView *titleView;

/** 第一个输入View */
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UILabel *lable1;
/** 第二个输入View */
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UILabel *lable2;
/** 第三个输入View */
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UILabel *lable3;

@end

@implementation TZPopInputView

#pragma mark 配置视图

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"TZPopInputView" owner:self options:nil] lastObject];
        // 初始化设置
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        self.frame = CGRectMake(20 + mScreenWidth, 100, mScreenWidth - 40, 320);
        [window addSubview:self.bgView];
        [window addSubview:self];
        
        // 监听键盘改变的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        // 监听文本框输入改变的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextFieldText) name:UITextFieldTextDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextFieldText) name:UITextFieldTextDidBeginEditingNotification object:nil];
    }
    return self;
}

- (void)awakeFromNib {
    // 一次性的设置
    self.titleView.backgroundColor = mBlueColor;
    [self.okButton setBackgroundColor:mBlueColor];
    
    self.okButton.layer.cornerRadius = 2;
    self.okButton.clipsToBounds = YES;
    
    self.layer.cornerRadius = 4;
    self.clipsToBounds = YES;
    
    self.textFiled1.delegate = self;
    self.textFiled2.delegate = self;
    self.textFiled3.delegate = self;
    
    [self.okButton setBackgroundImage:[self createImageWithColor:mGrayColor] forState:UIControlStateDisabled];
    self.okButton.enabled = NO;
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

/** 设置三个提示lable的值 */
- (void)setItems:(NSArray *)items {
    _items = items;
    if (items.count > 0) { self.lable1.text = items[0]; }
    if (items.count > 1) { self.lable2.text = items[1]; }
    if (items.count > 2) { self.lable3.text = items[2]; }
    
    self.view2.hidden = items.count > 1 ? NO : YES;
    self.view3.hidden = items.count > 2 ? NO : YES;
    
    self.textFiled1.returnKeyType = items.count <= 1 ? UIReturnKeyDone : UIReturnKeyNext;
    self.textFiled2.returnKeyType = items.count <= 2 ? UIReturnKeyDone : UIReturnKeyNext;
    
    // 根据传进来items的个数,来设定frame
    CGRect frame = self.frame;
    frame.size.height = 110 + 70 * items.count;
    self.frame = frame;
    
    CGPoint center = self.center;
    center.y = mScreenHeight / 2;
    self.center = center;
}

/** 三个textFiled的lable */
- (void)setTextFieldItems:(NSArray *)textFieldItems {
    _textFieldItems = textFieldItems;
     // 延迟0.2秒，等View显示出来后，再激活键盘
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (textFieldItems.count > 0) { self.textFiled1.text = textFieldItems[0]; [self.textFiled2 becomeFirstResponder]; }
        if (textFieldItems.count > 1) { self.textFiled2.text = textFieldItems[1]; }
        if (textFieldItems.count > 2) { self.textFiled3.text = textFieldItems[2]; }
    });
}

/** 三个textFiled的遮罩文本 */
- (void)setPlaceholderItems:(NSArray *)placeholderItems {
    _placeholderItems = placeholderItems;
    
    // 防止设置被重置，延迟0.2秒再设置
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (placeholderItems.count > 0) { self.textFiled1.placeholder = placeholderItems[0]; }
        if (placeholderItems.count > 1) { self.textFiled2.placeholder = placeholderItems[1]; }
        if (placeholderItems.count > 2) { self.textFiled3.placeholder = placeholderItems[2]; }
    });
}

#pragma mark 功能方法

/** 显示 */
- (void)show {
    // 重置输入框
    [self resetTextFiled];
    
    // 在这里可以 根据标题的不同 加入一些特殊设置。比如：修改支付宝情况下，textFiled1不可编辑。
    self.textFiled1.enabled = [self.titleLable.text containsString:@"修改支付宝"] ? NO : YES;
    
    // 延迟0.2秒，等View显示出来后，再激活键盘
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textFiled1 becomeFirstResponder];
    });

    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bgView.hidden = NO;
        self.bgView.userInteractionEnabled = NO;
        
        CGPoint center = self.center;
        center.x = mScreenWidth / 2;
        self.center = center;
    } completion:^(BOOL finished) {
        self.bgView.userInteractionEnabled = YES;
    }];
}

/** 隐藏 */
- (void)hide {
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:0 animations:^{
        CGPoint center = self.center;
        center.x = mScreenWidth / 2 + mScreenWidth;
        self.center = center;
    } completion:^(BOOL finished) {
        self.bgView.hidden = YES;
    }];
    [self endEditing:YES];
}

/** 确认修改 */
- (IBAction)okButtonClick:(UIButton *)sender {
    // 检查数据
    if ([self checkTextFiledData] == NO) return;
    
    [self endEditing:YES];
    
    // 返回用户输入的数据
    if (self.okButtonClickBolck) {
        NSMutableArray *arr = [NSMutableArray array];
        if (self.textFiled1.text.length > 0) { [arr addObject:self.textFiled1.text];}
        if (self.textFiled2.text.length > 0) { [arr addObject:self.textFiled2.text];}
        if (self.textFiled3.text.length > 0) { [arr addObject:self.textFiled3.text];}
        
        self.okButtonClickBolck(arr);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.textFiled1) {
        if (textField.returnKeyType == UIReturnKeyNext) {
            [self.textFiled2 becomeFirstResponder];
        } else {
            [self endEditing:YES];
        }
    } else if (textField == self.textFiled2) {
        if (textField.returnKeyType == UIReturnKeyNext) {
            [self.textFiled3 becomeFirstResponder];
        } else {
            [self endEditing:YES];
        }
    } else {
        [self endEditing:YES];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self checkTextFieldText];
    return YES;
}

#pragma mark 通知方法

/** 键盘frame即将改变的通知 */
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:duration animations:^{
        // 键盘下去了
        if (keyboardF.origin.y >= mScreenHeight) {
            CGPoint center = self.center;
            center.y = mScreenHeight / 2;
            self.center = center;
        // 键盘上来了
        } else {
            CGRect frame = self.frame;
            frame.origin.y = keyboardF.origin.y - frame.size.height - 2; // 2是输入框和键盘的间隙，自己调..
            self.frame = frame;
        }
    }];
}

/** 监听文本框输入改变/开始输入的通知 刷新确认按钮的enable状态 */
- (void)checkTextFieldText {
    BOOL isOkButtonEnable = YES;
    
    // 输入文本的最小长度限制
    NSInteger length1 = 0,length2 = 0,length3 = 0;
    if ([self.titleLable.text containsString:@"修改密码"]) {
        length2 = length3 = 7;
    } else if ([self.titleLable.text containsString:@"修改手机号"]) {
        length1 = 10;
    }
    
    // 确认按钮的enable状态
    if (self.textFiled1.text.length <= length1) { isOkButtonEnable = NO; }
    if (self.textFiled2.text.length <= length2 && !self.view2.hidden) { isOkButtonEnable = NO; }
    if (self.textFiled3.text.length <= length3 && !self.view3.hidden) { isOkButtonEnable = NO; }
    
    [self.okButton setTitle:@"确认修改" forState:UIControlStateDisabled];
    self.okButton.enabled = isOkButtonEnable;
}

#pragma mark 私有方法

/** 重置textFiled */
- (void)resetTextFiled {
    self.textFiled1.text = @"";
    self.textFiled2.text = @"";
    self.textFiled3.text = @"";
    
    self.textFiled1.placeholder = @"";
    self.textFiled2.placeholder = @"";
    self.textFiled3.placeholder = @"";
    
    self.textFiled1.keyboardType = UIKeyboardTypeDefault;
    self.textFiled2.keyboardType = UIKeyboardTypeDefault;
    self.textFiled3.keyboardType = UIKeyboardTypeDefault;
}

/** 检查用户的输入 */
- (BOOL)checkTextFiledData {
    // 根据标题的不同，分别做不同的数据检查 用按钮的title做用户提示
    if ([self.titleLable.text isEqualToString:@"修改密码"]) {
        // 检测两次密码是否输入正确
        if (![self.textFiled2.text isEqualToString:self.textFiled3.text]) {
            [self.okButton setTitle:@"两次密码输入不一致" forState:UIControlStateDisabled];
            self.okButton.enabled = NO;
            return NO;
        }
    } else if ([self.titleLable.text isEqualToString:@"修改支付宝账号"]) {
        // 检测是否是邮箱或手机号
        if (![self isEmail:self.textFiled2.text] && ![self isPhoneNumber:self.textFiled2.text]) {
            [self.okButton setTitle:@"支付宝账号格式不正确" forState:UIControlStateDisabled];
            self.okButton.enabled = NO;
            return NO;
        }
    } else if ([self.titleLable.text isEqualToString:@"修改手机号"]) {
        // 检测是否是手机号
        if (![self isPhoneNumber:self.textFiled1.text]) {
            [self.okButton setTitle:@"手机号格式不正确" forState:UIControlStateDisabled];
            self.okButton.enabled = NO;
            return NO;
        }
    }
    return YES;
}

/** 该字符串是否是邮箱 */
- (BOOL)isEmail:(NSString *)str {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:str];
}

/** 该字符串是否是手机号 */
- (BOOL)isPhoneNumber:(NSString *)str {
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    NSString * CU = @"^1(3[0-2]|5[256]|8[156])\\d{8}$";
    NSString * CT = @"^1((33|53|8|7[09])[0-9]|349)\\d{7}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    BOOL res1 = [regextestmobile evaluateWithObject:str];
    BOOL res2 = [regextestcm evaluateWithObject:str];
    BOOL res3 = [regextestcu evaluateWithObject:str];
    BOOL res4 = [regextestct evaluateWithObject:str];
    
    if (res1 || res2 || res3 || res4 ) {
        return YES;
    } else {
        return NO;
    }
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

@end

