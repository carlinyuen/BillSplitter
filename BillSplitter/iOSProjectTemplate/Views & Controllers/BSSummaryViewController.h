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
    
@interface BSSummaryViewController : UIViewController <
    UIScrollViewDelegate
>
    
    /** Reference to final cost label from BSTotalMarkupViewController */
	@property (nonatomic, strong) UILabel *finalLabel;

    /** Reference to steppers from BSDishSetupViewController to get prices */
	@property (nonatomic, strong) UIVerticalStepper *drinkStepper;
	@property (nonatomic, strong) UIVerticalStepper *smallDishStepper;
	@property (nonatomic, strong) UIVerticalStepper *mediumDishStepper;
	@property (nonatomic, strong) UIVerticalStepper *largeDishStepper;
    
    /** List of profiles user sets up, from BSDistributionViewController */
	@property (nonatomic, strong) NSMutableArray *profiles;
   	@property (nonatomic, strong) NSMutableArray *profileBillViews;

    /** Reference to scrollView and page control from BSDistributionViewController */
    @property (nonatomic, strong) UIScrollView *profileScrollView;
    @property (nonatomic, strong) CustomPageControl *profilePageControl; 
    
    /** Scroll view for results */
    @property (nonatomic, strong) UIScrollView *scrollView;

    /** Label for error messages */
    @property (nonatomic, strong) UILabel *errorLabel;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

    /** @brief Create UI elements to show new calculations */
    - (void)updateScrollView;

@end
