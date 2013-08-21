/**
	@file	BSHeadcountViewController.h
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

@class BSHeadcountViewController;
@protocol BSHeadcountViewControllerDelegate <NSObject>

@end

@interface BSHeadcountViewController : UIViewController <
	UITextFieldDelegate
>

	@property (strong, nonatomic) UIStepper *stepper;
	@property (strong, nonatomic) UITextField *textField;
	@property (strong, nonatomic) UIImageView *imageView;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

@end
