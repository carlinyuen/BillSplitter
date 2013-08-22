/**
	@file	BSDishSetupViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSDishSetupViewController.h"

	#define UI_SIZE_LABEL_MARGIN 24
	#define UI_SIZE_MARGIN 16

	#define IMAGEVIEW_SCALE_SMALLDISH 0.7
	#define IMAGEVIEW_SCALE_MEDIUMDISH 0.8
	#define IMAGEVIEW_SCALE_LARGEDISH 1.0

	#define STEPPER_MIN_VALUE 0.0
	#define STEPPER_MAX_VALUE 9999999.99

	#define IMG_DRINK @"drink.png"
	#define IMG_DISH @"plate.png"

	typedef enum {
		BSDishSetupViewControllerItemDrink,
		BSDishSetupViewControllerItemSmallDish,
		BSDishSetupViewControllerItemMediumDish,
		BSDishSetupViewControllerItemLargeDish,
		BSDishSetupViewControllerItemCount
	} BSDishSetupViewControllerItem;

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
		
		_drinkIV = [[UIImageView alloc] initWithFrame:CGRectZero];
		_smallDishIV = [[UIImageView alloc] initWithFrame:CGRectZero];
		_mediumDishIV = [[UIImageView alloc] initWithFrame:CGRectZero];
		_largeDishIV = [[UIImageView alloc] initWithFrame:CGRectZero];
		
		_drinkTextField = [[UITextField alloc] initWithFrame:CGRectZero];
		_smallDishTextField = [[UITextField alloc] initWithFrame:CGRectZero];
		_mediumDishTextField = [[UITextField alloc] initWithFrame:CGRectZero];
		_largeDishTextField = [[UITextField alloc] initWithFrame:CGRectZero];
		
		_drinkStepper = [[RPVerticalStepper alloc] initWithFrame:CGRectZero];
		_smallDishStepper = [[RPVerticalStepper alloc] initWithFrame:CGRectZero];
		_mediumDishStepper = [[RPVerticalStepper alloc] initWithFrame:CGRectZero];
		_largeDishStepper = [[RPVerticalStepper alloc] initWithFrame:CGRectZero];
		
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
	CGRect frame = CGRectZero;

	// Loop through and layout elements
	RPVerticalStepper *stepper;
	UIImageView *imageView;
	UITextField *textField;
	float itemSize = (bounds.size.height / 5) - UI_SIZE_MARGIN * 2;
	float scale = 1;
	for (int i = 0; i < BSDishSetupViewControllerItemCount; ++i)
	{
		// Setup variables
		switch (i)
		{
			case BSDishSetupViewControllerItemDrink:
				stepper = self.drinkStepper;
				textField = self.drinkTextField;
				imageView = self.drinkIV;
				imageView.image = [UIImage imageNamed:IMG_DRINK];
				scale = 1.0;
				break;
				
			case BSDishSetupViewControllerItemSmallDish:
				stepper = self.smallDishStepper;
				textField = self.smallDishTextField;
				imageView = self.smallDishIV;
				imageView.image = [UIImage imageNamed:IMG_DISH];
				scale = IMAGEVIEW_SCALE_SMALLDISH;
				break;
				
			case BSDishSetupViewControllerItemMediumDish:
				stepper = self.mediumDishStepper;
				textField = self.mediumDishTextField;
				imageView = self.mediumDishIV;
				imageView.image = [UIImage imageNamed:IMG_DISH];
				scale = IMAGEVIEW_SCALE_MEDIUMDISH;
				break;
				
			case BSDishSetupViewControllerItemLargeDish:
				stepper = self.largeDishStepper;
				textField = self.largeDishTextField;
				imageView = self.largeDishIV;
				imageView.image = [UIImage imageNamed:IMG_DISH];
				scale = IMAGEVIEW_SCALE_LARGEDISH;
				break;
				
			default: break;
		}
		
		// Setup layout
		imageView.frame = CGRectMake(
			UI_SIZE_MARGIN,
			frame.origin.y + frame.size.height + UI_SIZE_MARGIN * 1.5,
			bounds.size.width / 4, itemSize
		);
		CGPoint center = imageView.center;
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.clipsToBounds = true;
		imageView.transform = CGAffineTransformMakeScale(scale, scale);
		imageView.center = center;
		
		frame = imageView.frame;
		textField.frame = CGRectMake(
			bounds.size.width / 4 + UI_SIZE_MARGIN / 2,
			(frame.size.height - itemSize) / 2 + frame.origin.y,
			bounds.size.width / 2, itemSize
		);
		textField.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_PRICE];
		textField.borderStyle = UITextBorderStyleRoundedRect;
		textField.keyboardAppearance = UIKeyboardAppearanceAlert;
		textField.keyboardType = UIKeyboardTypeNumberPad;
		textField.textAlignment = NSTextAlignmentCenter;
		textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		textField.text = @"0.00";
		
		frame = textField.frame;
		stepper.frame = CGRectMake(
			bounds.size.width - stepper.frame.size.width - UI_SIZE_LABEL_MARGIN,
			(frame.size.height - stepper.frame.size.height) / 2 + frame.origin.y,
			stepper.frame.size.width, stepper.frame.size.height
		);
		stepper.maximumValue = STEPPER_MAX_VALUE;
		stepper.minimumValue = STEPPER_MIN_VALUE;
		stepper.value = STEPPER_MIN_VALUE;
		stepper.delegate = self;
	}

	frame = imageView.frame;
	self.descriptionLabel.text = NSLocalizedString(@"DISHSETUP_DESCRIPTION_TEXT", nil);
	self.descriptionLabel.numberOfLines = 0;
	self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.descriptionLabel.backgroundColor = [UIColor clearColor];
	self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
	self.descriptionLabel.textColor = [UIColor lightGrayColor];
	self.descriptionLabel.font = [UIFont fontWithName:FONT_NAME_COPY size:FONT_SIZE_COPY];
	self.descriptionLabel.frame = CGRectMake(
		UI_SIZE_LABEL_MARGIN,
		frame.origin.y + frame.size.height + UI_SIZE_MARGIN,
		bounds.size.width - UI_SIZE_LABEL_MARGIN * 2,
		bounds.size.height - UI_SIZE_MARGIN
			- (frame.origin.y + frame.size.height + UI_SIZE_MARGIN)
	);

	[self.view addSubview:self.drinkIV];
	[self.view addSubview:self.smallDishIV];
	[self.view addSubview:self.mediumDishIV];
	[self.view addSubview:self.largeDishIV];
	
	[self.view addSubview:self.drinkStepper];
	[self.view addSubview:self.smallDishStepper];
	[self.view addSubview:self.mediumDishStepper];
	[self.view addSubview:self.largeDishStepper];
	
	[self.view addSubview:self.drinkTextField];
	[self.view addSubview:self.smallDishTextField];
	[self.view addSubview:self.mediumDishTextField];
	[self.view addSubview:self.largeDishTextField];
	
	[self.view addSubview:self.descriptionLabel];
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
