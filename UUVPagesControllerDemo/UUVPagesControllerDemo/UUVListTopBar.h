//
//  ListTopBar.h
//  UUV
//
//  Created by Admin on 16/3/24.
//  Copyright © 2016年 UUV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UUVListTopBar;

typedef NS_ENUM(NSUInteger,UUVListTopBarStyle) {
    UUVListTopBarStyleScale=0,///<Hide indicator and scale item when scrolling.
    UUVListTopBarStyleIndicator,///<Show indicator and no scale.
};

@protocol UUVListTopBarDelegate <NSObject>
@optional
- (void)topBar:(UUVListTopBar *)bar willTransitionFromIndex:(NSUInteger)fromIdx toIndex:(NSUInteger)toIdx;
- (void)topBar:(UUVListTopBar *)bar didTransitionToIndex:(NSUInteger)index;
@end

@interface UUVListTopBar : UIView
@property (nonatomic, strong) UIColor            *itemColor;///<Text color for item normal state
@property (nonatomic, strong) UIColor            *itemSelectedColor;///<Text highlights color for item selected state
@property (nonatomic, strong) UIFont             *itemFont;///< A font for item`s text
@property (nonatomic, assign) CGFloat            itemSelectedScale;///<The scale for selected item（must greater than 1.0）
@property (nonatomic, assign) NSUInteger         selectedIndex;///<Index of selected item,default=0.
@property (nonatomic, strong) NSArray<NSString*> *itemTitles;///<A array of each item`s text.
@property (nonatomic, strong) UIColor            *indicatorColor;///<The color for indicator`s color.Default use itemSelectedColor.
@property (nonatomic, assign) CGFloat            indicatorHeight;///<The height for indicator`s height.Default is 1.5f.
@property (nonatomic, assign) UUVListTopBarStyle style;///<The specified style for top bar.Default use .scale.
@property (nonatomic, assign) CGFloat            itemHorizontalSpace;///<The horizontal space between items in top bar.Default is 10.

@property (nonatomic, weak) id<UUVListTopBarDelegate>  delegate;///<The object who can receive item click event in top bar.
@property (nonatomic, weak) UIScrollView               *contanierView;///<A contanier view that can dispaly items.
@property (nonatomic, strong, readonly) NSMutableArray<UIButton*> *itemViews;///<A array for stor all items.

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray<NSString*> *)titles;
- (void)reloadData;///<You should call this method manual when it appeared in superview or it`s titles value changed.
@end
