//
//  LYMTagListView.h
//  Jerry
//
//  Created by Jerry on 5/6/15.
//  Copyright (c) 2016 innogeek. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LYMTagListView;

typedef NS_ENUM(NSUInteger, LYMTagListViewAlignment) {
    LYMTagListViewAlignmentLeft = 1,
    LYMTagListViewAlignmentCenter,
    LYMTagListViewAlignmentRight,
};

@protocol LYMTagListViewDelegate <NSObject>

@optional
- (void)tagListView:(LYMTagListView * _Nonnull)tagListView didTapLabel:(UILabel * _Nonnull)tappedLabel index:(uint64_t)index;

@end

@interface LYMTagListView : UIView

@property (nonatomic, weak) id<LYMTagListViewDelegate> _Nullable delegate;

@property (nonatomic) CGFloat listViewVMargin;
@property (nonatomic) CGFloat listViewHMargin; //标签容器与listView中的边距
@property (nonatomic) CGFloat tagHSpace;
@property (nonatomic) CGFloat tagVSpace; //标签与标签之间的距离
@property (nonatomic) CGFloat tagHInset; //每个label在每个标签容器中的水平缩进
@property (nonatomic) CGFloat tagHeight;
@property (nonatomic) CGFloat tagWidth; //如果设置了tagWidth为非0值，则强制按照给定的tagWidth排列布局
@property (nonatomic) NSTextAlignment tagTextAlignment; //tag内文本排列方式。默认为居中
@property (nonatomic, strong) UIFont  * _Nonnull tagFont;
@property (nonatomic, strong) UIColor * _Nonnull tagBorderColor;
@property (nonatomic, strong) UIColor * _Nonnull tagTextColor;
@property (nonatomic, strong) UIColor * _Nonnull tagBgColor;


/**
 *  传入的frame，只有height会根据item做自适配，其他都会保持传入值不变。
 */
- (instancetype _Nonnull)initWithFrame:(CGRect)frame
                             alignment:(LYMTagListViewAlignment)alignment
                          tagTextColor:(UIColor * _Nonnull)tagTextColor
                    tagBackgroundColor:(UIColor * _Nonnull)tagBgColor;

- (void)reloadUIWithStrItems:(NSArray<NSString *> * _Nonnull)strItems completion:(void(^ _Nullable)(CGRect tagListViewFrame))completion;

- (UILabel * _Nonnull)labelAtIndex:(NSInteger)index;
- (NSInteger)numOfLabels;
- (void)enumerateLabel:(void (^ _Nullable)(UILabel * _Nonnull label, NSUInteger index))block;

@end
