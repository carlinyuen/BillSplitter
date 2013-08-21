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

	@property (weak, nonatomic) IBOutlet UIStepper *stepper;
	@property (weak, nonatomic) IBOutlet UITextField *textField;
	@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
