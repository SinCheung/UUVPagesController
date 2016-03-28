//
//  UUVPagesController.m
//  UUVideo
//
//  Created by Admin on 16/3/25.
//  Copyright © 2016年 UUV. All rights reserved.
//

#import "UUVPagesController.h"
#import "UUVListTopBar.h"

#define UUVPagesDefaultTopBarHeight 44.f
#define UUVPagesDefaultTopBarWidth  [UIScreen mainScreen].bounds.size.width-20.f

static UIEdgeInsets UUV_UIEdgeInsetsFromUIRectEdge(UIRectEdge rectEdge) {
    CGFloat top,bottom;
    top = rectEdge&UIRectEdgeTop ? 64.f : 0.f;
    bottom = rectEdge&UIRectEdgeBottom ? 49.f : 0.f;
    return UIEdgeInsetsMake(top, 0, bottom, 0);
}

@interface UUVPagesController ()
@property (nonatomic, strong) UIScrollView  *contanierView;
@property (nonatomic, strong) UUVListTopBar *topBar;
@property (nonatomic, strong) NSArray<NSString*> *titles;
@property (nonatomic, assign) CGRect topBarFrame;
@property (nonatomic, weak)   UIViewController *topViewController;
@end

@implementation UUVPagesController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _topBarHeight = UUVPagesDefaultTopBarHeight;
    _topBarWidth = UUVPagesDefaultTopBarWidth+20;
    _highlightsScale = 17.f/15.f;
    [self.view addSubview:self.contanierView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - getter
- (UIScrollView *)contanierView
{
    if (!_contanierView) {
        _contanierView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _contanierView.pagingEnabled = YES;
        _contanierView.showsVerticalScrollIndicator = NO;
        _contanierView.showsHorizontalScrollIndicator = NO;
    }
    return _contanierView;
}

- (UUVListTopBar *)topBar
{
    if (!_topBar) {
        _topBar = [[UUVListTopBar alloc] initWithFrame:_topBarFrame
                                                titles:_titles];
        _topBar.backgroundColor = self.topBarColor;
        _topBar.itemFont = self.font;
        _topBar.itemColor = self.normalColor;
        _topBar.itemSelectedColor = self.highlightsColor;
        _topBar.itemSelectedScale = self.highlightsScale;
        _topBar.delegate = self.topBarDelegate;
        _topBar.showIndicator = self.showIndicator;
        _topBar.indicatorColor = self.indicatorColor;
        _topBar.indicatorHeight = self.indicatorHeight;
    }
    return _topBar;
}

- (UIFont *)font
{
    if (!_font) {
        _font = [UIFont systemFontOfSize:15.f];
    }
    return _font;
}

- (UIColor *)topBarColor
{
    if (!_topBarColor) {
        _topBarColor = [UIColor clearColor];
    }
    return _topBarColor;
}

- (UIColor *)normalColor
{
    if (!_normalColor) {
        _normalColor = [UIColor lightGrayColor];
    }
    return _normalColor;
}

- (UIColor *)highlightsColor
{
    if (!_highlightsColor) {
        _highlightsColor = [UIColor whiteColor];
    }
    return _highlightsColor;
}

- (NSUInteger)index
{
    return self.topBar.selectedIndex;
}

#pragma mark - setter
- (void)setHighlightsScale:(CGFloat)highlightsScale
{
    if (highlightsScale>1.f) {
        _highlightsScale = highlightsScale;
    }
}

- (void)setTopBarHeight:(CGFloat)topBarHeight
{
    if (_topBarPlace) {
        if (_topBarHeight!=UUVPagesDefaultTopBarHeight) {
            _topBarHeight = UUVPagesDefaultTopBarHeight;
        }
        return;
    }
    
    if (_topBarHeight!=topBarHeight) {
        _topBarHeight = topBarHeight;
    }
}

- (void)setTopBarWidth:(CGFloat)topBarWidth
{
    if (_topBarPlace) {
        if (_topBarHeight!=UUVPagesDefaultTopBarWidth) {
            _topBarHeight = UUVPagesDefaultTopBarWidth;
        }
        return;
    }
    
    if (_topBarWidth!=topBarWidth) {
        _topBarWidth = topBarWidth;
    }
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers
{
    if (_viewControllers != viewControllers) {
        _viewControllers = viewControllers;
        _titles = [viewControllers valueForKey:@"title"];
    }
}

- (void)layoutSubviews
{
    if (!_viewControllers.count) {
        @throw [NSException exceptionWithName:@"Init PagesController exception."
                                       reason:@"Invalid viewControllers,you should guarantee viewControllers property available."
                                     userInfo:nil];
    }
    
    if (!_titles.count) {
        @throw [NSException exceptionWithName:@"Init PagesController exception."
                                       reason:@"Invalid viewController`s title,you should set title property."
                                     userInfo:nil];
    }
    
    [self.contanierView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _topBar = nil;
    _topBarWidth = _topBarPlace ? UUVPagesDefaultTopBarWidth : _topBarWidth;
    _topBarHeight = _topBarPlace ? UUVPagesDefaultTopBarHeight : _topBarHeight;
    
    CGFloat topBarX = 0.f;
    if (!_topBarPlace) {
        UIEdgeInsets insets = UUV_UIEdgeInsetsFromUIRectEdge(_topViewController.edgesForExtendedLayout);
        topBarX = insets.top;
    }
    
    _topBarFrame = CGRectMake(0, topBarX, _topBarWidth, _topBarHeight);
    
    if (_topBarPlace) {
        _topBarPlace.titleView = self.topBar;
    } else {
        [self.view addSubview:self.topBar];
        [self.view bringSubviewToFront:self.topBar];
    }
    
    CGFloat containerWidth = CGRectGetWidth(self.view.frame);
    CGFloat contanierHeight = CGRectGetHeight(self.view.frame);
    self.contanierView.frame = CGRectMake(0, 0, containerWidth, contanierHeight);
    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
        [_topViewController addChildViewController:vc];
        CGRect frame = CGRectMake(idx*containerWidth, 0, containerWidth, contanierHeight);
        vc.view.frame = frame;
        [self.contanierView addSubview:vc.view];
    }];
    
    self.contanierView.contentSize = CGSizeMake(_viewControllers.count*containerWidth, contanierHeight);
    self.topBar.contanierView = self.contanierView;
    [self.topBar reloadData];
}

- (void)reloadData
{
    [self layoutSubviews];
}

- (void)addParentViewController:(UIViewController *)vc
{
    _topViewController = vc;
    [self willMoveToParentViewController:vc];
    [vc.view addSubview:self.view];
    [self didMoveToParentViewController:vc];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.view
                                                               attribute:(NSLayoutAttributeLeading)
                                                               relatedBy:(NSLayoutRelationEqual)
                                                                  toItem:vc.view
                                                               attribute:(NSLayoutAttributeLeading)
                                                              multiplier:1.f
                                                                constant:0.f];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.view
                                                               attribute:(NSLayoutAttributeTop)
                                                               relatedBy:(NSLayoutRelationEqual)
                                                                  toItem:vc.view
                                                               attribute:(NSLayoutAttributeTop)
                                                              multiplier:1.f
                                                                constant:0.f];
    
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:self.view
                                                               attribute:(NSLayoutAttributeTrailing)
                                                               relatedBy:(NSLayoutRelationEqual)
                                                                  toItem:vc.view
                                                               attribute:(NSLayoutAttributeTrailing)
                                                              multiplier:1.f
                                                                constant:0.f];
    
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.view
                                                               attribute:(NSLayoutAttributeBottom)
                                                               relatedBy:(NSLayoutRelationEqual)
                                                                  toItem:vc.view
                                                               attribute:(NSLayoutAttributeBottom)
                                                              multiplier:1.f
                                                                constant:0.f];
    [vc.view addConstraints:@[leading,top,trailing,bottom]];
    
    [self layoutSubviews];
}

@end
