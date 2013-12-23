/**
	@file	BSSummaryViewController.h
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

#import "BSDishSetupViewController.h"
#import "BSDistributionViewController.h"

	extern NSString* const BSSummaryViewControllerProfileBill;
    
@interface BSSummaryViewController : UIViewController

    /** Reference to final cost label from BSTotalMarkupViewController */
	@property (nonatomic, strong) UILabel *finalLabel;

    /** Reference to steppers from BSDishSetupViewController to get prices */
	@property (nonatomic, strong) UIVerticalStepper *drinkStepper;
	@property (nonatomic, strong) UIVerticalStepper *smallDishStepper;
	@property (nonatomic, strong) UIVerticalStepper *mediumDishStepper;
	@property (nonatomic, strong) UIVerticalStepper *largeDishStepper;
    
    /** List of profiles user sets up, from BSDistributionViewController */
	@property (nonatomic, strong) NSMutableArray *profiles;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

@end
