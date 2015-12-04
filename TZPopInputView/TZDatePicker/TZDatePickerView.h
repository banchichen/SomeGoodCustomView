//
//  TZDatePickerView.h
//  ZM_MiniSupply
//
//  Created by 谭真 on 15/11/21.
//  Copyright © 2015年 上海千叶网络科技有限公司. All rights reserved.
//  时间选择器（开始时间和结束时间）

#import <UIKit/UIKit.h>

@interface TZDatePickerView : UIView

/** 显示 */
- (void)show;
/** 隐藏 */
- (void)hide;

/** 返回用户选择的开始时间和结束时间 */
@property (nonatomic, copy) void(^gotoSrceenOrderBlock)(NSString *,NSString *);

@end
