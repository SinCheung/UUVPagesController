//
//  ListTopBar.m
//  UUVideo
//
//  Created by Admin on 16/3/24.
//  Copyright © 2016年 UUV. All rights reserved.
//

#import "UUVListTopBar.h"

#define UUVListTopBarItemSpace    10.f
#define UUVListTopBarItemMinWidth 44.f

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
    CGFloat _deltaX;
    CGFloat _contanierWidth;
    CGFloat _externContanierWidth;
    BOOL    _modifyOffsetManual;
    BOOL    _shouldChangeItemPosition;
}
@property (nonatomic, strong) UIScrollView *itemsContanier;
@property (nonatomic, strong) UIView       *indicator;
@property (nonatomic, strong, readwrite) NSMutableArray *itemViews;
@end

@implementation UUVListTopBar

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray<NSString *> *)titles
{
    self = [super initWithFrame:frame];
    if (self) {
        self.itemTitles = titles.copy;
        _contanierWidth = CGRectGetWidth(frame);
    }
    return self;
}

- (void)reloadData
{
    [self setupSubviews];
}

- (void)setupSubviews
{
    if (!_itemViews) {
        _itemViews = [NSMutableArray arrayWithCapacity:_itemTitles.count];
    }
    
    [_itemViews removeAllObjects];
    _selectedIndex = 0;
    _deltaX = 0.f;
    _itemSelectedScale = 17.f/15.f;
    _shouldChangeItemPosition = NO;
    
    [self addSubview:self.itemsContanier];
    if (self.itemsContanier.subviews.count) {
        [self.itemsContanier.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    __weak typeof(self) weakSelf = self;
    [_itemTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [weakSelf genUIButtonWithTitle:title
                                                 color:weakSelf.itemColor
                                                  font:weakSelf.itemFont
                                                 index:idx];
        [weakSelf.itemViews addObject:btn];
        [weakSelf.itemsContanier addSubview:btn];
        if (idx==0) {
            [weakSelf makeItemSelected:btn];
        }
    }];
    
    _shouldChangeItemPosition = (_deltaX>_contanierWidth);
    _itemsContanier.contentSize = CGSizeMake(_deltaX, CGRectGetHeight(_itemsContanier.frame));
    
    if (_showIndicator) {
        CGRect frame = self.indicator.frame;
        UIButton *firstbtn = _itemViews.firstObject;
        frame.size.width = CGRectGetWidth(firstbtn.frame);
        self.indicator.frame = frame;
        
        CGPoint center = self.indicator.center;
        center.x = firstbtn.center.x;
        self.indicator.center = center;
        
        [self.itemsContanier addSubview:self.indicator];
    } else {
        [_indicator removeFromSuperview];
        _indicator = nil;
    }
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
    btn.frame = CGRectMake(_deltaX, 0, width, CGRectGetHeight(self.frame));
    _deltaX+=(width+UUVListTopBarItemSpace);
    
    return btn;
}

- (void)makeItemSelected:(UIButton *)item
{
    item.transform = CGAffineTransformMakeScale(_itemSelectedScale, _itemSelectedScale);
    [item setTitleColor:self.itemSelectedColor forState:UIControlStateNormal];
}

- (void)makeItemNormal:(UIButton *)item
{
    item.transform = CGAffineTransformIdentity;
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
        _indicator = [UIView new];
        _indicator.backgroundColor = self.indicatorColor;
        _indicator.frame = CGRectMake(0, CGRectGetHeight(self.frame)-self.indicatorHeight-.5f, 0, self.indicatorHeight);
    }
    return _indicator;
}

#pragma mark - setter
- (void)setItemTitles:(NSArray<NSString *> *)itemTitles
{
    if (![_itemTitles isEqualToArray:itemTitles]) {
        _itemTitles = itemTitles.copy;
        _deltaX = UUVListTopBarItemSpace;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (_selectedIndex!=selectedIndex && selectedIndex<_itemTitles.count) {
        _selectedIndex = selectedIndex;
        
        UIButton *sender = self.itemViews[selectedIndex];
        [self changeClickItemPositon:sender];
    }
}

- (void)setItemSelectedScale:(CGFloat)itemSelectedScale
{
    if (itemSelectedScale>1.f) {
        _itemSelectedScale = itemSelectedScale;
    } else {
        NSLog(@"You shoud set the selected scale greater than 1.0.");
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
                
                if (_indicator) {
                    CGRect frame = _indicator.frame;
                    CGPoint center = _indicator.center;
                    
                    CGFloat preX = previosSelectedItem.center.x;
                    CGFloat nextX = nextSelectedItem.center.x;
                    CGFloat preWidth = CGRectGetWidth(previosSelectedItem.frame);
                    CGFloat nextWidth = CGRectGetWidth(nextSelectedItem.frame);
                    
                    CGFloat deltaWith = nextWidth-preWidth;
                    frame.size.width = preWidth+(absRatio*deltaWith);
                    
                    CGFloat deltaCenterX = nextX-preX;
                    center.x = preX+(absRatio*deltaCenterX);
                    
                    _indicator.frame = frame;
                    _indicator.center = center;
                }
                
                CGFloat preScale = 1.f + (_itemSelectedScale-1.f)*(1-absRatio);
                CGFloat nextScale = 1.f + (_itemSelectedScale-1.f)*absRatio;
                previosSelectedItem.transform = CGAffineTransformMakeScale(preScale, preScale);
                nextSelectedItem.transform = CGAffineTransformMakeScale(nextScale, nextScale);
                if (absRatio>0.5f) {
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
        frame.size.width = CGRectGetWidth(sender.frame);
        
        [UIView animateWithDuration:0.2f
                         animations:^{
                             _indicator.frame = frame;
                             _indicator.center = center;
                         }];
    }
    
    _modifyOffsetManual = YES;
     CGPoint point = CGPointMake(_selectedIndex*_externContanierWidth, 0);
    [UIView animateWithDuration:0.0f
                     animations:^{
                         [_contanierView setContentOffset:point animated:NO];
                     } completion:^(BOOL finished) {
                         _modifyOffsetManual = NO;
                     }];
    
    if ([self.delegate respondsToSelector:@selector(itemAtIndex:didSelectInTopBar:)]) {
        [self.delegate itemAtIndex:_selectedIndex didSelectInTopBar:self];
    }
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
    
    if (itemCenter.x>halfWidth && itemCenter.x<(_deltaX-halfWidth)) {
        finalPoint = CGPointMake(itemCenter.x-halfWidth, 0);
        shouldChange = YES;
    } else if (itemCenter.x>(_deltaX-halfWidth)) {
        finalPoint = CGPointMake(_deltaX-_contanierWidth, 0);
        shouldChange = YES;
    } else if (itemCenter.x<halfWidth) {
        shouldChange = YES;
    }
    
    if (shouldChange) {
        [_itemsContanier setContentOffset:finalPoint animated:YES];
    }
}

@end
