//
//  LYMTagListView.m
//  Jerry
//
//  Created by Jerry on 5/6/15.
//  Copyright (c) 2016 innogeek. All rights reserved.
//

#import "LYMTagListView.h"


@interface TagListModel : NSObject

@property (nonatomic, strong) NSString * strItem;
@property (nonatomic, strong) NSValue  * cgframeValue;
@property (nonatomic        ) int      lineNum;//从0开始

@end

@implementation TagListModel

@end




@interface LYMTagListView ()

@property (nonatomic, strong) NSArray        * strItems;
@property (nonatomic, strong) NSMutableArray * labelFrameValues;
@property (nonatomic, strong) NSMutableArray * labelMuArray;
@property (nonatomic, strong) NSMutableDictionary   * attr;

@property (nonatomic) LYMTagListViewAlignment alignment;
@property (nonatomic) BOOL                 isEnableUserInteraction;

@end

@implementation LYMTagListView

- (instancetype)initWithFrame:(CGRect)frame
                    alignment:(LYMTagListViewAlignment)alignment
                 tagTextColor:(UIColor *)tagTextColor
           tagBackgroundColor:(UIColor *)tagBgColor {
    self = [super initWithFrame:frame];
    if (self) {
        self.strItems = @[];
        self.labelFrameValues = [NSMutableArray arrayWithCapacity:10];
        if (tagBgColor == nil) {
            self.tagBgColor = [UIColor clearColor];
        } else {
            self.tagBgColor = tagBgColor;
        }

        self.labelMuArray = [NSMutableArray array];
        self.alignment = alignment;
        self.listViewVMargin = 3.0;
        self.listViewHMargin = 3.0;
        self.tagHSpace       = self.listViewHMargin;
        self.tagVSpace       = self.listViewVMargin;
        self.tagHInset       = 3.0;
        self.tagHeight     = 24.0;
        self.tagFont       = [UIFont systemFontOfSize:15.0];
        self.tagBorderColor  = [UIColor clearColor];
        self.tagTextAlignment = NSTextAlignmentCenter;
        
        NSMutableDictionary * attr = [@{NSFontAttributeName:self.tagFont} mutableCopy];
        if (tagTextColor == nil) {
            self.tagTextColor = [UIColor darkGrayColor];
        } else {
            self.tagTextColor = tagTextColor;
        }
        [attr setValue:self.tagTextColor forKey:NSForegroundColorAttributeName];
        self.attr = attr;
        
        [self reloadUIWithStrItems:self.strItems completion:^(CGRect tagListViewFrame) {
            self.frame = tagListViewFrame;
        }];
    }
    return self;
}

- (void)setTagTextColor:(UIColor *)tagTextColor {
    _tagTextColor = tagTextColor;
    [self.attr setValue:_tagTextColor forKey:NSForegroundColorAttributeName];
}

- (void)setTagFont:(UIFont *)tagFont {
    _tagFont = tagFont;
    [self.attr setValue:_tagFont forKey:NSFontAttributeName];
}

- (void)setDelegate:(id<LYMTagListViewDelegate>)delegate {
    _delegate = delegate;
    if (delegate) {
        self.isEnableUserInteraction = YES;
    } else {
        self.isEnableUserInteraction = NO;
    }
}

- (void)reloadUIWithStrItems:(NSArray<NSString *> *)strItems completion:(void (^)(CGRect))completion {
    [self.labelMuArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.labelMuArray removeAllObjects];
    [self.labelFrameValues removeAllObjects];
    self.strItems = strItems;
    
    //初始化临时变量
    CGFloat maxOneLineWidth = self.frame.size.width - self.listViewHMargin * 2;
    CGFloat x = self.listViewHMargin;
    CGFloat y = self.listViewVMargin;
    CGFloat widthRest = maxOneLineWidth;
    int lineNum = 0;
    for (int i = 0; i < strItems.count; i ++) {
        //计算当前str的宽度
        NSString * oneStr = [strItems objectAtIndex:i];
        if (oneStr == nil) {
            continue;
        }
        CGFloat strWidth = self.tagWidth;
        if (strWidth == 0.0) {
            //如果没给定tagWidth，则自动计算
            strWidth = [oneStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.tagHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_tagFont} context:nil].size.width + self.tagHInset * 2;
        }
        TagListModel * model = [[TagListModel alloc] init];
        model.strItem = oneStr;
        //计算得到label的frame
        CGRect labelFrame;
        //判断当前行剩余空间是否足够放下oneStr
        if (widthRest - strWidth >= 0) {
            //够，在当前行继续摆放
        } else {
            //不够，缩小宽度到行宽度最大值
            if (strWidth > maxOneLineWidth) {
                strWidth = maxOneLineWidth;
            }
            //首行不换行
            if (i == 0) {
                widthRest = 0.0;
            } else {
                //不够，非首行则新起一行
                lineNum ++;
                widthRest = maxOneLineWidth;
                x = self.listViewHMargin;
                y += self.tagVSpace + self.tagHeight;
            }
        }
        //行号保存
        model.lineNum = lineNum;
        //frame生成
        labelFrame = CGRectMake(x, y, strWidth, self.tagHeight);
        model.cgframeValue = [NSValue valueWithCGRect:labelFrame];
        [self.labelFrameValues addObject:model];
        //递进x
        x += strWidth + self.tagHSpace;
        //本行剩余空间更新(maxOneLineWidth中已经减过listViewHMargin，对x作差，多减了一次listViewHMargin)
        widthRest = maxOneLineWidth - x + self.listViewHMargin;
    }
    y += self.tagHeight + self.listViewVMargin;
    CGRect frame = self.frame;
    frame.size.height = y;
    self.frame = frame;
    [self reloadUI];
    if (completion) {
        completion(self.frame);
    }
}

- (void)reloadUI {
    if (self.labelFrameValues.count == 0) {
        return ;
    }
    NSMutableArray * labelArray = [NSMutableArray arrayWithCapacity:5];
    int lineNum = 0;
    for (TagListModel * model in self.labelFrameValues) {
        NSAttributedString * attrString = [[NSAttributedString alloc] initWithString:model.strItem attributes:self.attr];
        UILabel * label = [[UILabel alloc] initWithFrame:model.cgframeValue.CGRectValue];
        label.attributedText         = attrString;
        label.textAlignment          = self.tagTextAlignment;
        label.lineBreakMode          = NSLineBreakByTruncatingTail;
        label.userInteractionEnabled = self.isEnableUserInteraction;
        label.backgroundColor        = self.tagBgColor;
        label.font                   = self.tagFont;
        label.layer.masksToBounds      = YES;
        label.layer.cornerRadius       = 3.0;
        label.layer.borderColor        = [self.tagBorderColor CGColor];
        label.layer.borderWidth        = 1.0;
        label.layer.shouldRasterize    = YES;
        label.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        label.numberOfLines = 0;
        [self.labelMuArray addObject:label];
        [self addSubview:label];
        //在label上添加tap手势
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabel:)];
        [label addGestureRecognizer:tapGesture];
        //收集本行label，校验对齐
        if (model.lineNum == lineNum) {
            //本行的label
            [labelArray addObject:label];
        } else {
            //新行
            lineNum = model.lineNum;
            //对上一行的labels重排列
            [self realignLabel:labelArray];
            //清空数组
            [labelArray removeAllObjects];
            //当前label加入数组
            [labelArray addObject:label];
        }
    }
    [self realignLabel:labelArray];
}

- (void)realignLabel:(NSArray *)labelArray {
    if ([labelArray count] == 0) {
        return ;
    }
    UILabel * lastLabel = [labelArray lastObject];
    //label重排列的偏移量，向右为正
    CGFloat offset = 0.0;
    if (self.alignment == LYMTagListViewAlignmentLeft) {
        //默认就是左对齐，不用重排
        return ;
    } else if (self.alignment == LYMTagListViewAlignmentCenter) {
        offset = self.frame.size.width - self.listViewHMargin - lastLabel.frame.origin.x - lastLabel.frame.size.width;
        offset /= 2.0;
    } else if (self.alignment == LYMTagListViewAlignmentRight) {
        //右对齐
        offset = self.frame.size.width - self.listViewHMargin - lastLabel.frame.origin.x - lastLabel.frame.size.width;
    }
    for (UILabel * oneLabel in labelArray) {
        CGRect frameNew = oneLabel.frame;
        frameNew.origin.x += offset;
        oneLabel.frame = frameNew;
    }
}

#pragma mark - UITapGesture delegate
- (void)didTapLabel:(UITapGestureRecognizer *)tapGesture {
    UILabel * tappedLabel = (UILabel *) tapGesture.view;
    if ([tappedLabel isKindOfClass:[UILabel class]] == NO) {
        return ;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagListView:didTapLabel:index:)]) {
        [self.delegate tagListView:self didTapLabel:tappedLabel index:[self.labelMuArray indexOfObject:tappedLabel]];
    }
}

#pragma mark - Public methods
- (UILabel *)labelAtIndex:(NSInteger)index {
    if (self.labelMuArray.count > index) {
        return [self.labelMuArray objectAtIndex:index];
    }
    return nil;
}

- (NSInteger)numOfLabels {
    return self.labelMuArray.count;
}

- (void)enumerateLabel:(void (^)(UILabel *, NSUInteger))block{
    if (block) {
        for (NSUInteger i = 0; i < self.labelMuArray.count; i++) {
            UILabel * label = self.labelMuArray[i];
            block(label, i);
        }
    }
}

@end



