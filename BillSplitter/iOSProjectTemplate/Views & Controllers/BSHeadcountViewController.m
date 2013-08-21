/**
	@file	BSHeadcountViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSHeadcountViewController.h"

	#define UI_SIZE_TEXTFIELD_HEIGHT 100

	#define IMG_MAN @"man.png"

@interface BSHeadcountViewController ()

@end


#pragma mark - Implementation

@implementation BSHeadcountViewController

/** @brief Initialize data-related properties */
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
	{
		self.view.frame = frame;
		
		_stepper = [[UIStepper alloc] initWithFrame:CGRectZero];
		_textField = [[UITextField alloc] initWithFrame:CGRectZero];
		_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return self;
}


#pragma mark - View Lifecycle

/** @brief Setup UI elements for viewing. */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	CGRect frame = self.textField.frame;
	frame.size.height = UI_SIZE_TEXTFIELD_HEIGHT;
	self.textField.frame = frame;
	self.textField.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_TEXTFIELD];
	
	self.stepper.transform = CGAffineTransformMakeRotation(degreesToRadians(10));
	frame = self.stepper.frame;
	frame.origin.x = self.textField.frame.origin.x + self.textField.frame.size.width;
	self.stepper.frame = frame;
	
	self.imageView.frame = CGRectMake( 0, 0, 48, 80 );
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	self.imageView.image = [UIImage imageNamed:IMG_MAN];
	
	[self.view addSubview:self.imageView];
	[self.view addSubview:self.textField];
	[self.view addSubview:self.stepper];
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
