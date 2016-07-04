//
//  ListTopBar.m
//  UUV
//
//  Created by Admin on 16/3/24.
//  Copyright © 2016年 UUV. All rights reserved.
//

#import "UUVListTopBar.h"

#define UUVListTopBarItemSpace    10.f
#define UUVListTopBarItemMinWidth 44.f
#define UUVListTopBarDuration     0.01f

static void* UUVListTopBarContainerContext = &UUVListTopBarContainerContext;
static void  uuv_getRBGAValueWithUIColor(CGFloat *r,CGFloat *g, CGFloat *b,CGFloat *a, UIColor *color) {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    if (colorSpaceModel == kCGColorSpaceModelRGB &&
        CGColorGetNumberOfComponents(color.CGColor) == 4) {
        *r = components[0];
        *g = components[1];
        *b = components[2];
        *a = components[3];
    } else if (colorSpaceModel == kCGColorSpaceModelMonochrome &&
               CGColorGetNumberOfComponents(color.CGColor) == 2) {
        *r = *g = *b = components[0];
        *a = components[1];
    } else {
        *r = *g = *b = *a = 0;
    }
}

@interface UUVListTopBar()
{
    CGFloat _finalContentWidth;
    CGFloat _contanierWidth;
    CGFloat _externContanierWidth;
    NSUInteger _countOfTitles;
    BOOL    _modifyOffsetManual;
    BOOL    _shouldChangeItemPosition;
    struct {
        unsigned int itemDidSelected    : 1;
        unsigned int itemTransition     : 1;
        unsigned int transitionCustom   : 1;
        unsigned int useCustomIndicator : 1;
        unsigned int bottomMargin       : 1;
    } _listTopDelegateFlag;
    
    struct {
        unsigned int numOfItems       : 1;
        unsigned int itemAtIndex      : 1;
        unsigned int titleAtIdx       : 1;
        unsigned int canUseDataSource : 1;
    } _listTopDataSourceFlag;
}
@property (nonatomic, strong) UIScrollView *itemsContanier;
@property (nonatomic, strong) UIView       *indicator;
@property (nonatomic, strong, readwrite) NSMutableArray<UIButton*> *itemViews;
@end

@implementation UUVListTopBar

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray<NSString *> *)titles
{
    self = [super initWithFrame:frame];
    if (self) {
        self.itemTitles = titles.copy;
    }
    return self;
}

- (void)dealloc
{
    if (_contanierView) {
        [self stopObserveContentOffset:_contanierView];
    }
}

- (void)reloadData
{
    [self setupSubviewsThenToIndex:0];
}

- (void)reloadDataThenToIndex:(NSUInteger)index
{
    [self setupSubviewsThenToIndex:index];
}

- (void)setupSubviewsThenToIndex:(NSUInteger)toIndex
{
    NSUInteger toIdx = toIndex;
     _contanierWidth = CGRectGetWidth(self.bounds);
    if (!_itemViews) {
        _itemViews = [NSMutableArray arrayWithCapacity:_itemTitles.count];
    }
    
    [_itemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_itemViews removeAllObjects];
    _selectedIndex = 0;
    if (_itemSelectedScale<1.f) _itemSelectedScale = 17.f/15.f;
    _shouldChangeItemPosition = NO;
    _itemHorizontalSpace = _itemHorizontalSpace!=0 ? _itemHorizontalSpace : UUVListTopBarItemSpace;
    _finalContentWidth = _itemHorizontalSpace;
    
    if (!_itemsContanier) {
        [self addSubview:self.itemsContanier];
    }
    
    _itemsContanier.contentOffset = CGPointZero;
    if (_itemsContanier.subviews.count) {
        [_itemsContanier.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (_listTopDataSourceFlag.canUseDataSource) {
        _countOfTitles = [_dataSource numberOfItemsInTopBar:self];
    } else {
        _countOfTitles = _itemTitles.count;
    }
    
    if (_countOfTitles==0) {
        return;
    }
    
    toIdx = toIndex>=_countOfTitles ? 0 : toIndex;
    if (_countOfTitles>0 && _itemTitles.count) {
        __weak typeof(self) weakSelf = self;
        [_itemTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = nil;
            btn = [weakSelf genUIButtonWithTitle:title
                                           color:weakSelf.itemColor
                                            font:weakSelf.itemFont
                                           index:idx];
            [weakSelf.itemViews addObject:btn];
            [weakSelf.itemsContanier addSubview:btn];
            if (idx==toIdx) {
                [weakSelf makeItemSelected:btn];
            }
        }];
    } else {
        for (NSUInteger idx=0; idx<_countOfTitles; idx++) {
            UIButton *btn = [self genUIButtonFromDataSourceAtIndex:idx];
            [self.itemViews addObject:btn];
            [self.itemsContanier addSubview:btn];
            if (idx==toIdx) {
                [self makeItemSelected:btn];
            }
        }
    }
    
    if (_finalContentWidth<_contanierWidth) {
        __block CGFloat totalWidth = 0.f;
        [_itemViews enumerateObjectsUsingBlock:^(UIButton* _Nonnull btn, NSUInteger idx, BOOL * _Nonnull stop) {
            totalWidth += CGRectGetWidth(btn.frame);
        }];
        
        CGFloat space = (_contanierWidth-totalWidth)/(_itemViews.count+1);
        [_itemViews enumerateObjectsUsingBlock:^(UIButton* _Nonnull btn, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect frame = btn.frame;
            if (idx==0) {
                frame.origin.x = space;
            } else {
                CGRect lastFrame = _itemViews[idx-1].frame;
                frame.origin.x = CGRectGetMaxX(lastFrame)+space;
            }
            
            btn.frame = frame;
        }];
        
        _itemHorizontalSpace = space;
        _finalContentWidth = CGRectGetMaxX(_itemViews.lastObject.frame);
    }
    
    _shouldChangeItemPosition = (_finalContentWidth>_contanierWidth);
    _itemsContanier.contentSize = CGSizeMake(_finalContentWidth, CGRectGetHeight(_itemsContanier.frame));
    
    if (_style==UUVListTopBarStyleIndicator) {
        UIButton *firstbtn = _itemViews.firstObject;
        if (!_listTopDelegateFlag.useCustomIndicator) {
            CGRect frame = self.indicator.frame;
            frame.size.width = CGRectGetWidth(firstbtn.frame);
            self.indicator.frame = frame;
        }
        
        CGPoint center = self.indicator.center;
        center.x = firstbtn.center.x;
        self.indicator.center = center;
        
        [self.itemsContanier addSubview:self.indicator];
    } else {
        [_indicator removeFromSuperview];
        _indicator = nil;
    }
    
    self.selectedIndex = toIdx;
}

- (UIButton *)genUIButtonWithTitle:(NSString *)title
                             color:(UIColor *)color
                              font:(UIFont *)font
                             index:(NSUInteger)idx
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:color forState:UIControlStateNormal];
    [btn.titleLabel setFont:font];
    [btn addTarget:self action:@selector(itemDidClick:) forControlEvents:(UIControlEventTouchUpInside)];
    btn.tag = idx;
    
    CGFloat width = [title sizeWithAttributes:@{NSFontAttributeName : font}].width;
    width = width>UUVListTopBarItemMinWidth ? width : UUVListTopBarItemMinWidth;
    btn.frame = CGRectMake(_finalContentWidth, 0, width, CGRectGetHeight(self.frame));
    _finalContentWidth+=(width+_itemHorizontalSpace);
    
    return btn;
}

- (UIButton *)genUIButtonFromDataSourceAtIndex:(NSUInteger)idx
{
    UIButton *btn = [_dataSource topBar:self itemAtIndex:idx];
    btn.tag = idx;
    
    if (_listTopDataSourceFlag.titleAtIdx) {
        NSString *title = [_dataSource topBar:self titleForItemAtIndex:idx];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:self.itemColor forState:UIControlStateNormal];
        [btn.titleLabel setFont:self.itemFont];
    }
    
    [[btn allTargets] enumerateObjectsUsingBlock: ^(id object, BOOL *stop) {
        [btn removeTarget:object action:NULL forControlEvents:UIControlEventAllEvents];
    }];
    [btn addTarget:self action:@selector(itemDidClick:) forControlEvents:(UIControlEventTouchUpInside)];
    
    CGFloat width = CGRectGetWidth(btn.bounds);
    CGFloat height = CGRectGetHeight(btn.bounds);
    CGFloat y = (CGRectGetHeight(self.bounds)-height)/2.f;
    width = width>UUVListTopBarItemMinWidth ? width : UUVListTopBarItemMinWidth;
    btn.frame = CGRectMake(_finalContentWidth, y, width, height);
    _finalContentWidth+=(width+_itemHorizontalSpace);
    
    return btn;
}

- (void)makeItemSelected:(UIButton *)item
{
    if (_itemSelectedScale>1.f) {
        item.transform = CGAffineTransformMakeScale(_itemSelectedScale, _itemSelectedScale);
    }
    [item setTitleColor:self.itemSelectedColor forState:UIControlStateNormal];
}

- (void)makeItemNormal:(UIButton *)item
{
    if (_itemSelectedScale>1.f) {
        item.transform = CGAffineTransformIdentity;
    }
    [item setTitleColor:self.itemColor forState:UIControlStateNormal];
}

#pragma mark - getter
- (UIScrollView *)itemsContanier
{
    if (!_itemsContanier) {
        _itemsContanier = [[UIScrollView alloc] initWithFrame:self.bounds];
        _itemsContanier.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _itemsContanier.showsHorizontalScrollIndicator = NO;
        _itemsContanier.showsVerticalScrollIndicator = NO;
        _itemsContanier.scrollsToTop = NO;
    }
    return _itemsContanier;
}

- (UIColor *)itemColor
{
    if (!_itemColor) {
        _itemColor = [UIColor lightGrayColor];
    }
    return _itemColor;
}

- (UIColor *)itemSelectedColor
{
    if (!_itemSelectedColor) {
        _itemSelectedColor = [UIColor whiteColor];
    }
    return _itemSelectedColor;
}

- (UIFont *)itemFont
{
    if (!_itemFont) {
        _itemFont = [UIFont systemFontOfSize:15.f];
    }
    return _itemFont;
}

- (UIColor *)indicatorColor
{
    if (!_indicatorColor) {
        return _itemSelectedColor;
    }
    return _indicatorColor;
}

- (CGFloat)indicatorHeight
{
    if (_indicatorHeight==0) {
        _indicatorHeight = 1.5f;
    }
    return _indicatorHeight;
}

- (UIView *)indicator
{
    if (!_indicator) {
        if (_listTopDelegateFlag.useCustomIndicator) {
            _indicator = [_delegate customIndicatorInTopBar:self];
            CGFloat height = CGRectGetHeight(_indicator.bounds);
            height = height<self.indicatorHeight ? self.indicatorHeight : height;
            CGFloat bottomMargin = 2.f;
            if (_listTopDelegateFlag.bottomMargin) {
                bottomMargin = [_delegate customIndicatorMarginToBottomInTopBar:self];
            }
            
            bottomMargin = bottomMargin>6.f ? 6.f : (bottomMargin<2.f ? 2.f : bottomMargin);
            _indicator.frame = CGRectMake(0, CGRectGetHeight(self.frame)-height-bottomMargin, CGRectGetWidth(_indicator.bounds), height);
        } else {
            _indicator = [UIView new];
            _indicator.backgroundColor = self.indicatorColor;
            _indicator.frame = CGRectMake(0, CGRectGetHeight(self.frame)-self.indicatorHeight-.5f, 0, self.indicatorHeight);
        }
    }
    return _indicator;
}

#pragma mark - setter
- (void)setItemTitles:(NSArray<NSString *> *)itemTitles
{
    if (![_itemTitles isEqualToArray:itemTitles]) {
        _itemTitles = itemTitles.copy;
        _finalContentWidth = UUVListTopBarItemSpace;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (_selectedIndex!=selectedIndex && selectedIndex<_countOfTitles) {
        _selectedIndex = selectedIndex;
        
        UIButton *sender = self.itemViews[selectedIndex];
        [self changeClickItemPositon:sender];
        
        if (_listTopDelegateFlag.itemDidSelected) {
            [self.delegate topBar:self didTransitionToIndex:selectedIndex];
        }
    }
}

- (void)setItemSelectedScale:(CGFloat)itemSelectedScale
{
    if (itemSelectedScale>=1.f) {
        _itemSelectedScale = itemSelectedScale;
    } else {
        NSLog(@"[UUVListTopBar]: You shoud set the selected scale not less than 1.0.");
    }
}

- (void)setContanierView:(UIScrollView *)contanierView
{
    if (_contanierView==contanierView) {
        return;
    }
    
    if (_contanierView) {
        [self stopObserveContentOffset:_contanierView];
    }
    
    _contanierView = contanierView;
    _externContanierWidth = CGRectGetWidth(contanierView.frame);
    [self startObserveContentOffset:_contanierView];
}

- (void)setDelegate:(id<UUVListTopBarDelegate>)delegate
{
    _delegate = delegate;
    _listTopDelegateFlag.itemDidSelected = [delegate respondsToSelector:@selector(topBar:didTransitionToIndex:)];
    _listTopDelegateFlag.itemTransition = [delegate respondsToSelector:@selector(topBar:willTransitionFromIndex:toIndex:)];
    _listTopDelegateFlag.transitionCustom = [delegate respondsToSelector:@selector(topBar:willTransitionFromItem:toItem:ratio:)];
    _listTopDelegateFlag.useCustomIndicator = [delegate respondsToSelector:@selector(customIndicatorInTopBar:)];
    _listTopDelegateFlag.bottomMargin = [delegate respondsToSelector:@selector(customIndicatorMarginToBottomInTopBar:)];
}

- (void)setDataSource:(id<UUVListTopBarDataSource>)dataSource
{
    _dataSource = dataSource;
    _listTopDataSourceFlag.numOfItems = [dataSource respondsToSelector:@selector(numberOfItemsInTopBar:)];
    _listTopDataSourceFlag.itemAtIndex = [dataSource respondsToSelector:@selector(topBar:itemAtIndex:)];
    _listTopDataSourceFlag.titleAtIdx = [dataSource respondsToSelector:@selector(topBar:titleForItemAtIndex:)];
    _listTopDataSourceFlag.canUseDataSource = (_listTopDataSourceFlag.itemAtIndex &&
                                               _listTopDataSourceFlag.numOfItems /*&&
                                               _listTopDataSourceFlag.titleAtIdx*/);
}

#pragma mark - observe
- (void)startObserveContentOffset:(UIScrollView *)view
{
    [view addObserver:self
           forKeyPath:@"contentOffset"
              options:(NSKeyValueObservingOptionNew)
              context:UUVListTopBarContainerContext];
}

- (void)stopObserveContentOffset:(UIScrollView *)view
{
    [view removeObserver:self
              forKeyPath:@"contentOffset"
                 context:UUVListTopBarContainerContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context==UUVListTopBarContainerContext && [keyPath isEqualToString:@"contentOffset"]) {
        CGFloat oldX = _selectedIndex * _externContanierWidth;
        if (oldX != self.contanierView.contentOffset.x && !_modifyOffsetManual) {
            BOOL scrollingTowards = (self.contanierView.contentOffset.x > oldX);
            NSInteger targetIndex = (scrollingTowards) ? self.selectedIndex + 1 : self.selectedIndex - 1;
            if (targetIndex >= 0 && targetIndex < self.itemViews.count) {
                CGFloat ratio = (self.contanierView.contentOffset.x - oldX) / _externContanierWidth;
                UIButton *previosSelectedItem = self.itemViews[self.selectedIndex];
                UIButton *nextSelectedItem = self.itemViews[targetIndex];
                
                CGFloat red, green, blue, alpha, highlightedRed, highlightedGreen, highlightedBlue, highlightedAlpha;
                uuv_getRBGAValueWithUIColor(&red,&green,&blue,&alpha,self.itemColor);
                uuv_getRBGAValueWithUIColor(&highlightedRed,&highlightedGreen,&highlightedBlue,&highlightedAlpha,self.itemSelectedColor);
                
                CGFloat absRatio = fabs(ratio);
                if (_style!=UUVListTopBarStyleCustom) {
                    UIColor *prev = [UIColor colorWithRed:red * absRatio + highlightedRed * (1 - absRatio)
                                                    green:green * absRatio + highlightedGreen * (1 - absRatio)
                                                     blue:blue * absRatio + highlightedBlue  * (1 - absRatio)
                                                    alpha:alpha * absRatio + highlightedAlpha  * (1 - absRatio)];
                    UIColor *next = [UIColor colorWithRed:red * (1 - absRatio) + highlightedRed * absRatio
                                                    green:green * (1 - absRatio) + highlightedGreen * absRatio
                                                     blue:blue * (1 - absRatio) + highlightedBlue * absRatio
                                                    alpha:alpha * (1 - absRatio) + highlightedAlpha * absRatio];
                    
                    [previosSelectedItem setTitleColor:prev forState:UIControlStateNormal];
                    [nextSelectedItem setTitleColor:next forState:UIControlStateNormal];
                }
                
                if (_style==UUVListTopBarStyleIndicator) {
                    CGPoint center = _indicator.center;
                    CGFloat preX = previosSelectedItem.center.x;
                    CGFloat nextX = nextSelectedItem.center.x;
                    CGFloat deltaCenterX = nextX-preX;
                    center.x = preX+(absRatio*deltaCenterX);
                    
                    if (!_listTopDelegateFlag.useCustomIndicator) {
                        CGRect frame = _indicator.frame;
                        CGFloat preWidth = CGRectGetWidth(previosSelectedItem.frame);
                        CGFloat nextWidth = CGRectGetWidth(nextSelectedItem.frame);
                        
                        CGFloat deltaWith = nextWidth-preWidth;
                        frame.size.width = preWidth+(absRatio*deltaWith);
                        _indicator.frame = frame;
                    }
                    
                    _indicator.center = center;
                } else if (_style==UUVListTopBarStyleScale && _itemSelectedScale>1.f) {
                    CGFloat preScale = 1.f + (_itemSelectedScale-1.f)*(1-absRatio);
                    CGFloat nextScale = 1.f + (_itemSelectedScale-1.f)*absRatio;
                    previosSelectedItem.transform = CGAffineTransformMakeScale(preScale, preScale);
                    nextSelectedItem.transform = CGAffineTransformMakeScale(nextScale, nextScale);
                } else if (_style==UUVListTopBarStyleCustom) {
                    if (_listTopDelegateFlag.transitionCustom) {
                        [_delegate topBar:self willTransitionFromItem:previosSelectedItem toItem:nextSelectedItem ratio:absRatio];
                    }
                }
                
                if (_listTopDelegateFlag.itemTransition) {
                    [_delegate topBar:self willTransitionFromIndex:_selectedIndex toIndex:targetIndex];
                }
                
                if (absRatio>0.99f) {
                    self.selectedIndex = _contanierView.contentOffset.x / _externContanierWidth;
                }
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - actions
- (void)itemDidClick:(UIButton *)sender
{
    UIButton *lastBtn = self.itemViews[_selectedIndex];
    self.selectedIndex = sender.tag;
    
    [self makeItemNormal:lastBtn];
    [self makeItemSelected:sender];
    
    if (_indicator) {
        CGPoint center = _indicator.center;
        center.x = sender.center.x;
        
        CGRect frame = _indicator.frame;
        if (!_listTopDelegateFlag.useCustomIndicator) {
            frame.size.width = CGRectGetWidth(sender.frame);
        }
        
        [UIView animateWithDuration:0.2f
                         animations:^{
                             _indicator.frame = frame;
                             _indicator.center = center;
                         }];
    }
    
    if (!_contanierView) {
        return;
    }
    
    _modifyOffsetManual = YES;
     CGPoint point = CGPointMake(_selectedIndex*_externContanierWidth, 0);
    [UIView animateWithDuration:UUVListTopBarDuration
                     animations:^{
                         _contanierView.contentOffset = point;
                     } completion:^(BOOL finished) {
                         _modifyOffsetManual = NO;
                     }];
}

- (void)changeClickItemPositon:(UIButton *)btn
{
    if (!_shouldChangeItemPosition) {
        return;
    }
    CGPoint itemCenter = btn.center;
    CGFloat halfWidth = _contanierWidth/2.f;
    CGPoint finalPoint = CGPointZero;
    BOOL shouldChange = NO;
    
    if (itemCenter.x>halfWidth && itemCenter.x<(_finalContentWidth-halfWidth)) {
        finalPoint = CGPointMake(itemCenter.x-halfWidth, 0);
        shouldChange = YES;
    } else if (itemCenter.x>(_finalContentWidth-halfWidth)) {
        finalPoint = CGPointMake(_finalContentWidth-_contanierWidth, 0);
        shouldChange = YES;
    } else if (itemCenter.x<halfWidth) {
        shouldChange = YES;
    }
    
    if (shouldChange) {
        [_itemsContanier setContentOffset:finalPoint animated:YES];
    }
}

@end
