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

	@property (nonatomic, strong) UILabel *totalLabel;
	@property (strong, nonatomic) UITextField *totalField;
	@property (nonatomic, strong) UIVerticalStepper *totalStepper;

	@property (nonatomic, strong) UILabel *tipLabel;
	@property (strong, nonatomic) UITextField *tipField;
	@property (nonatomic, strong) UIVerticalStepper *tipStepper;
   	@property (nonatomic, strong) UILabel *tipAmountLabel; 

	@property (nonatomic, strong) UILabel *finalLabel;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

	/** @brief Returns one of the steppers used */
	- (UIVerticalStepper *)stepperForTextField:(UITextField *)textField;
    
    /** @brief Updates tip amount based on tip */
    - (void)updateTipAmount;
    
@end
