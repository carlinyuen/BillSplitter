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
	@property (strong, nonatomic) UIImageView *totalIV;
	@property (strong, nonatomic) UITextField *totalField;
	@property (nonatomic, strong) UIVerticalStepper *totalStepper;

	@property (nonatomic, strong) UILabel *tipLabel;
	@property (strong, nonatomic) UIImageView *tipIV;
	@property (strong, nonatomic) UITextField *tipField;
	@property (nonatomic, strong) UIVerticalStepper *tipStepper;

	@property (nonatomic, strong) UILabel *descriptionLabel;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

@end
