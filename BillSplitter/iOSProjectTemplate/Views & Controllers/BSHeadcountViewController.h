/**
	@file	BSHeadcountViewController.h
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

#import "RPVerticalStepper.h"

@class BSHeadcountViewController;
@protocol BSHeadcountViewControllerDelegate <NSObject>

@end

@interface BSHeadcountViewController : UIViewController <
	UITextFieldDelegate,
	RPVerticalStepperDelegate
>

	@property (strong, nonatomic) UITextField *textField;
	@property (strong, nonatomic) UIImageView *imageView;
	@property (nonatomic, strong) RPVerticalStepper *stepper;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

@end
