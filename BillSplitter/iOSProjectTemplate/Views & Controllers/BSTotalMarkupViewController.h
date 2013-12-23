/**
	@file	BSTotalMarkupViewController.h
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

#import "UIVerticalStepper.h"

@interface BSTotalMarkupViewController : UIViewController <
	UIVerticalStepperDelegate
>

    /** Reference to HeadCount stepper from BSHeadCountViewController */
    @property (nonatomic, strong) UIVerticalStepper *headCountStepper;

	@property (nonatomic, strong) UILabel *totalLabel;
	@property (strong, nonatomic) UITextField *totalField;
	@property (nonatomic, strong) UIVerticalStepper *totalStepper;

	@property (nonatomic, strong) UILabel *tipLabel;
	@property (strong, nonatomic) UITextField *tipField;
	@property (nonatomic, strong) UIVerticalStepper *tipStepper;
   	@property (nonatomic, strong) UITextField *tipAmountField; 

	@property (nonatomic, strong) UIView *finalDivider;
	@property (nonatomic, strong) UILabel *finalLabel;
   	@property (nonatomic, strong) UILabel *evenSplitLabel; 

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

	/** @brief Returns one of the steppers used */
	- (UIVerticalStepper *)stepperForTextField:(UITextField *)textField;
    
    /** @brief Updates calculations */
    - (void)updateCalculations;
    
@end
