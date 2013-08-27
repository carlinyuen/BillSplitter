/**
	@file	BSDistributionViewController.h
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

#import "RPVerticalStepper.h"

@interface BSDistributionViewController : UIViewController <
	RPVerticalStepperDelegate,
	UIScrollViewDelegate
>

	@property (nonatomic, assign) int headCount;

	@property (nonatomic, strong) UIButton *addButton;
	@property (nonatomic, strong) UIButton *removeButton;

	@property (nonatomic, strong) UIButton *drinkButton;
	@property (nonatomic, strong) UIButton *smallDishButton;
	@property (nonatomic, strong) UIButton *mediumDishButton;
	@property (nonatomic, strong) UIButton *largeDishButton;

	@property (nonatomic, strong) NSMutableArray *dishViews;
	@property (nonatomic, strong) NSMutableArray *buttons;
	@property (nonatomic, strong) NSMutableArray *textFields;
	@property (nonatomic, strong) NSMutableArray *steppers;

	@property (nonatomic, strong) UILabel *descriptionLabel;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

	/** @brief Returns one of the steppers used */
	- (RPVerticalStepper *)stepperForTextField:(UITextField *)textField;

@end
