/**
	@file	BSTotalMarkupViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSTotalMarkupViewController.h"

@interface BSTotalMarkupViewController ()

@end


#pragma mark - Implementation

@implementation BSTotalMarkupViewController

/** @brief Initialize data-related properties */
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
	{
		self.view.frame = frame;
	
		_totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_totalIV = [[UIImageView alloc] initWithFrame:CGRectZero];
		_totalField = [[UITextField alloc] initWithFrame:CGRectZero];
		_totalStepper = [[UIVerticalStepper alloc] initWithFrame:CGRectZero];
		
		_tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_tipIV = [[UIImageView alloc] initWithFrame:CGRectZero];
		_tipField = [[UITextField alloc] initWithFrame:CGRectZero];
		_tipStepper = [[UIVerticalStepper alloc] initWithFrame:CGRectZero];
		
		_descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return self;
}


#pragma mark - View Lifecycle

/** @brief Setup UI elements for viewing. */
- (void)viewDidLoad
{
    [super viewDidLoad];
}

/** @brief Last-minute setup before view appears. */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

/** @brief Dispose of any resources that can be recreated. */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/** @brief Return supported orientations */
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - Class Functions


#pragma mark - UI Setup


#pragma mark - UI Events


#pragma mark - Utility Functions


#pragma mark - Delegates


@end
