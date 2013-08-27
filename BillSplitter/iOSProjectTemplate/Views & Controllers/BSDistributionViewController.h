/**
	@file	BSDistributionViewController.h
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

#import "RPVerticalStepper.h"

	extern NSString* const BSDistributionViewControllerProfileViewDishes;
	extern NSString* const BSDistributionViewControllerProfileViewImageButton;
	extern NSString* const BSDistributionViewControllerProfileViewRemoveButton;
	extern NSString* const BSDistributionViewControllerProfileViewTextField;
	extern NSString* const BSDistributionViewControllerProfileViewStepper;
	extern NSString* const BSDistributionViewControllerProfileViewCard;

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

	@property (nonatomic, strong) NSMutableArray *profiles;

	@property (nonatomic, strong) UILabel *descriptionLabel;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

@end
