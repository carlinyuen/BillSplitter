/**
	@file	BSSummaryViewController.h
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

@interface BSSummaryViewController : UIViewController

    /** Reference to final cost label from BSTotalMarkupViewController */
	@property (nonatomic, strong) UILabel *finalLabel;

    /** List of profiles user sets up, from BSDistributionViewController */
	@property (nonatomic, strong) NSMutableArray *profiles;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

@end
