/**
	@file	BSTotalMarkupViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSTotalMarkupViewController.h"

    #define UI_SIZE_LABEL_MARGIN 24
	#define UI_SIZE_MARGIN 16
   
	#define STEPPER_TOTAL_MIN_VALUE 0.0
	#define STEPPER_TOTAL_MAX_VALUE 1000000.00
	#define STEPPER_TOTAL_DEFAULT_VALUE 0 

	#define STEPPER_TIP_MIN_VALUE 0.0
	#define STEPPER_TIP_MAX_VALUE 1000.00
	#define STEPPER_TIP_DEFAULT_VALUE 15 
    
@interface BSTotalMarkupViewController ()

	@property (nonatomic, assign) CGRect frame;

@end


#pragma mark - Implementation

@implementation BSTotalMarkupViewController

/** @brief Initialize data-related properties */
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
	{
		_frame = frame;
	
		_totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_totalField = [[UITextField alloc] initWithFrame:CGRectZero];
		_totalStepper = [[UIVerticalStepper alloc] initWithFrame:CGRectZero];
		
		_tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_tipField = [[UITextField alloc] initWithFrame:CGRectZero];
		_tipStepper = [[UIVerticalStepper alloc] initWithFrame:CGRectZero];
		
		_finalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
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
	
	// Setup
	[self setupTotal:bounds];
	[self setupTip:bounds];
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
	
	// Reset fields
}

/** @brief Return supported orientations */
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - Class Functions

/** @brief Returns one of the steppers used */
- (UIVerticalStepper *)stepperForTextField:(UITextField *)textField
{
	if (textField == self.totalField) {
		return self.totalStepper;
	} else if (textField == self.tipField) {
		return self.tipStepper;
	} else {
		return nil;
	}
}


#pragma mark - UI Setup

/** @brief Setup Total Fields */
- (void)setupTotal:(CGRect)bounds
{
    CGRect frame;
	self.totalLabel.text = [NSLocalizedString(@"TOTALMARKUP_TOTAL_LABEL", nil) uppercaseString];
	self.totalLabel.backgroundColor = [UIColor clearColor];
	self.totalLabel.textColor = [UIColor whiteColor];
	self.totalLabel.font = [UIFont fontWithName:FONT_NAME_TAGLINE size:FONT_SIZE_TAGLINE];
    [self.totalLabel sizeToFit];
    frame = self.totalLabel.frame;
    frame.origin.y = UI_SIZE_MARGIN;
    frame.origin.x = (bounds.size.width - frame.size.width) / 2;
    self.totalLabel.frame = frame;

	frame = self.totalLabel.frame;
	self.totalField.frame = CGRectMake(
		UI_SIZE_LABEL_MARGIN,
		(bounds.size.height / 3 - bounds.size.height / 5) / 2,
		bounds.size.width / 4 * 3 - UI_SIZE_MARGIN,
        bounds.size.height / 5
	);
	self.totalField.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_HEADCOUNT];
    self.totalField.textColor = [UIColor whiteColor];
	self.totalField.borderStyle = UITextBorderStyleNone;
	self.totalField.keyboardAppearance = UIKeyboardAppearanceAlert;
	self.totalField.keyboardType = UIKeyboardTypeNumberPad;
	self.totalField.textAlignment = NSTextAlignmentRight;
	self.totalField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.totalField.adjustsFontSizeToFitWidth = true;
    self.totalField.minimumFontSize = FONT_SIZE_HEADCOUNT / 3;
	
	frame = self.totalField.frame;
	self.totalStepper.frame = CGRectMake(
		bounds.size.width - self.totalStepper.frame.size.width - UI_SIZE_LABEL_MARGIN,
		(frame.size.height - self.totalStepper.frame.size.height) / 2 + frame.origin.y,
		self.totalStepper.frame.size.width, 
        self.totalStepper.frame.size.height
	);
	self.totalStepper.delegate = self;
	self.totalStepper.maximumValue = STEPPER_TOTAL_MAX_VALUE;
	self.totalStepper.minimumValue = STEPPER_TOTAL_MIN_VALUE;
	self.totalStepper.value = STEPPER_TOTAL_DEFAULT_VALUE;
	
	[self.view addSubview:self.totalLabel];
   	[self.view addSubview:self.totalField]; 
	[self.view addSubview:self.totalStepper];
}

/** @brief Setup Tip Fields */
- (void)setupTip:(CGRect)bounds
{
    CGRect frame;
    self.tipField.frame = CGRectMake(
		bounds.size.width / 2 - self.tipStepper.frame.size.width - UI_SIZE_MARGIN,
		bounds.size.height / 3,
		bounds.size.width / 2,
        bounds.size.height / 6
	);
	self.tipField.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_PRICE];
    self.tipField.textColor = [UIColor darkGrayColor];
	self.tipField.borderStyle = UITextBorderStyleNone;
	self.tipField.keyboardAppearance = UIKeyboardAppearanceAlert;
	self.tipField.keyboardType = UIKeyboardTypeNumberPad;
	self.tipField.textAlignment = NSTextAlignmentRight;
	self.tipField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.tipField.adjustsFontSizeToFitWidth = true;
    self.tipField.minimumFontSize = FONT_SIZE_PRICE / 3;
    
    UILabel *unitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UI_SIZE_MIN_TOUCH, UI_SIZE_MIN_TOUCH)];
    unitsLabel.text = @"%";
    unitsLabel.textColor = [UIColor darkGrayColor]; 
    unitsLabel.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_TAGLINE];
    unitsLabel.backgroundColor = [UIColor clearColor];
    self.tipField.rightViewMode = UITextFieldViewModeAlways;
    self.tipField.rightView = unitsLabel;
	  
    frame = self.tipField.frame;
	self.tipLabel.text = NSLocalizedString(@"TOTALMARKUP_TIP_LABEL", nil);
	self.tipLabel.backgroundColor = [UIColor clearColor];
	self.tipLabel.textColor = [UIColor darkGrayColor];
	self.tipLabel.font = [UIFont fontWithName:FONT_NAME_TAGLINE size:FONT_SIZE_TAGLINE];
    [self.tipLabel sizeToFit];
    frame = self.tipLabel.frame;
    frame.origin.y = CGRectGetMinY(self.tipField.frame) + (CGRectGetHeight(self.tipField.frame) - CGRectGetHeight(frame)) / 2;
    frame.origin.x = CGRectGetMinX(self.tipField.frame) - frame.size.width;
    self.tipLabel.frame = frame;
	
	frame = self.tipField.frame;
	self.tipStepper.frame = CGRectMake(
		bounds.size.width - self.tipStepper.frame.size.width - UI_SIZE_LABEL_MARGIN,
		(frame.size.height - self.tipStepper.frame.size.height) / 2 + frame.origin.y,
		self.tipStepper.frame.size.width, 
        self.tipStepper.frame.size.height
	);
	self.tipStepper.delegate = self;
	self.tipStepper.maximumValue = STEPPER_TIP_MAX_VALUE;
	self.tipStepper.minimumValue = STEPPER_TIP_MIN_VALUE;
	self.tipStepper.value = STEPPER_TIP_DEFAULT_VALUE;
	
	[self.view addSubview:self.tipLabel];
   	[self.view addSubview:self.tipField]; 
	[self.view addSubview:self.tipStepper];
}


#pragma mark - UI Events


#pragma mark - Utility Functions


#pragma mark - Delegates
#pragma mark - UIVerticalStepperDelegate

- (void)stepperValueDidChange:(UIVerticalStepper *)stepper
{
	if (stepper == self.totalStepper) {
		self.totalField.text = [NSString stringWithFormat:@"$%.2f", stepper.value];
	} else if (stepper == self.tipStepper) {
		self.tipField.text = [NSString stringWithFormat:@"%i", (int)stepper.value];
	}
}

@end
