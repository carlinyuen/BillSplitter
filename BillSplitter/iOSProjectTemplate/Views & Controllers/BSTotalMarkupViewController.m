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
	self.totalLabel.text = NSLocalizedString(@"TOTALMARKUP_TOTAL_LABEL", nil);
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
		CGRectGetMaxY(frame),
		bounds.size.width / 4 * 3 - UI_SIZE_MARGIN,
        bounds.size.height / 5
	);
	self.totalField.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_HEADCOUNT];
    self.totalField.textColor = [UIColor whiteColor];
	self.totalField.borderStyle = UITextBorderStyleNone;
	self.totalField.keyboardAppearance = UIKeyboardAppearanceAlert;
	self.totalField.keyboardType = UIKeyboardTypeNumberPad;
	self.totalField.textAlignment = NSTextAlignmentCenter;
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

/** @brief Setup Tax Fields */
- (void)setupTax:(CGRect)bounds
{
}

/** @brief Setup Tip Fields */
- (void)setupTip:(CGRect)bounds
{
}


#pragma mark - UI Events


#pragma mark - Utility Functions


#pragma mark - Delegates
#pragma mark - UIVerticalStepperDelegate

- (void)stepperValueDidChange:(UIVerticalStepper *)stepper
{
	NSString *value = [NSString stringWithFormat:@"$%.2f", stepper.value];
	
	if (stepper == self.totalStepper) {
		self.totalField.text = value;
	} else if (stepper == self.tipStepper) {
		self.tipField.text = value;
	}
}

@end
