/**
	@file	BSHeadcountViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSHeadcountViewController.h"

	#define UI_SIZE_TAGLINELABEL_HEIGHT 36
	#define UI_SIZE_WELCOMELABEL_HEIGHT 64
	#define UI_SIZE_TEXTFIELD_HEIGHT 100
	#define UI_SIZE_LABEL_MARGIN 24
	#define UI_SIZE_MARGIN 16

	#define STEPPER_MIN_VALUE 1
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
		_stepper = [[UIVerticalStepper alloc] initWithFrame:CGRectZero];
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
	self.taglineLabel.backgroundColor = [UIColor whiteColor];
	self.taglineLabel.textAlignment = NSTextAlignmentCenter;
	self.taglineLabel.textColor = [UIColor darkGrayColor];
	self.taglineLabel.font = [UIFont fontWithName:FONT_NAME_TAGLINE size:FONT_SIZE_TAGLINE];
	self.taglineLabel.frame = CGRectMake(
		UI_SIZE_MARGIN, UI_SIZE_MARGIN,
		bounds.size.width - UI_SIZE_MARGIN * 2, UI_SIZE_TAGLINELABEL_HEIGHT
	);
	
	frame = self.taglineLabel.frame;
	self.welcomeLabel.text = NSLocalizedString(@"WELCOME_TEXT", nil);
	self.welcomeLabel.numberOfLines = 0;
	self.welcomeLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.welcomeLabel.backgroundColor = [UIColor whiteColor];
	self.welcomeLabel.textAlignment = NSTextAlignmentCenter;
	self.welcomeLabel.textColor = [UIColor lightGrayColor];
	self.welcomeLabel.font = [UIFont fontWithName:FONT_NAME_COPY size:FONT_SIZE_COPY];
	self.welcomeLabel.frame = CGRectMake(
		UI_SIZE_LABEL_MARGIN, frame.origin.y + frame.size.height,
		bounds.size.width - UI_SIZE_LABEL_MARGIN * 2, UI_SIZE_WELCOMELABEL_HEIGHT
	);
	
	frame = self.welcomeLabel.frame;
	self.imageView.frame = CGRectMake(
		UI_SIZE_MARGIN * 2, frame.origin.y + frame.size.height - UI_SIZE_MARGIN * 2,
		bounds.size.width / 4, bounds.size.height / 3 * 2
	);
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	self.imageView.image = [UIImage imageNamed:IMG_MAN];
	self.imageView.clipsToBounds = true;
	
	frame = self.imageView.frame;
	self.textField.frame = CGRectMake(
		frame.origin.x + frame.size.width,
		(frame.size.height - UI_SIZE_TEXTFIELD_HEIGHT) / 2 + frame.origin.y,
		bounds.size.width / 4 + UI_SIZE_MARGIN, UI_SIZE_TEXTFIELD_HEIGHT
	);
	self.textField.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_HEADCOUNT];
	self.textField.borderStyle = UITextBorderStyleNone;
	self.textField.keyboardAppearance = UIKeyboardAppearanceAlert;
	self.textField.keyboardType = UIKeyboardTypeNumberPad;
	self.textField.textAlignment = NSTextAlignmentRight;
	self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	frame = self.textField.frame;
	self.stepper.frame = CGRectMake(
		frame.origin.x + frame.size.width + UI_SIZE_MARGIN,
		(frame.size.height - self.stepper.frame.size.height) / 2 + frame.origin.y,
		self.stepper.frame.size.width, self.stepper.frame.size.height
	);
	self.stepper.delegate = self;
	self.stepper.maximumValue = STEPPER_MAX_VALUE;
	self.stepper.minimumValue = STEPPER_MIN_VALUE;
	self.stepper.value = STEPPER_MIN_VALUE;
	
	frame = self.imageView.frame;
	
	[self.view addSubview:self.taglineLabel];
	[self.view addSubview:self.welcomeLabel];
	[self.view addSubview:self.imageView];
	[self.view addSubview:self.stepper];
	[self.view addSubview:self.textField];
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
	
	// Reset values
	self.stepper.value = STEPPER_MIN_VALUE;
}

/** @brief Return supported orientations */
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - Class Functions


#pragma mark - Utility Functions


#pragma mark - Delegates
#pragma mark - UIVerticalStepperDelegate

- (void)stepperValueDidChange:(UIVerticalStepper *)stepper
{
	self.textField.text = [NSString stringWithFormat:@"%i", (int)stepper.value];
	
	// Change image based on number
	// TODO
}


@end
