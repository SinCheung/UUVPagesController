//
//  UUVPagesController.h
//  UUV
//
//  Created by Admin on 16/3/25.
//  Copyright © 2016年 UUV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UUVListTopBar.h"

/**
 *  The pagesController contain viewControllers to displayed like "今日头条" or "网易新闻"`s navigation list style.
 *  2 style for topbar display,one is in NavigationBar if you set topBarPlace;another is below NavigationBar.
 *  If you want show topBar in navigationBar,you should set topBarPlace as a UINavigationItem`s object,such as self.navigationItem.
 *  If your viewConroller`s content behind NavigationBar,you should check the viewController`s edgesForExtendedLayout value.
 */
@interface UUVPagesController : UIViewController
@property (nonatomic, strong) UIColor *topBarColor;///<the backgroud color for top list bar,default is clearColor.
@property (nonatomic, strong) UIColor *normalColor;///<default is lightGrayColor
@property (nonatomic, strong) UIColor *highlightsColor;///<default is whiteColor
@property (nonatomic, strong) UIFont  *font;///<default is systemFont with size 15.
@property (nonatomic, strong) NSArray<UIViewController*> *viewControllers;///<the array store viewControllers that displayed in pages contanier.
@property (nonatomic, weak)   UINavigationItem  *topBarPlace;///<topbar layout place.if is nil,topBar will plcae in contanier`s view below navigationBar.
@property (nonatomic, assign) CGFloat highlightsScale;///<must greater than 1.0,default=17.f/15.f
@property (nonatomic, assign) CGFloat topBarHeight;///<the height for list top bar,if the postion is in navigationBar,it use default value 44.f.
@property (nonatomic, assign) CGFloat topBarWidth;///<the width for list top bar.The default value is UIScreen width when topBarPlace is nil.
@property (nonatomic, weak)   id<UUVListTopBarDelegate> topBarDelegate;///<delegate for topBar`s event
@property (nonatomic, readonly) NSUInteger index;///<the index of current highlights item in top list bar.
@property (nonatomic, strong) UIColor *indicatorColor;///<The color for indicator`s color.Default use highlightsColor.
@property (nonatomic, assign) CGFloat indicatorHeight;///<The height for indicator`s height.Default is 2.f.
@property (nonatomic, assign) CGFloat itemHorizontalSpace;///<The horizontal space between items in top bar.Default is 10.
@property (nonatomic, assign) UUVListTopBarStyle topBarStyle;///<A specified top bar style.Default use .scale.

- (void)addParentViewController:(UIViewController *)vc;///<Make contanier to dispalyed on the specified viewController.
- (void)reloadData;///<If you changed the viewControllers value,you should call this method to refresh all layout.
@end
