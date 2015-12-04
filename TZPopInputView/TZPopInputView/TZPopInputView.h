//
//  TZPopInputView.h
//  ZM_MiniSupply
//
//  Created by 谭真 on 15/11/19.
//  Copyright © 2015年 上海千叶网络科技有限公司. All rights reserved.
//  自定义输入框

#import <UIKit/UIKit.h>

@interface TZPopInputView : UIView

/** 显示 */
- (void)show;
/** 隐藏 */
- (void)hide;

/** 三个textFiled 放在.h里，方便从外界更改键盘样式 */
@property (weak, nonatomic) IBOutlet UITextField *textFiled1;
@property (weak, nonatomic) IBOutlet UITextField *textFiled2;
@property (weak, nonatomic) IBOutlet UITextField *textFiled3;
/** 确认按钮 也放在.h里，方便从外界做特殊的数据判读处理，限制用户的输入 */
@property (weak, nonatomic) IBOutlet UIButton *okButton;

/** 标题文本 */
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
/** 输入框的提示文本 输入框的个数,由items数组的个数动态确定 */
@property (nonatomic, copy) NSArray *items;
/** 输入框的预设文本 */
@property (nonatomic, copy) NSArray *textFieldItems;
/** 输入框的占位文本 */
@property (nonatomic, copy) NSArray *placeholderItems;

/** 确认按钮点击的block */
@property (nonatomic, copy) void(^okButtonClickBolck)(NSMutableArray *items);

@end
