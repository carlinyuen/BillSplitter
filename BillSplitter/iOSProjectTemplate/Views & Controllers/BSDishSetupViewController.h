/**
	@file	BSDishSetupViewController.h
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

#import "RPVerticalStepper.h"

@interface BSDishSetupViewController : UIViewController <
	RPVerticalStepperDelegate
>

	@property (nonatomic, strong) UIButton *drinkButton;
	@property (nonatomic, strong) UIButton *smallDishButton;
	@property (nonatomic, strong) UIButton *mediumDishButton;
	@property (nonatomic, strong) UIButton *largeDishButton;

	@property (nonatomic, strong) RPVerticalStepper *drinkStepper;
	@property (nonatomic, strong) RPVerticalStepper *smallDishStepper;
	@property (nonatomic, strong) RPVerticalStepper *mediumDishStepper;
	@property (nonatomic, strong) RPVerticalStepper *largeDishStepper;

	@property (nonatomic, strong) UITextField *drinkTextField;
	@property (nonatomic, strong) UITextField *smallDishTextField;
	@property (nonatomic, strong) UITextField *mediumDishTextField;
	@property (nonatomic, strong) UITextField *largeDishTextField;

	@property (nonatomic, strong) UILabel *descriptionLabel;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

	/** @brief Returns one of the steppers used */
	- (RPVerticalStepper *)stepperForTextField:(UITextField *)textField;

@end
