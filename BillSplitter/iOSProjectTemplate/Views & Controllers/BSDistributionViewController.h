/**
	@file	BSDistributionViewController.h
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

#import "RPVerticalStepper.h"

#import "BSDistributionTableViewCell.h"

@interface BSDistributionViewController : UIViewController <
	RPVerticalStepperDelegate,
	UITableViewDataSource,
	UITableViewDelegate
>

	@property (nonatomic, strong) UITableView *tableView;
	@property (nonatomic, strong) BSDistributionTableViewCell *headerView;
	@property (nonatomic, strong) NSMutableArray *imageViews;
	@property (nonatomic, strong) NSMutableArray *textFields;
	@property (nonatomic, strong) NSMutableArray *steppers;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

	/** @brief Returns one of the steppers used */
	- (RPVerticalStepper *)stepperForTextField:(UITextField *)textField;

@end
