//
//  ViewController.m
//  MM
//
//  Created by 蔡君义 on 2017/12/21.
//  Copyright © 2017年 justin. All rights reserved.
//

#import "PageViewController.h"
#import "CairoRequest.h"
#import "MMObject.h"
#import "ImageObject.h"
#import <MJExtension.h>
#import "AFNetworkReachabilityManager.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "MJRefresh.h"
#import <SYPhotoBrowser/SYPhotoBrowser.h>

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)


@interface PageViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray<ImageObject *> *mObject;
@property (strong, nonatomic) CairoRequest *cRequest;
@property (strong, nonatomic) NSString *cRequestURL;
@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation PageViewController

//获取category字符串
NSString * const TypeDescription[] = {
    @"All",@"DaXiong",@"QiaoTun", @"HeiSi", @"MeiTui", @"QingXin",@"ZaHui"
};

//初始化url
NSString *const baseURL = @"https://meizi.leanapp.cn";

- (CairoRequest *) getCRequest
{
    if (!_cRequest) {
        _cRequest = [[CairoRequest alloc] init];
    }
    return _cRequest;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化左右button
    [self initNavBarButton];
    // 初始化collectionview
    [self initCollectionView];
    // 初始化下拉刷新view
    [self initPullRefresh];
    // 初始化上拉更多view
    [self initPushRefresh];
    // 初始化数据
    [self refreshList:0];
}

// 加载进度条
- (void) progressBarInit{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-60)/2, (SCREEN_HEIGHT-60)/2, 60, 60)];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.activityIndicator.userInteractionEnabled = NO;
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

// 去掉加载进度条
- (void) progressBarDismiss
{
    [self.activityIndicator stopAnimating];
    if (self.activityIndicator) {
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }
}

// 初始化左右button
- (void) initNavBarButton{
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"随机换" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(refreshList:)];
    refreshButton.tag = 1;
    self.parentViewController.navigationItem.rightBarButtonItem = refreshButton;
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"全部" style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(refreshList:)];
    homeButton.tag = 0;
    self.parentViewController.navigationItem.leftBarButtonItem = homeButton;
}

- (void)initCollectionView{
    //创建一个layout布局类
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    //设置布局方向为垂直流布局
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //这个是水平布局
    //layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //设置每个item的大小
    layout.itemSize = CGSizeMake([self getSize], [self getSize]);
    //创建collectionView 通过一个布局策略layout来创建
    self.collectionView = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:layout];
    //代理设置
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    //注册item类型 这里使用系统的类型
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
}

//下拉初始化
- (void)initPullRefresh{
    if (self.collectionView.mj_header == nil) {
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        header.automaticallyChangeAlpha = YES;
        self.collectionView.mj_header = header;
    }
}

//加载更多初始化
- (void)initPushRefresh{
    if (self.collectionView.mj_footer == nil) {
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(hasMoreData)];
        footer.automaticallyRefresh = YES;
        footer.automaticallyChangeAlpha = YES;
        self.collectionView.mj_footer = footer;
    }
}

//从服务端加载数据
- (void)loadData:(Boolean)isFirst{
    // 加载进度条
    [self progressBarInit];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self.getCRequest getUrlbyAF:self.cRequestURL andParam:params resultClass:[MMObject class] success:^(id result) {
        MMObject * ob = (MMObject *)result;
        NSMutableArray *nArray = [ImageObject mj_objectArrayWithKeyValuesArray:ob.results];
        if (isFirst) {
            _mObject = nArray;
            [self.collectionView reloadData];
            [self.collectionView.mj_header endRefreshing];
            return;
        }
        if(nArray!=NULL&&nArray.count>0){
            [_mObject addObjectsFromArray:nArray];
            [self.collectionView reloadData];
            [self.collectionView.mj_footer endRefreshing];
        }else{
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
        }
    } failure:^(NSError *error) {
        [self.collectionView.mj_footer endRefreshing];
        NSLog(@"failure");
    }];
    // 移除进度条
    [self progressBarDismiss];
}

// 初始化数据
- (void)refreshList:(id)sender{
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    NSInteger listType = button.tag;
    self.category = ((listType==0) ? TypeDescription[0] :TypeDescription[arc4random()%7]);
    self.page = 1;
    [self appendURL];
    [self loadData:YES];
    self.parentViewController.title =  self.category;
}
// 拼接URL
- (void) appendURL{
    NSString *params = [NSString stringWithFormat:@"/category/%@/page/%@",self.category, @(self.page)];
    self.cRequestURL = [baseURL stringByAppendingString:params];
}

//加载更多
- (void)hasMoreData{
    self.page++;
    [self appendURL];
    [self loadData:NO];
    self.parentViewController.title =  self.category;
}

//下拉刷新数据
- (void)loadNewData{
    [self appendURL];
    [self loadData:YES];
    self.parentViewController.title = self.category;
}

// 图片cell大小
- (NSInteger)getSize{
    CGFloat screeWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    NSInteger perLine = ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait)?3:5;
    //向下取整
    NSInteger asize = floorf(screeWidth/perLine) -8 ;
    return asize;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma collectionView
//返回分区个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//返回每个分区的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _mObject.count;
}

//返回每个item
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [self getSize], [self getSize])];
    //imageView.contentMode = UIViewContentModeScaleAspectFit;
    ImageObject *iObject = (ImageObject *)_mObject[indexPath.row];
    NSURL *imagURL = [NSURL URLWithString:iObject.thumb_url];
    // 占位图片
    UIImage *placeholder = [UIImage imageNamed:@"placeholderImage"];
    // 从内存\沙盒缓存中获得原图
    UIImage *originalImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:iObject.thumb_url];
    if (originalImage) { // 如果内存\沙盒缓存有原图，那么就直接显示原图（不管现在是什么网络状态）
        [imageView sd_setImageWithURL:imagURL placeholderImage:placeholder];
    } else { // 内存\沙盒缓存没有原图
        AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
        if (mgr.isReachableViaWiFi) { // 在使用Wifi, 下载原图
            [imageView sd_setImageWithURL:imagURL placeholderImage:placeholder];
        } else if (mgr.isReachableViaWWAN) { // 在使用手机自带网络
            //     用户的配置项假设利用NSUserDefaults存储到了沙盒中
            //    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"alwaysDownloadOriginalImage"];
            //    [[NSUserDefaults standardUserDefaults] synchronize];
            //#warning 从沙盒中读取用户的配置项：在3G\4G环境是否仍然下载原图
            BOOL alwaysDownloadOriginalImage = [[NSUserDefaults standardUserDefaults] boolForKey:@"alwaysDownloadOriginalImage"];
            if (alwaysDownloadOriginalImage) { // 下载原图
                [imageView sd_setImageWithURL:imagURL placeholderImage:placeholder];
            } else { // 下载小图
                [imageView sd_setImageWithURL:imagURL placeholderImage:placeholder];
            }
        } else { // 没有网络
            UIImage *thumbnailImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:iObject.thumb_url];
            if (thumbnailImage) { // 内存\沙盒缓存中有小图
                [imageView sd_setImageWithURL:imagURL placeholderImage:placeholder];
            } else {
                [imageView sd_setImageWithURL:nil placeholderImage:placeholder];
            }
        }
    }
    [cell addSubview:imageView];
    return cell;
}

//点击图片浏览
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *photoURLArray = [NSMutableArray array];
    for (ImageObject *iObject in self.mObject) {
        [photoURLArray addObject:iObject.image_url];
    }
    SYPhotoBrowser *photoBrowser = [[SYPhotoBrowser alloc] initWithImageSourceArray:photoURLArray caption:nil delegate:self];
    photoBrowser.pageControlStyle = SYPhotoBrowserPageControlStyleLabel;
    photoBrowser.initialPageIndex = indexPath.item;
    [self presentViewController:photoBrowser animated:YES completion:nil];
}

#pragma mark - Orientation method
//判断屏幕旋转方向
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    self.collectionView.frame = CGRectMake(0,0,size.width,size.height);
}

@end
