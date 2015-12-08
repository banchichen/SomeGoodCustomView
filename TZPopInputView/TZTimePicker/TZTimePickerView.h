//
//  TZTimePickerView.h
//
//  Created by 谭真 on 15/11/4.
//  Copyright © 2015年 memberwine. All rights reserved.
//  时间选择器（选择某个时间段）

#import <UIKit/UIKit.h>

@interface TZTimePickerView : UIView

/** 显示 */
- (void)show;
/** 隐藏 */
- (void)hide;

/** 选择好时间后的 回调block */
@property (nonatomic, copy) void (^okBtnClickBlock)(NSString *,NSString *);
/** 所有天数里 时间段是否可预约的大数组 */
@property (nonatomic, copy) NSMutableArray *allDaysArr;

@end
