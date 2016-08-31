//
//  PhotoBrowserViewController.m
//  HXPhotoBrowser
//
//  Created by hanx on 16/8/29.
//  Copyright © 2016年 hanx. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "PhotoViewController.h"
#import "PhotoBrowserPhotos.h"
#import "PhotoBrowserAnimator.h"

@interface PhotoBrowserViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,PhotoViewControllerDelegate>

@end

@implementation PhotoBrowserViewController{
    PhotoBrowserPhotos *_photos;
    BOOL _statusBarHidden;
    UIPageViewController *pageViewControllers;
    PhotoBrowserAnimator *_animator;
    PhotoViewController *currentViewer;
}

#pragma mark - 构造函数
+ (instancetype)photoBrowserWithSelectedIndex:(NSInteger)selectedIndex urls:(NSArray<NSString *> *)urls parentImageViews:(NSArray<UIImageView *> *)parentImageViews {
    return [[self alloc] initWithSelectedIndex:selectedIndex
                                          urls:urls
                              parentImageViews:parentImageViews];
}

- (instancetype)initWithSelectedIndex:(NSInteger)selectedIndex urls:(NSArray<NSString *> *)urls parentImageViews:(NSArray<UIImageView *> *)parentImageViews {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _photos = [[PhotoBrowserPhotos alloc] init];
        
        _photos.selectedIndex = selectedIndex;
        self.index = selectedIndex;
        self.arrayImageStr = urls;
        _photos.urls = urls;
        _photos.parentImageViews = parentImageViews;
        
        _statusBarHidden = NO;
        
        self.modalPresentationStyle = UIModalPresentationCustom;
        _animator = [PhotoBrowserAnimator animatorWithPhotos:_photos];
        self.transitioningDelegate = _animator;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI{
    pageViewControllers = [[UIPageViewController alloc]
                          initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                          options:@{UIPageViewControllerOptionInterPageSpacingKey: @20}];
    pageViewControllers.delegate = self;
    [pageViewControllers.view setBackgroundColor:[UIColor blackColor]];
    pageViewControllers.dataSource = self;
    PhotoViewController *viewer = [[PhotoViewController alloc]initWithImage:_photos.urls[_photos.selectedIndex] index:_photos.selectedIndex placeHoldImage:_photos.parentImageViews[_photos.selectedIndex].image];
    viewer.delegate = self;
    [pageViewControllers setViewControllers:@[viewer]
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:YES
                                completion:nil];
    [self.view addSubview:pageViewControllers.view];
    [self addChildViewController:pageViewControllers];
    [pageViewControllers didMoveToParentViewController:self];
    currentViewer = viewer;
}



#pragma mark - UIPageViewControllerDelegate



- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(PhotoViewController *)viewController{
    NSInteger index = viewController.index;
    if (index-- <= 0) {
        return nil;
    }
    self.index = index;
    UIImage *placeHolder = _photos.parentImageViews[index].image;
    PhotoViewController *photoVc = [[PhotoViewController alloc]initWithImage:_photos.urls[index] index:index placeHoldImage:placeHolder];
    photoVc.delegate = self;
    return photoVc;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(PhotoViewController *)viewController{
    
    NSInteger index = viewController.index;
    if (++index >= self.arrayImageStr.count) {
        return nil;
    }

    self.index = index;
    UIImage *placeHolder = _photos.parentImageViews[index].image;
    PhotoViewController *photoVc = [[PhotoViewController alloc]initWithImage:self.arrayImageStr[index] index:index placeHoldImage:placeHolder];
    photoVc.delegate = self;
    return photoVc;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    PhotoViewController *viewe = pageViewController.viewControllers[0];
    _photos.selectedIndex = viewe.index;
    currentViewer = viewe;
}

- (void)imageDidClick{
    
    _animator.fromImageView = currentViewer.imageView;
    _animator.fromImageView.frame = [self getImageViewSizeWithImage:currentViewer.imageView.image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGRect)getImageViewSizeWithImage:(UIImage *)image{
    CGFloat widthScale = [UIScreen mainScreen].bounds.size.width/image.size.width;
    CGFloat viewY;;
    CGFloat hei = image.size.height * widthScale;
    CGFloat wid = image.size.width * widthScale;
    if (image.size.width/image.size.height > [UIScreen mainScreen].bounds.size.width/[UIScreen mainScreen].bounds.size.height) {
        viewY = ([UIScreen mainScreen].bounds.size.height - hei)*0.5;
    }else{
        viewY = 0;
    }
    return CGRectMake(0,viewY, wid, hei);
}


@end
