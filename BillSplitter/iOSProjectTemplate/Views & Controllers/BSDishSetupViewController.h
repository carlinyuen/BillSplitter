/**
	@file	BSDishSetupViewController.h
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

#import "UIVerticalStepper.h"

	typedef enum {
		BSDishSetupViewControllerItemDrink,
		BSDishSetupViewControllerItemSmallDish,
		BSDishSetupViewControllerItemMediumDish,
		BSDishSetupViewControllerItemLargeDish,
		BSDishSetupViewControllerItemCount
	} BSDishSetupViewControllerItem;

@interface BSDishSetupViewController : UIViewController <
	UIVerticalStepperDelegate
>

    @property (nonatomic, strong) UILabel *descriptionLabel;

	@property (nonatomic, strong) UIButton *drinkButton;
	@property (nonatomic, strong) UIButton *smallDishButton;
	@property (nonatomic, strong) UIButton *mediumDishButton;
	@property (nonatomic, strong) UIButton *largeDishButton;

	@property (nonatomic, strong) UIVerticalStepper *drinkStepper;
	@property (nonatomic, strong) UIVerticalStepper *smallDishStepper;
	@property (nonatomic, strong) UIVerticalStepper *mediumDishStepper;
	@property (nonatomic, strong) UIVerticalStepper *largeDishStepper;

	@property (nonatomic, strong) UITextField *drinkTextField;
	@property (nonatomic, strong) UITextField *smallDishTextField;
	@property (nonatomic, strong) UITextField *mediumDishTextField;
	@property (nonatomic, strong) UITextField *largeDishTextField;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

	/** @brief Returns one of the steppers used */
	- (UIVerticalStepper *)stepperForTextField:(UITextField *)textField;

@end
