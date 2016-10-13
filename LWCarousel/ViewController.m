//
//  ViewController.m
//  LWCarousel
//
//  Created by AloesLu on 2016/10/12.
//  Copyright © 2016年 AloesLu. All rights reserved.
//

#import "ViewController.h"
#import "LWCarousel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *arry=@[@"msqb",@"qgyz",@"wdqz",@"xxss",@"ylsn"];
    LWCarousel *carouselImage=[LWCarousel carouselWithtFrame:CGRectMake(0, 0, kScreen_Width, 200) ImageArr:arry isCycle:YES AndImageClickBlock:^(NSInteger index) {
        
    }];
    [carouselImage.pageVC setFrame:CGRectMake(0,180, kScreen_Width, 20)];
    carouselImage.pageVC.pageIndicatorTintColor=kSeparatorColor;
    carouselImage.direct.scrollsToTop=NO;
    carouselImage.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:carouselImage];
    
    
    NSMutableArray *muArry=[NSMutableArray arrayWithCapacity:1];
    for (int i=0; i<4; i++) {
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width-60, 200)];
        if(i==0){
            imageView.image=[self imageWithColor:[UIColor redColor]];
        }else if(i==1){
            imageView.image=[self imageWithColor:[UIColor orangeColor]];
        }else if(i==2){
            imageView.image=[self imageWithColor:[UIColor yellowColor]];
        }else if(i==3){
            imageView.image=[self imageWithColor:[UIColor greenColor]];
        }
        [muArry addObject:imageView];
    }
    LWCarousel *carouselView=[LWCarousel carouselWithtFrame:CGRectMake(30, 230, kScreen_Width-60, 200) ViewArr:[muArry copy] isCycle:YES isNeedBounds:YES AndClickBlock:^(NSInteger index) {
        
    }];
    [carouselView.pageVC setFrame:CGRectMake(0,180, kScreen_Width-60, 20)];
    carouselView.pageVC.pageIndicatorTintColor=kSeparatorColor;
    carouselView.direct.scrollsToTop=NO;
    carouselView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:carouselView];
    
    self.view.backgroundColor=kBGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(UIImage *)imageWithColor:(UIColor *)aColor{
    CGRect aFrame=CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(aFrame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [aColor CGColor]);
    CGContextFillRect(context, aFrame);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end
