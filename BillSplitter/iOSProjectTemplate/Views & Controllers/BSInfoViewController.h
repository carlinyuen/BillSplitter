/**
	@file	BSInfoViewController.h
	@author	Carlin
	@date	7/12/13
	@brief	iOSProjectTemplate
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

@class BSInfoViewController;
@protocol BSInfoViewControllerDelegate <NSObject>

	@optional
	- (void)infoViewController:(BSInfoViewController*)vc willCloseAnimated:(bool)animated;

@end

@interface BSInfoViewController : UIViewController <
	UITableViewDataSource, UITableViewDelegate
>

	@property (nonatomic, weak) id<BSInfoViewControllerDelegate> delegate;

@end
