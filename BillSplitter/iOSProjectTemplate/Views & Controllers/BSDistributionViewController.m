/**
	@file	BSDistributionViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSDistributionViewController.h"

#import "CustomPageControl.h"

	#define TABLEVIEW_ROW_ID @"RowCell"

	#define UI_SIZE_PAGECONTROL_HEIGHT 24
	#define UI_SIZE_LABEL_MARGIN 24
	#define UI_SIZE_MARGIN 16

	#define IMAGEVIEW_SCALE_SMALLDISH 0.7
	#define IMAGEVIEW_SCALE_MEDIUMDISH 0.8
	#define IMAGEVIEW_SCALE_LARGEDISH 1.0

	#define STEPPER_MIN_VALUE 1
	#define STEPPER_DEFAULT_VALUE_DRINK 9.0
	#define STEPPER_DEFAULT_VALUE_SMALLDISH 5.0
	#define STEPPER_DEFAULT_VALUE_MEDIUMDISH 15.0
	#define STEPPER_DEFAULT_VALUE_LARGEDISH 25.0

	#define IMG_DRINK @"drink.png"
	#define IMG_DISH @"plate.png"

@interface BSDistributionViewController () <CustomPageControlDelegate>

	@property (nonatomic, assign) CGRect frame;

	/** For sideswipping between diners */
	@property (nonatomic, strong) UIScrollView *scrollView;
	@property (nonatomic, strong) CustomPageControl *pageControl;

@end


#pragma mark - Implementation

@implementation BSDistributionViewController

/** @brief Initialize data-related properties */
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
	{
		_frame = frame;
		
		_numDiners = 1;
		
		_imageViews = [[NSMutableArray alloc] init];
		_textFields = [[NSMutableArray alloc] init];
		_steppers = [[NSMutableArray alloc] init];
		
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
	
	// Background view
	UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(
		0, bounds.size.height / 8, bounds.size.width, bounds.size.height * 1.5
	)];
	backgroundView.backgroundColor = UIColorFromHex(COLOR_HEX_ACCENT);
	[self.view addSubview:backgroundView];

	// Description label
	self.descriptionLabel.text = NSLocalizedString(@"DISTRIBUTION_DESCRIPTION_TEXT", nil);
	self.descriptionLabel.numberOfLines = 0;
	self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.descriptionLabel.backgroundColor = [UIColor clearColor];
	self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
	self.descriptionLabel.textColor = [UIColor lightGrayColor];
	self.descriptionLabel.font = [UIFont fontWithName:FONT_NAME_COPY size:FONT_SIZE_COPY];
	self.descriptionLabel.frame = CGRectMake(
		UI_SIZE_MARGIN, frame.origin.y + frame.size.height,
		bounds.size.width - UI_SIZE_MARGIN * 2, bounds.size.height / 8
	);
	
	[self.view addSubview:self.descriptionLabel];

	// ScrollView
	[self setupScrollView:bounds];
	[self setupPageControl:bounds];
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

/** @brief Returns one of the steppers used */
- (RPVerticalStepper *)stepperForTextField:(UITextField *)textField
{
	int index = [self.textFields indexOfObject:textField];
	return (self.steppers.count && index != NSNotFound)
		? [self.steppers objectAtIndex:index] : nil;
}

/** @brief When setting the number of diners, also update steppers maxes */
- (void)setNumDiners:(int)numDiners
{
	_numDiners = numDiners;
	
	// Update steppers
	[self updateSteppers];
}

/** @brief Updates all steppers with numDiners as max */
- (void)updateSteppers
{
	for (RPVerticalStepper *stepper in self.steppers) {
		stepper.maximumValue = self.numDiners;
	}
}

/** @brief Returns point offset for given page in scroll view */
- (CGFloat)offsetForPageInScrollView:(int)page
{
	return self.scrollView.bounds.size.width * page;
}


#pragma mark - UI Setup

/** @brief Setup scrollView */
- (void)setupScrollView:(CGRect)bounds
{
	self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(
		0, bounds.size.height / 8, bounds.size.width, bounds.size.height / 2
	)];
	self.scrollView.contentSize = CGSizeMake(bounds.size.width + 1, self.scrollView.bounds.size.height);
	self.scrollView.backgroundColor = [UIColor grayColor];
	self.scrollView.showsHorizontalScrollIndicator = false;
	self.scrollView.showsVerticalScrollIndicator = false;
	self.scrollView.clipsToBounds = false;
	self.scrollView.delegate = self;
	
	[self.view addSubview:self.scrollView];
}

/** @brief Setup page control */
- (void)setupPageControl:(CGRect)bounds
{
	CGRect frame = self.scrollView.frame;
	self.pageControl = [[CustomPageControl alloc] initWithFrame:CGRectMake(
		0, frame.origin.y + frame.size.height,
		bounds.size.width, UI_SIZE_PAGECONTROL_HEIGHT
	)];
	
	// Configure
	self.pageControl.delegate = self;
	self.pageControl.numberOfPages = 1;
	self.pageControl.currentPage = 0;
	self.pageControl.currentDotTintColor = UIColorFromHex(COLOR_HEX_COPY_DARK);
	self.pageControl.dotTintColor = UIColorFromHex(COLOR_HEX_NAVBAR_BUTTON);
	
	// Set images
	
	[self.view addSubview:self.pageControl];
}


#pragma mark - UI Events


#pragma mark - Utility Functions


#pragma mark - Delegates
#pragma mark - CustomPageControlDelegate

- (void)pageControlPageDidChange:(CustomPageControl *)pageControl
{
	CGRect frame = self.scrollView.bounds;
	frame.origin.x = [self offsetForPageInScrollView:pageControl.currentPage];
	[self.scrollView scrollRectToVisible:frame animated:true];	
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// Change page control accordingly:
	//	Update the page when more than 50% of the previous/next page is visible
    float pageSize = scrollView.bounds.size.height;
    int page = floor((scrollView.contentOffset.y - pageSize / 2) / pageSize) + 1;

	// Bound page limits
	if (page >= self.textFields.count) {
		page = self.textFields.count - 1;
	} else if (page < 0) {
		page = 0;
	}
		
    self.pageControl.currentPage = page;
}


@end
