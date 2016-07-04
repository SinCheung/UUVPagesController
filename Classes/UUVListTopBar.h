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
    UUVListTopBarStyleCustom,///<Custom the style for transition.
};

@protocol UUVListTopBarDelegate <NSObject>
@optional
- (void)topBar:(nonnull UUVListTopBar *)bar willTransitionFromIndex:(NSUInteger)fromIdx toIndex:(NSUInteger)toIdx;
- (void)topBar:(nonnull UUVListTopBar *)bar willTransitionFromItem:(nonnull UIButton *)previousItem toItem:(nonnull UIButton *)nextItem ratio:(CGFloat)ratio;
- (void)topBar:(nonnull UUVListTopBar *)bar didTransitionToIndex:(NSUInteger)index;
- (nonnull UIView *)customIndicatorInTopBar:(nonnull UUVListTopBar *)topBar;
- (CGFloat)customIndicatorMarginToBottomInTopBar:(nonnull UUVListTopBar *)topBar;///<margin must between in 2.f and 6.f,default=2.f.
@end

@protocol UUVListTopBarDataSource <NSObject>
@required
/**
 *  Return the number of items count.
 *
 *  @param topbar the topbar
 *
 *  @return the count of items
 */
- (NSUInteger)numberOfItemsInTopBar:(nonnull UUVListTopBar *)topbar;
/**
 *  Return a button as item in topBar.
 *  @warning you must not set a action for the button item. if you setted,it`s also no any effection.<br>
 *
 *  @param topBar topbar
 *  @param index  the index of item
 *
 *  @return a custom button
 */
- (nonnull UIButton *)topBar:(nonnull UUVListTopBar *)topBar itemAtIndex:(NSUInteger)index;

@optional
/**
 *  Return the title for item at index.
 *  @warning if you implement this moethod,the item`s font and titleColor will accord with topbar`s proprty.
 *
 *  @param topBar the topBar
 *  @param index  the index for item
 *
 *  @return The title.
 */
- (nullable NSString *)topBar:(nonnull UUVListTopBar *)topBar titleForItemAtIndex:(NSUInteger)index;
@end

IB_DESIGNABLE
@interface UUVListTopBar : UIView
@property (nonatomic, strong, nonnull) IBInspectable UIColor            *itemColor;///<Text color for item normal state
@property (nonatomic, strong, nonnull) IBInspectable UIColor            *itemSelectedColor;///<Text highlights color for item selected state
@property (nonatomic, strong, nonnull) IBInspectable UIFont             *itemFont;///< A font for item`s text
@property (nonatomic, strong, nonnull) IBInspectable UIColor            *indicatorColor;///<The color for indicator`s color.Default use itemSelectedColor.
/**
 *  A array of each item`s text.If you want pass value via dataDource,you can ignore this property.
 */
@property (nonatomic, strong, nullable) NSArray<NSString*>     *itemTitles;
@property (nonatomic, assign) IBInspectable CGFloat            itemSelectedScale;///<The scale for selected item（must not less than 1.0）
@property (nonatomic, assign) IBInspectable NSUInteger         selectedIndex;///<Index of selected item,default=0.
@property (nonatomic, assign) IBInspectable CGFloat            indicatorHeight;///<The height for indicator`s height.Default is 1.5f.
@property (nonatomic, assign) IBInspectable UUVListTopBarStyle style;///<The specified style for top bar.Default use .scale.
@property (nonatomic, assign) IBInspectable CGFloat            itemHorizontalSpace;///<The horizontal space between items in top bar.Default is 10.

@property (nonatomic, weak, nullable) id<UUVListTopBarDelegate>    delegate;///<The object who can receive item click event in top bar.
@property (nonatomic, weak, nullable) id<UUVListTopBarDataSource>  dataSource;///<The object who can return data for top bar.
@property (nonatomic, weak, nullable) UIScrollView                 *contanierView;///<A contanier view that can dispaly items.
@property (nonatomic, strong, readonly, nullable) NSMutableArray<UIButton*> *itemViews;///<A array for stor all items.

- (nullable instancetype)initWithFrame:(CGRect)frame
                                titles:(nonnull NSArray<NSString*> *)titles;
- (void)reloadData;///<You should call this method manual when it appeared in superview or it`s titles value changed.
- (void)reloadDataThenToIndex:(NSUInteger)index;
@end
