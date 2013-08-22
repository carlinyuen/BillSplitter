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
	RPVerticalStepperDelegate
>

	@property (nonatomic, strong) UILabel *taglineLabel;
	@property (nonatomic, strong) UILabel *welcomeLabel;
	@property (strong, nonatomic) UIImageView *imageView;
	@property (strong, nonatomic) UITextField *textField;
	@property (nonatomic, strong) RPVerticalStepper *stepper;
	@property (nonatomic, strong) UILabel *descriptionLabel;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

@end
