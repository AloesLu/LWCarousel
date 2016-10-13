//
//  LWCarousel.h
//  vomoho
//
//  Created by AloesLu on 16/4/22.
//  Copyright © 2016年 AloesLu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^imageClickBlock)(NSInteger index);

@interface LWCarousel : UIView

//轮播的ScrollView
@property(strong,nonatomic) UIScrollView *direct;
//轮播的页码
@property(strong,nonatomic) UIPageControl *pageVC;
//轮播滚动时间间隔
@property(assign,nonatomic) CGFloat time;

/**
 *  开始定时器
 */
-(void)beginTimer;
/**
 *  销毁定时器
 */
-(void)stopTimer;

/**
 *  初始化图片轮播
 *
 *  @param frame          frame大小
 *  @param imageNameArray 图片数组
 *  @param isCycle        是否循环轮播
 *  @param clickBlock     点击事件
 *
 *  @return 轮播实例对象
 */
+(instancetype)carouselWithtFrame:(CGRect)frame ImageArr:(NSArray *)imageNameArray isCycle:(BOOL)isCycle AndImageClickBlock:(imageClickBlock)clickBlock;

/**
 *  初始化自定义View轮播，无需循环
 *
 *  @param frame         frame大小
 *  @param customViewArr view数组
 *  @param isCycle       是否循环轮播
 *  @param isNeedBounds  是否需要不完全展示
 *  @param clickBlock    点击事件
 *
 *  @return 轮播实例对象
 */
+(instancetype)carouselWithtFrame:(CGRect)frame ViewArr:(NSArray *)customViewArr isCycle:(BOOL)isCycle isNeedBounds:(BOOL)isNeedBounds AndClickBlock:(imageClickBlock)clickBlock;
@end
