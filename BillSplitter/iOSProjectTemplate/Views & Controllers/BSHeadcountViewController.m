/**
	@file	BSHeadcountViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSHeadcountViewController.h"

	#define UI_SIZE_WELCOMELABEL_HEIGHT 64
	#define UI_SIZE_DESCRIPTIONLABEL_HEIGHT 64
	#define UI_SIZE_TEXTFIELD_HEIGHT 100
	#define UI_SIZE_MARGIN 16

	#define STEPPER_MIN_VALUE 2
	#define STEPPER_MAX_VALUE 50

	#define IMG_MAN @"man.png"

@interface BSHeadcountViewController ()

	@property (nonatomic, assign) CGRect frame;

@end


#pragma mark - Implementation

@implementation BSHeadcountViewController

/** @brief Initialize data-related properties */
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
	{
		_frame = frame;
		
		_taglineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_welcomeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		_textField = [[UITextField alloc] initWithFrame:CGRectZero];
		_stepper = [[RPVerticalStepper alloc] initWithFrame:CGRectZero];
		_descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return self;
}


#pragma mark - View Lifecycle

/** @brief Setup UI elements for viewing. */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.frame = self.frame;
	
	CGRect bounds = self.view.bounds;
	CGRect frame;

	self.taglineLabel.text = NSLocalizedString(@"TAGLINE_TEXT", nil);
	self.taglineLabel.backgroundColor = [UIColor clearColor];
	self.taglineLabel.textAlignment = NSTextAlignmentCenter;
	self.taglineLabel.textColor = [UIColor darkGrayColor];
	self.taglineLabel.frame = CGRectMake(
		0, 0, 0, 0
	);
	
	self.welcomeLabel.text = NSLocalizedString(@"WELCOME_TEXT", nil);
	self.welcomeLabel.backgroundColor = [UIColor clearColor];
	self.welcomeLabel.textAlignment = NSTextAlignmentCenter;
	self.welcomeLabel.textColor = [UIColor darkGrayColor];
	self.welcomeLabel.frame = CGRectMake(
		0, 0, 0, 0
	);
	
	self.imageView.frame = CGRectMake(
		UI_SIZE_MARGIN, UI_SIZE_MARGIN,
		bounds.size.width / 3, bounds.size.height - UI_SIZE_MARGIN * 2
	);
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	self.imageView.image = [UIImage imageNamed:IMG_MAN];
	self.imageView.clipsToBounds = true;
	
	frame = self.imageView.frame;
	self.textField.frame = CGRectMake(
		frame.origin.x + frame.size.width,
		(bounds.size.height - UI_SIZE_TEXTFIELD_HEIGHT) / 2,
		bounds.size.width / 3 + UI_SIZE_MARGIN, UI_SIZE_TEXTFIELD_HEIGHT
	);
	self.textField.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_TEXTFIELD];
	self.textField.borderStyle = UITextBorderStyleRoundedRect;
	self.textField.keyboardAppearance = UIKeyboardAppearanceAlert;
	self.textField.keyboardType = UIKeyboardTypeNumberPad;
	self.textField.textAlignment = NSTextAlignmentCenter;
	self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	self.textField.text = [NSString stringWithFormat:@"%i", STEPPER_MIN_VALUE];
	
	frame = self.textField.frame;
	self.stepper.frame = CGRectMake(
		frame.origin.x + frame.size.width + UI_SIZE_MARGIN,
		(bounds.size.height - self.stepper.frame.size.height) / 2,
		self.stepper.frame.size.width, self.stepper.frame.size.height
	);
	self.stepper.minimumValue = STEPPER_MIN_VALUE;
	self.stepper.maximumValue = STEPPER_MAX_VALUE;
	self.stepper.delegate = self;
	
	self.descriptionLabel.text = NSLocalizedString(@"HEADCOUNT_DESCRIPTION_TEXT", nil);
	self.descriptionLabel.backgroundColor = [UIColor clearColor];
	self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
	self.descriptionLabel.textColor = [UIColor darkGrayColor];
	self.descriptionLabel.frame = CGRectMake(
		0, 0, 0, 0
	);
	
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


#pragma mark - Utility Functions


#pragma mark - Delegates
#pragma mark - RPVerticalStepperDelegate

- (void)stepperValueDidChange:(RPVerticalStepper *)stepper
{
	self.textField.text = [NSString stringWithFormat:@"%i", (int)stepper.value];
	
	// Change image based on number
	// TODO
}


@end
