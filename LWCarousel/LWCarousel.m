//
//  LWCarousel.m
//  vomoho
//
//  Created by AloesLu on 16/4/22.
//  Copyright © 2016年 AloesLu. All rights reserved.
//

#import "LWCarousel.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface LWCarousel()<UIScrollViewDelegate>{
    //    CGFloat _viewWidth;
}
//轮播图片名字的数组
@property(strong,nonatomic) NSArray *imageArr;
//自定义视图的数组
@property(strong,nonatomic) NSArray *viewArr;
//定时器
@property(strong,nonatomic) NSTimer *timer;
//点击图片出发Block
@property(assign,nonatomic) imageClickBlock clickBlock;


@property(assign,nonatomic) BOOL isCycle;
@property(assign,nonatomic) BOOL isNeedBounds;
@end

@implementation LWCarousel

//获取ScrollView的X值偏移量
#define contentOffSet_x self.direct.contentOffset.x
//获取ScrollView的宽度
#define frame_width self.direct.frame.size.width
//获取ScrollView的contentSize宽度
#define contentSize_x self.direct.contentSize.width

#pragma mark -========================初始化==============================

+ (instancetype)carouselWithtFrame:(CGRect)frame ViewArr:(NSArray *)customViewArr isCycle:(BOOL)isCycle isNeedBounds:(BOOL)isNeedBounds AndClickBlock:(imageClickBlock)clickBlock{
    return [[LWCarousel alloc]initWithtFrame:frame ViewArr:customViewArr isCycle:isCycle isNeedBounds:isNeedBounds AndImageClickBlock:clickBlock];
}
+ (instancetype)carouselWithtFrame:(CGRect)frame ImageArr:(NSArray *)imageNameArray isCycle:(BOOL)isCycle AndImageClickBlock:(imageClickBlock)clickBlock{
    return [[LWCarousel alloc]initWithtFrame:frame ImageArr:imageNameArray isCycle:isCycle AndImageClickBlock:clickBlock];
}
-(instancetype)initWithtFrame:(CGRect)frame ViewArr:(NSArray *)customViewArr isCycle:(BOOL)isCycle isNeedBounds:(BOOL)isNeedBounds AndImageClickBlock:(imageClickBlock)clickBlock
{
    _isNeedBounds=isNeedBounds;
    _isCycle=isCycle;
    if(isNeedBounds){
        if(self=[self initWithFrame:frame])
        {
            //设置ScrollView的contentSize
            self.direct.contentSize=CGSizeMake((customViewArr.count+4)*frame_width,0);
            self.direct.contentOffset=CGPointMake(frame_width*2, 0);
            
            self.pageVC.numberOfPages=customViewArr.count;
            
            self.viewArr=customViewArr;
            
            //设置图片点击的Block
            self.clickBlock=clickBlock;
        }
    }else if(isCycle){
        if(self=[self initWithFrame:frame])
        {
            //设置ScrollView的contentSize
            self.direct.contentSize=CGSizeMake((customViewArr.count+2)*frame_width,0);
            self.direct.contentOffset=CGPointMake(frame_width, 0);
            
            self.pageVC.numberOfPages=customViewArr.count;
            
            self.viewArr=customViewArr;
            
            //设置图片点击的Block
            self.clickBlock=clickBlock;
        }
    }else{
        if(self=[self initWithFrame:frame])
        {
            //设置ScrollView的contentSize
            self.direct.contentSize=CGSizeMake(customViewArr.count*frame_width,0);
            self.direct.bounces=NO;
            self.direct.contentOffset=CGPointMake(0, 0);
            
            self.pageVC.numberOfPages=customViewArr.count;
            
            self.viewArr=customViewArr;
            
            //设置图片点击的Block
            self.clickBlock=clickBlock;
        }
    }
    return self;
}
-(instancetype)initWithtFrame:(CGRect)frame ImageArr:(NSArray *)imageNameArray isCycle:(BOOL)isCycle AndImageClickBlock:(imageClickBlock)clickBlock;
{
    _isCycle=isCycle;
    if(isCycle){
        if(self=[self initWithFrame:frame])
        {
            //设置ScrollView的contentSize
            self.direct.contentSize=CGSizeMake((imageNameArray.count+2)*frame_width,0);
            self.direct.contentOffset=CGPointMake(frame_width, 0);
            
            self.pageVC.numberOfPages=imageNameArray.count;
            
            //设置滚动图片数组
            self.imageArr=imageNameArray;
            
            //设置图片点击的Block
            self.clickBlock=clickBlock;
        }
    }else{
        if(self=[self initWithFrame:frame])
        {
            //设置ScrollView的contentSize
            self.direct.contentSize=CGSizeMake(imageNameArray.count*frame_width,0);
            self.direct.bounces=NO;
            self.direct.contentOffset=CGPointMake(0, 0);
            
            self.pageVC.numberOfPages=imageNameArray.count;
            
            //设置滚动图片数组
            self.imageArr=imageNameArray;
            
            //设置图片点击的Block
            self.clickBlock=clickBlock;
        }
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame])
    {
        //初始化轮播ScrollView
        self.direct=[[UIScrollView alloc]init];
        self.direct.delegate=self;
        self.direct.pagingEnabled=YES;
        self.direct.frame=self.bounds;
        self.direct.clipsToBounds=NO;
        
        self.direct.showsHorizontalScrollIndicator=NO;
        [self addSubview:self.direct];
        
        //初始化轮播页码控件
        self.pageVC=[[UIPageControl alloc]init];
        //设置轮播页码的位置
        self.pageVC.frame=CGRectMake(0,kScreen_Width-20, kScreen_Width, 20);
        self.pageVC.pageIndicatorTintColor=[UIColor colorWithWhite:1.0 alpha:0.5];
        self.pageVC.currentPageIndicatorTintColor=kMainColor;
        [self addSubview:self.pageVC];
        
        self.time=1.5;
    }
    return self;
}

#pragma mark-===========================定时器===============================

#pragma mark 初始化定时器
-(void)beginTimer
{
    if(self.timer==nil)
    {
        self.timer =[NSTimer scheduledTimerWithTimeInterval:self.time target:self selector:@selector(timerSel) userInfo:nil repeats:YES];
    }
}
#pragma mark 摧毁定时器
-(void)stopTimer
{
    [self.timer invalidate];
    self.timer=nil;
}

#pragma mark 定时器调用的方法
-(void)timerSel
{
    //获取并且计算当前页码
    CGPoint currentConOffSet=self.direct.contentOffset;
    currentConOffSet.x+=frame_width;
    
    //动画改变当前页码
    [UIView animateWithDuration:0.5 animations:^{
        self.direct.contentOffset=currentConOffSet;
    }completion:^(BOOL finished) {
        [self updataWhenFirstOrLast];
    }];
}

#pragma mark-========================UIScrollViewDelegate=====================
#pragma mark 开始拖拽代理
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    [self stopTimer];
}

#pragma mark 结束拖拽代理
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self updataWhenFirstOrLast];
//    [self beginTimer];
}

#pragma mark 结束滚动代理
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //当最后或者最前一张图片时改变坐标
    [self updataWhenFirstOrLast];
}

#pragma mark-=====================轮播页码改变=====================

#pragma mark 更新PageControl
-(void)updataPageControl
{
    NSInteger index=0;
    if(_isNeedBounds){
        index=(contentOffSet_x-frame_width*2)/frame_width;
    }else if(_isCycle){
        index=(contentOffSet_x-frame_width)/frame_width;
    }else{
        index=contentOffSet_x/frame_width;
    }
    self.pageVC.currentPage=index;
}

#pragma mark 判断是否第一或者最后一个图片,改变坐标
-(void)updataWhenFirstOrLast
{
    if(_isNeedBounds){
        //当图片移动到最后第二张时，动画结束移动到第三张图片的位置
        if(contentOffSet_x>=contentSize_x-frame_width*2)
        {
            self.direct.contentOffset=CGPointMake(frame_width*2, 0);
        }
        //当图片移动到第二张时，动画结束移动到倒数第三张的位置
        else if (contentOffSet_x<=frame_width)
        {
            self.direct.contentOffset=CGPointMake(contentSize_x-3*frame_width, 0);
        }
    }else if(_isCycle){
        //当图片移动到最后一张时，动画结束移动到第二张图片的位置
        if(contentOffSet_x>=contentSize_x-frame_width)
        {
            self.direct.contentOffset=CGPointMake(frame_width, 0);
        }
        //当图片移动到第一张时，动画结束移动到倒数第二张的位置
        else if (contentOffSet_x<=0)
        {
            self.direct.contentOffset=CGPointMake(contentSize_x-2*frame_width, 0);
        }
    }
    
    //更新PageControl
    [self updataPageControl];
}

#pragma mark -=====================其他一些方法===================

#pragma mark轮播定时器时间
-(void)setTime:(CGFloat)time
{
    if(time>0)
    {
        _time=time;
        [self stopTimer];
//        [self beginTimer];
    }
}
#pragma mark 重写图片名字的数组
-(void)setImageArr:(NSArray *)imageArr
{
    _imageArr=imageArr;
    
    [self addImageToScrollView];
    
//    [self beginTimer];
}
#pragma mark 重写自定义视图的数组
-(void)setViewArr:(NSArray *)viewArr
{
    _viewArr=viewArr;
    
    if(_isNeedBounds){
        [self addCustomViewToScrollViewNeedBounds];
    }else if(_isCycle){
        [self addCustomViewToScrollViewCycle];
    }else{
        [self addCustomViewToScrollView];
    }
    
//    [self beginTimer];
}

#pragma mark 图片点击事件
-(void)imageClick:(UITapGestureRecognizer *)tap
{
    UIView *view=tap.view;
    if(self.clickBlock)
    {
        self.clickBlock(view.tag);
    }
}

#pragma mark 根据自定义视图添加到ScrollView
-(void)addCustomViewToScrollViewNeedBounds
{
    //初始化一个可变数组
    NSMutableArray *imgMArr=[NSMutableArray arrayWithArray:self.viewArr];
    
    //序列化后反序列化View，生成一个新的对象
    UIView *lastView=[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:[self.viewArr lastObject]]];
    
    //将无法序列化和反序列化的Image进行递归，并且赋值到新VIEW上
//    [self imageCopy:[self.viewArr lastObject] To:lastView];
    
    //添加新对象到可变数组
    [imgMArr insertObject:lastView atIndex:0];
    
    if(self.viewArr.count==1){
        UIView *lastlastView=[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:[self.viewArr lastObject]]];
        [imgMArr insertObject:lastlastView atIndex:0];
    }else if(self.viewArr.count>1){
        UIView *lastlastView=[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:[self.viewArr objectAtIndex:self.viewArr.count-2]]];
        [imgMArr insertObject:lastlastView atIndex:0];
    }
    
    //序列化后反序列化View，生成一个新的对象
    UIView *firstView=[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:[self.viewArr firstObject]]];
    
    //将无法序列化和反序列化的Image进行递归，并且赋值到新VIEW上
//    [self imageCopy:[self.viewArr firstObject] To:firstView];
    
    //添加新对象到可变数组
    [imgMArr addObject:firstView];
    
    if(self.viewArr.count==1){
        UIView *firstfirstView=[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:[self.viewArr firstObject]]];
        [imgMArr addObject:firstfirstView];
    }else if(self.viewArr.count>1){
        UIView *firstfirstView=[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:[self.viewArr objectAtIndex:1]]];
        [imgMArr addObject:firstfirstView];
    }
    
    NSInteger tag=-1;
    for (UIView *customView in imgMArr) {
        customView.frame=CGRectMake(frame_width*(tag+1), 0, frame_width, self.frame.size.height);
        //设置tag
        customView.tag=tag;
        tag++;
        //添加手势
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
        [customView addGestureRecognizer:tap];
        
        //开启用户交互
        customView.userInteractionEnabled=YES;
        [self.direct addSubview:customView];
    }
}

-(void)addCustomViewToScrollViewCycle
{
    //初始化一个可变数组
    NSMutableArray *imgMArr=[NSMutableArray arrayWithArray:self.viewArr];
    
    //序列化后反序列化View，生成一个新的对象
    UIView *lastView=[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:[self.viewArr lastObject]]];
    
    //将无法序列化和反序列化的Image进行递归，并且赋值到新VIEW上
//    [self imageCopy:[self.viewArr lastObject] To:lastView];
    
    //添加新对象到可变数组
    [imgMArr insertObject:lastView atIndex:0];
    
    //序列化后反序列化View，生成一个新的对象
    UIView *firstView=[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:[self.viewArr firstObject]]];
    
    //将无法序列化和反序列化的Image进行递归，并且赋值到新VIEW上
//    [self imageCopy:[self.viewArr firstObject] To:firstView];
    
    //添加新对象到可变数组
    [imgMArr addObject:firstView];
    
    NSInteger tag=-1;
    for (UIView *customView in imgMArr) {

        customView.frame=CGRectMake(self.frame.size.width*(tag+1), 0, self.frame.size.width, self.frame.size.height);
        //设置tag
        customView.tag=tag;
        tag++;
        
        //添加手势
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
        [customView addGestureRecognizer:tap];
        
        //开启用户交互
        customView.userInteractionEnabled=YES;
        [self.direct addSubview:customView];
    }
}

-(void)addCustomViewToScrollView
{
    //初始化一个可变数组
    NSMutableArray *imgMArr=[NSMutableArray arrayWithArray:self.viewArr];
    
    NSInteger tag=0;
    for (UIView *customView in imgMArr) {
        customView.frame=CGRectMake(self.frame.size.width*tag, 0, self.frame.size.width, self.frame.size.height);
        //设置tag
        customView.tag=tag;
        tag++;
        
        //添加手势
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
        [customView addGestureRecognizer:tap];
        
        //开启用户交互
        customView.userInteractionEnabled=YES;
        [self.direct addSubview:customView];
    }
}
#pragma mark 根据图片名添加图片到ScrollView
-(void)addImageToScrollView
{
    //创建一个可变数组
    NSMutableArray *imgMArr=[NSMutableArray arrayWithArray:self.imageArr];
    //添加第一个和最后一个对象到对应可变数组的最后一个位置和第一个位置
    [imgMArr insertObject:[self.imageArr lastObject] atIndex:0];
    [imgMArr addObject:[self.imageArr firstObject]];
    
    NSInteger tag=-1;
    for (NSString *name in imgMArr) {
        
        //将传进来的图片名在本地初始化
        UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:name]];
        imgView.contentMode=UIViewContentModeScaleAspectFill;
        imgView.layer.masksToBounds=YES;
        //如果本地没有这张图片进行网络请求
        if(imgView.image ==nil)
        {
            NSRange num=[name rangeOfString:@"vomoho"];
            if(!num.length){
                if (SDKVersion10) {
                    NSString *assetLocal=name;
                    NSArray *assetLocalArray = [NSArray arrayWithObject:assetLocal];
                    PHFetchResult *results = [PHAsset fetchAssetsWithLocalIdentifiers:assetLocalArray options:nil];
                    PHAsset *asset = [results objectAtIndex:0];
                    
                    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
                    imageOptions.synchronous = YES;
                    imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                    imageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
                    
                    __block UIImage *copyOfOriginalImage;
                    PHImageManager *imageManager = [PHImageManager defaultManager];
                    [imageManager requestImageDataForAsset:asset options:imageOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                        copyOfOriginalImage = [UIImage imageWithData:imageData];
                    }];
                    imgView.image=copyOfOriginalImage;
                } else {
                    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                    [library assetForURL:[NSURL URLWithString:name] resultBlock:^(ALAsset *asset){
                        UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:0.5 orientation:UIImageOrientationUp];
                        imgView.image=copyOfOriginalImage;
                    }failureBlock:^(NSError *error){
                        
                    }];
                }
            }else{
                //下载网络图赋值
            }
        }
        //设置图片的坐标
        imgView.frame=CGRectMake(self.frame.size.width*(tag+1), 0, self.frame.size.width, self.frame.size.height);
        
        //设置tag
        imgView.tag=tag;
        tag++;
        
        //添加手势
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageActivityClick:)];
        [imgView addGestureRecognizer:tap];
        //开启用户交互
        imgView.userInteractionEnabled=YES;
        [self.direct addSubview:imgView];
    }
}
-(void)imageActivityClick:(UITapGestureRecognizer *)tap
{
    UIView *view=tap.view;
    NSString *name=[self.imageArr objectAtIndex:view.tag];
    NSRange num=[name rangeOfString:@"vomoho"];
    if(!num.length){
        if (SDKVersion10) {
            NSString *assetLocal=name;
            NSArray *assetLocalArray = [NSArray arrayWithObject:assetLocal];
            PHFetchResult *results = [PHAsset fetchAssetsWithLocalIdentifiers:assetLocalArray options:nil];
            PHAsset *asset = [results objectAtIndex:0];
            
            PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
            imageOptions.synchronous = YES;
            imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            imageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
            
            __block UIImage *copyOfOriginalImage;
            PHImageManager *imageManager = [PHImageManager defaultManager];
            [imageManager requestImageDataForAsset:asset options:imageOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                copyOfOriginalImage = [UIImage imageWithData:imageData];
            }];
            UIImageView *imgView=[[UIImageView alloc]initWithImage:copyOfOriginalImage];
            NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithCapacity:1];
            [dict setObject:imgView forKey:[NSNumber numberWithInt:0]];
            //预览方法
        } else {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:[NSURL URLWithString:name] resultBlock:^(ALAsset *asset){
                UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:0.5 orientation:UIImageOrientationUp];
                UIImageView *imgView=[[UIImageView alloc]initWithImage:copyOfOriginalImage];
                NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithCapacity:1];
                [dict setObject:imgView forKey:[NSNumber numberWithInt:0]];
                //预览方法
            }failureBlock:^(NSError *error){
                
            }];
        }
    }else{
        NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithCapacity:1];
        [dict setObject:name forKey:[NSNumber numberWithInt:0]];
        //预览方法
    }
}

#pragma mark 递归图片
/**
 *参数1：被拷贝的UIView
 *参数2：新拷贝的UIView
 */
-(void)imageCopy:(id)obj To:(id)obj2
{
    //图片无法在序列化和反序列化中被重新生成，因此判断为图片类型时为新对象IMAGE赋值
    if([obj isKindOfClass:[UIImageView class]])
    {
        ((UIImageView *)obj2).image=((UIImageView *)obj).image;
    }
    
    //遍历子对象中是否包含UIImageView类型
    if([obj isKindOfClass:[UIView class]])
    {
        UIView *view=(UIView *)obj;
        UIView *view2=(UIView *)obj2;
        for(int i=0;i<view.subviews.count;i++)
        {
            //递归操作
            [self imageCopy:view.subviews[i] To:view2.subviews[i]];
        }
    }
}
@end
