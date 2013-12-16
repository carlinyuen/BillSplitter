/**
	@file	BSDishSetupViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSDishSetupViewController.h"

#import <QuartzCore/QuartzCore.h>

	#define UI_SIZE_LABEL_MARGIN 24
	#define UI_SIZE_MARGIN 16

	#define IMAGEVIEW_SCALE_SMALLDISH 0.7
	#define IMAGEVIEW_SCALE_MEDIUMDISH 0.8
	#define IMAGEVIEW_SCALE_LARGEDISH 1.0

	#define STEPPER_MIN_VALUE 0.0
	#define STEPPER_MAX_VALUE 9999999.99
	#define STEPPER_DEFAULT_VALUE_DRINK 9.0
	#define STEPPER_DEFAULT_VALUE_SMALLDISH 5.0
	#define STEPPER_DEFAULT_VALUE_MEDIUMDISH 15.0
	#define STEPPER_DEFAULT_VALUE_LARGEDISH 25.0

	#define IMG_DRINK @"drink.png"
	#define IMG_DISH1 @"dish1.png"
	#define IMG_DISH2 @"dish2.png"
	#define IMG_DISH3 @"dish3.png"

@interface BSDishSetupViewController ()

	@property (nonatomic, assign) CGRect frame;

@end


#pragma mark - Implementation

@implementation BSDishSetupViewController

/** @brief Initialize data-related properties */
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
	{
		_frame = frame;
		
		_drinkButton = [[UIButton alloc] initWithFrame:CGRectZero];
		_smallDishButton = [[UIButton alloc] initWithFrame:CGRectZero];
		_mediumDishButton = [[UIButton alloc] initWithFrame:CGRectZero];
		_largeDishButton = [[UIButton alloc] initWithFrame:CGRectZero];
		
		_drinkTextField = [[UITextField alloc] initWithFrame:CGRectZero];
		_smallDishTextField = [[UITextField alloc] initWithFrame:CGRectZero];
		_mediumDishTextField = [[UITextField alloc] initWithFrame:CGRectZero];
		_largeDishTextField = [[UITextField alloc] initWithFrame:CGRectZero];
		
		_drinkStepper = [[UIVerticalStepper alloc] initWithFrame:CGRectZero];
		_smallDishStepper = [[UIVerticalStepper alloc] initWithFrame:CGRectZero];
		_mediumDishStepper = [[UIVerticalStepper alloc] initWithFrame:CGRectZero];
		_largeDishStepper = [[UIVerticalStepper alloc] initWithFrame:CGRectZero];
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
	CGRect frame = CGRectZero;
    
	// Loop through and layout elements
	UIVerticalStepper *stepper;
	UIView *containerView;
	UIButton *button;
	UITextField *textField;
	float itemSize = (bounds.size.height / 5) - UI_SIZE_MARGIN;
	float stepperValue = 0;
	float scale = 1;
	for (int i = 0; i < BSDishSetupViewControllerItemCount; ++i)
	{
		// Setup variables
		switch (i)
		{
			case BSDishSetupViewControllerItemDrink:
				stepper = self.drinkStepper;
				textField = self.drinkTextField;
				button = self.drinkButton;
				[button setImage:[UIImage imageNamed:IMG_DRINK] forState:UIControlStateNormal];
				stepperValue = STEPPER_DEFAULT_VALUE_DRINK;
				scale = 1.0;
				break;

			case BSDishSetupViewControllerItemSmallDish:
				stepper = self.smallDishStepper;
				textField = self.smallDishTextField;
				button = self.smallDishButton;
				[button setImage:[UIImage imageNamed:IMG_DISH1] forState:UIControlStateNormal];
				stepperValue = STEPPER_DEFAULT_VALUE_SMALLDISH;
				scale = IMAGEVIEW_SCALE_SMALLDISH;
				break;

			case BSDishSetupViewControllerItemMediumDish:
				stepper = self.mediumDishStepper;
				textField = self.mediumDishTextField;
				button = self.mediumDishButton;
				[button setImage:[UIImage imageNamed:IMG_DISH2] forState:UIControlStateNormal];
				stepperValue = STEPPER_DEFAULT_VALUE_MEDIUMDISH;
				scale = IMAGEVIEW_SCALE_MEDIUMDISH;
				break;

			case BSDishSetupViewControllerItemLargeDish:
				stepper = self.largeDishStepper;
				textField = self.largeDishTextField;
				button = self.largeDishButton;
				[button setImage:[UIImage imageNamed:IMG_DISH3] forState:UIControlStateNormal];
				stepperValue = STEPPER_DEFAULT_VALUE_LARGEDISH;
				scale = IMAGEVIEW_SCALE_LARGEDISH;
				break;

			default: break;
		}
		
		// Create container view
		containerView = [[UIView alloc] initWithFrame:CGRectMake(
			0, CGRectGetMaxY(frame) + UI_SIZE_MARGIN,
			bounds.size.width, itemSize
		)];
		
		// Setup layout
		button.frame = CGRectMake(
			UI_SIZE_MARGIN / 2, 0,
			bounds.size.width / 4, itemSize
		);
		CGPoint center = button.center;
		button.imageView.contentMode = UIViewContentModeScaleAspectFit;
		button.clipsToBounds = true;
		button.transform = CGAffineTransformMakeScale(scale, scale);
		button.center = center;
		button.tag = i;
		[button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
		
		frame = button.frame;
		textField.frame = CGRectMake(
			bounds.size.width / 4 + UI_SIZE_MARGIN,
			(frame.size.height - itemSize) / 2 + frame.origin.y,
			bounds.size.width / 2, itemSize
		);
		textField.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_PRICE];
		textField.borderStyle = UITextBorderStyleNone;
		textField.keyboardAppearance = UIKeyboardAppearanceAlert;
		textField.keyboardType = UIKeyboardTypeNumberPad;
		textField.textAlignment = NSTextAlignmentCenter;
		textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		textField.adjustsFontSizeToFitWidth = true;
		textField.minimumFontSize = FONT_SIZE_PRICE / 3;
	 
        frame = textField.frame; 
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.text = @"≈";
        label.textColor = [UIColor lightGrayColor]; 
		label.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_PRICE];
		label.textAlignment = NSTextAlignmentCenter;
        [label sizeToFit];
        label.center = textField.center;
        frame = label.frame;
        frame.origin.x = CGRectGetMinX(textField.frame) - CGRectGetWidth(frame) / 2;
        label.frame = frame;
        [containerView addSubview:label];	
        
		frame = textField.frame;
		stepper.frame = CGRectMake(
			bounds.size.width - stepper.frame.size.width - UI_SIZE_LABEL_MARGIN,
			(frame.size.height - stepper.frame.size.height) / 2 + frame.origin.y,
			stepper.frame.size.width, stepper.frame.size.height
		);
		stepper.delegate = self;
		stepper.maximumValue = STEPPER_MAX_VALUE;
		stepper.minimumValue = STEPPER_MIN_VALUE;
		stepper.value = stepperValue;
		
		frame = containerView.frame;
		[containerView addSubview:stepper];
		[containerView addSubview:textField];
		[containerView addSubview:button];
		[self.view addSubview:containerView];
	}

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
	self.drinkStepper.value = STEPPER_DEFAULT_VALUE_DRINK;
	self.smallDishStepper.value = STEPPER_DEFAULT_VALUE_SMALLDISH;
	self.mediumDishStepper.value = STEPPER_DEFAULT_VALUE_MEDIUMDISH;
	self.largeDishStepper.value = STEPPER_DEFAULT_VALUE_LARGEDISH;
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
	if (textField == self.drinkTextField) {
		return self.drinkStepper;
	} else if (textField == self.smallDishTextField) {
		return self.smallDishStepper;
	} else if (textField == self.mediumDishTextField) {
		return self.mediumDishStepper;
	} else if (textField == self.largeDishTextField) {
		return self.largeDishStepper;
	} else {
		return nil;
	}
}


#pragma mark - UI Setup


#pragma mark - UI Events

- (void)buttonPressed:(UIButton *)sender
{
	debugFunc(sender);
}


#pragma mark - Utility Functions


#pragma mark - Delegates
#pragma mark - UIVerticalStepperDelegate

- (void)stepperValueDidChange:(UIVerticalStepper *)stepper
{
	NSString *value = [NSString stringWithFormat:@"$%.2f", stepper.value];
	
	if (stepper == self.drinkStepper) {
		self.drinkTextField.text = value;
	} else if (stepper == self.smallDishStepper) {
		self.smallDishTextField.text = value;
	} else if (stepper == self.mediumDishStepper) {
		self.mediumDishTextField.text = value;
	} else if (stepper == self.largeDishStepper) {
		self.largeDishTextField.text = value;
	}
	
	// Change image based on number
	// TODO
}


@end
