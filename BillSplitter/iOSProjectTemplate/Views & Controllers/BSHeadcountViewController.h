/**
	@file	BSHeadcountViewController.h
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

#import "UIVerticalStepper.h"

@class BSHeadcountViewController;
@protocol BSHeadcountViewControllerDelegate <NSObject>

    @optional
    /** Notifies delegate whenever headcount is changed */
    - (void)headCountViewController:(BSHeadcountViewController *)vc countChanged:(NSInteger)count;

    /** Notifies delegate if instruction button is pressed */
    - (void)headCountViewController:(BSHeadcountViewController *)vc instructionsPressed:(UIButton *)button;

@end

@interface BSHeadcountViewController : UIViewController <
	UIVerticalStepperDelegate
>

    @property (nonatomic, weak) id<BSHeadcountViewControllerDelegate> delegate;

	@property (nonatomic, strong) UILabel *taglineLabel;
	@property (nonatomic, strong) UILabel *welcomeLabel;
	@property (strong, nonatomic) UIImageView *imageView;
	@property (strong, nonatomic) UITextField *textField;
	@property (nonatomic, strong) UIVerticalStepper *stepper;
       
    @property (nonatomic, strong) UIButton *instructionButton;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

@end
