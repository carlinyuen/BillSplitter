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

	@property (nonatomic, strong) UIImageView *drinkIV;
	@property (nonatomic, strong) UIImageView *smallDishIV;
	@property (nonatomic, strong) UIImageView *mediumDishIV;
	@property (nonatomic, strong) UIImageView *largeDishIV;

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

@end
