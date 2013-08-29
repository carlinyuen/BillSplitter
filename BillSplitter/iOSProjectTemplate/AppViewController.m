/**
	@file	AppViewController.m
	@author	Carlin
	@date	7/12/13
	@brief	iOSProjectTemplate
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "AppViewController.h"

#import "ParallaxScrollingFramework.h"
#import "CustomPageControl.h"
#import "BSKeyboardControls.h"
#import "UIViewDebugger.h"

#import "InfoViewController.h"
#import "BSHeadcountViewController.h"
#import "BSDishSetupViewController.h"
#import "BSDistributionViewController.h"
#import "BSTotalMarkupViewController.h"
#import "BSSummaryViewController.h"

	#define UI_SIZE_INFO_BUTTON_MARGIN 8

	#define UI_SIZE_PAGECONTROL_WIDTH 24
	#define UI_SIZE_PAGECONTROL_HEIGHT 94
	
	typedef enum {
		AppViewControllerPageHeadCount,
		AppViewControllerPageDishes,
		AppViewControllerPageDistribution,
		AppViewControllerPageTotal,
		AppViewControllerPageSummary,
		AppViewControllerPageCount
	} AppViewControllerPage;


#pragma mark - Internal mini class for restricted navigation controller

@interface InfoViewNavigationController : UINavigationController @end
@implementation InfoViewNavigationController
	- (NSUInteger)supportedInterfaceOrientations {
		return UIInterfaceOrientationMaskPortrait;
	}
@end


#pragma mark - AppViewController

@interface AppViewController () <
	CustomPageControlDelegate,
	InfoViewControllerDelegate,
	BSKeyboardControlsDelegate
>

	/** For scrolling effect */
	@property (nonatomic, strong) ParallaxScrollingFramework *animator;
	@property (nonatomic, assign) bool enableAnimator;

	/** Main UI Elements */
	@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
	@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
	@property (nonatomic, strong) CustomPageControl *pageControl;
	@property (nonatomic, strong) BSKeyboardControls *keyboardControl;

	/** Controllers for user actions */
	@property (nonatomic, strong) NSArray *viewControllers;
	@property (nonatomic, strong) NSMutableArray *inputFields;

	/** Debuggin */
	@property (nonatomic, strong) UIViewDebugger *debugger;

	/** Keep track of which page you're on */
	@property (nonatomic, assign) AppViewControllerPage lastShownPage;

@end


#pragma mark - Implementation

@implementation AppViewController

/** @brief Initialize data-related properties */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
		// Input fields storage container
		_inputFields = [[NSMutableArray alloc] init];
		
		// Animator
		_enableAnimator = false;
		
		// Debugging
		_debugger = [[UIViewDebugger alloc] init];
    }
    return self;
}


#pragma mark - View Lifecycle

/** @brief Setup UI elements for viewing. */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Get device screen size
	CGRect bounds = getScreenFrame();
	bounds.origin.x = bounds.origin.y = 0;
	
	// UI Setup
	[self setupNavBar:bounds];
	[self setupScrollView:bounds];
	[self setupAnimation:bounds];
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
	return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - UI Setup

/** @brief Setup Nav bar */
- (void)setupNavBar:(CGRect)bounds
{
	// App title
	self.navBar.topItem.title = NSLocalizedString(@"APP_VIEW_TITLE", nil);
		
	// Color
	self.navBar.tintColor = UIColorFromHex(COLOR_HEX_ACCENT);
	self.navBar.translucent = true;

	// Info button
	UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	CGRect frame = infoButton.frame;
	frame.size.width += UI_SIZE_INFO_BUTTON_MARGIN;
	infoButton.frame = frame;
	[infoButton addTarget:self action:@selector(showInfo:)
			forControlEvents:UIControlEventTouchUpInside];
	[self.navBar.topItem setRightBarButtonItem:[[UIBarButtonItem alloc]
			initWithCustomView:infoButton] animated:true];
}

/** @brief Setup scrollview and its contents */
- (void)setupScrollView:(CGRect)bounds
{
	// Setup content size for scrolling
	self.scrollView.frame = bounds;
	self.scrollView.contentSize = CGSizeMake(
		bounds.size.width, bounds.size.height * AppViewControllerPageCount);

	
	// Create pages and populate reference array for view controllers
	NSMutableArray *vcs = [[NSMutableArray alloc] init];
	self.viewControllers = vcs;
	for (int i = 0; i < AppViewControllerPageCount; ++i)
	{
		switch (i) {
			case AppViewControllerPageHeadCount:
				[vcs addObject:[self setupHeadCount:bounds]]; break;
				
			case AppViewControllerPageDishes:
				[vcs addObject:[self setupDishes:bounds]]; break;
				
			case AppViewControllerPageDistribution:
				[vcs addObject:[self setupDistribution:bounds]]; break;
				
			case AppViewControllerPageTotal:
				[vcs addObject:[self setupTotalMarkup:bounds]]; break;
				
			case AppViewControllerPageSummary:
				[vcs addObject:[self setupSummary:bounds]]; break;
				
			default: break;
		}
	}
	
	[self setupPageControl:bounds];
	[self setupKeyboardControl];
}

/** @brief Setup headcount view */
- (UIViewController *)setupHeadCount:(CGRect)bounds
{
	BSHeadcountViewController *vc = [[BSHeadcountViewController alloc]
		initWithFrame:CGRectMake(
		0, [self offsetForPageInScrollView:AppViewControllerPageHeadCount] + UI_SIZE_MIN_TOUCH,
		bounds.size.width, bounds.size.height - UI_SIZE_MIN_TOUCH
	)];
	
	[self.inputFields addObject:vc.textField];
	vc.textField.tag = AppViewControllerPageHeadCount;
	vc.textField.delegate = self;
	
	[self.scrollView addSubview:vc.view];
	return vc;
}

/** @brief Setup dishes and costs view */
- (UIViewController *)setupDishes:(CGRect)bounds
{
	BSDishSetupViewController *vc = [[BSDishSetupViewController alloc]
		initWithFrame:CGRectMake(
		0, [self offsetForPageInScrollView:AppViewControllerPageDishes] + UI_SIZE_MIN_TOUCH,
		bounds.size.width, bounds.size.height - UI_SIZE_MIN_TOUCH
	)];
		
	[self.inputFields addObject:vc.drinkTextField];
	[self.inputFields addObject:vc.smallDishTextField];
	[self.inputFields addObject:vc.mediumDishTextField];
	[self.inputFields addObject:vc.largeDishTextField];
	vc.drinkTextField.tag = AppViewControllerPageDishes;
	vc.smallDishTextField.tag = AppViewControllerPageDishes;
	vc.mediumDishTextField.tag = AppViewControllerPageDishes;
	vc.largeDishTextField.tag = AppViewControllerPageDishes;
	vc.drinkTextField.delegate = self;
	vc.smallDishTextField.delegate = self;
	vc.mediumDishTextField.delegate = self;
	vc.largeDishTextField.delegate = self;
	
	[self.scrollView addSubview:vc.view];
	return vc;
}

/** @brief Setup distribution of dishes to people view */
- (UIViewController *)setupDistribution:(CGRect)bounds
{
	BSDistributionViewController *vc = [[BSDistributionViewController alloc]
		initWithFrame:CGRectMake(
		0, [self offsetForPageInScrollView:AppViewControllerPageDistribution] + UI_SIZE_MIN_TOUCH,
		bounds.size.width, bounds.size.height - UI_SIZE_MIN_TOUCH
	)];
	
	BSDishSetupViewController *dishes = [self.viewControllers objectAtIndex:AppViewControllerPageDishes];
	vc.drinkButton = dishes.drinkButton;
	vc.smallDishButton = dishes.smallDishButton;
	vc.mediumDishButton = dishes.mediumDishButton;
	vc.largeDishButton = dishes.largeDishButton;
	
	// Allow scrolling with drag & drop
	[vc.panGesture requireGestureRecognizerToFail:self.scrollView.panGestureRecognizer];
	
	[self.scrollView addSubview:vc.view];
	return vc;
}

/** @brief Setup total markup view view */
- (UIViewController *)setupTotalMarkup:(CGRect)bounds
{
	BSTotalMarkupViewController *vc = [[BSTotalMarkupViewController alloc]
		initWithFrame:CGRectMake(
		0, [self offsetForPageInScrollView:AppViewControllerPageTotal] + UI_SIZE_MIN_TOUCH,
		bounds.size.width, bounds.size.height - UI_SIZE_MIN_TOUCH
	)];
		
	[self.scrollView addSubview:vc.view];
	return vc;
}

/** @brief Setup summary & payments options view */
- (UIViewController *)setupSummary:(CGRect)bounds
{
	BSSummaryViewController *vc = [[BSSummaryViewController alloc]
		initWithFrame:CGRectMake(
		0, [self offsetForPageInScrollView:AppViewControllerPageSummary] + UI_SIZE_MIN_TOUCH,
		bounds.size.width, bounds.size.height - UI_SIZE_MIN_TOUCH
	)];
	
	vc.view.frame = CGRectMake(
		0, [self offsetForPageInScrollView:AppViewControllerPageSummary],
		bounds.size.width, bounds.size.height);
		
	[self.scrollView addSubview:vc.view];
	return vc;
}

/** @brief Setup page control for scrolling */
- (void)setupPageControl:(CGRect)bounds
{
	// Create and rotate to make vertical
	self.pageControl = [[CustomPageControl alloc] initWithFrame:CGRectMake(
		0, 0, UI_SIZE_PAGECONTROL_HEIGHT, UI_SIZE_PAGECONTROL_WIDTH
	)];
	self.pageControl.transform = CGAffineTransformMakeRotation(degreesToRadians(90));
	CGRect frame = self.pageControl.frame;
	frame.origin.y = bounds.size.height - frame.size.height;
	frame.origin.x = bounds.size.width - frame.size.width;
	self.pageControl.frame = frame;
	
	// Configure
	self.pageControl.delegate = self;
	self.pageControl.numberOfPages = AppViewControllerPageCount;
	self.pageControl.currentPage = AppViewControllerPageHeadCount;
	self.lastShownPage = AppViewControllerPageHeadCount;
	self.pageControl.currentDotTintColor = UIColorFromHex(COLOR_HEX_ACCENT);
	self.pageControl.dotTintColor = UIColorFromHex(COLOR_HEX_BACKGROUND_GRAY_TRANSLUCENT);
	
	// Set images
	
	[self.view addSubview:self.pageControl];
}

/** @brief Setup control for keyboard */
- (void)setupKeyboardControl
{
	self.keyboardControl = [[BSKeyboardControls alloc] initWithFields:self.inputFields];
	self.keyboardControl.delegate = self;
}

/** @brief Setup animation for scrolling */
- (void)setupAnimation:(CGRect)bounds
{
	self.animator = [[ParallaxScrollingFramework alloc] initWithScrollView:self.scrollView];
	self.animator.direction = ParallaxScrollingFrameworkDirectionVertical;
	
	CGRect refFrame, targetFrame;
	CGPoint tempPoint, targetPoint;
	CGSize tempSize, targetSize;
	CGAffineTransform transform;
	float yOffset = 0, xOffset = 0;
	float yTempOffset = 0, xTempOffset = 0;
	float difference = 0, temp = 0;
	
	BSHeadcountViewController *headCount = [self.viewControllers objectAtIndex:AppViewControllerPageHeadCount];
	BSDishSetupViewController *dishSetup = [self.viewControllers objectAtIndex:AppViewControllerPageDishes];
	BSDistributionViewController *distribution = [self.viewControllers objectAtIndex:AppViewControllerPageDistribution];
	BSTotalMarkupViewController *total = [self.viewControllers objectAtIndex:AppViewControllerPageTotal];
	BSSummaryViewController *summary = [self.viewControllers objectAtIndex:AppViewControllerPageSummary];


	/////////////////////////////////////////////
	// Headcount Page
	yOffset = [self offsetForPageInScrollView:AppViewControllerPageHeadCount];
		
	[self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, 0)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:headCount.stepper
	];
	[self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, 0)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:headCount.textField
	];
	[self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, 0)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:headCount.imageView
	];
	
	// Animate out sideways
	difference = bounds.size.height / 2;
	[self.animator setKeyFrameWithOffset: yOffset + difference
		translate:CGPointMake(bounds.size.width, difference)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:headCount.stepper
	];
	[self.animator setKeyFrameWithOffset: yOffset + difference
		translate:CGPointMake(bounds.size.width, difference)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:headCount.textField
	];
	[self.animator setKeyFrameWithOffset: yOffset + difference
		translate:CGPointMake(-bounds.size.width, difference)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:headCount.imageView
	];
	

	/////////////////////////////////////////////
	// Dish Setup Page
	yOffset = [self offsetForPageInScrollView:AppViewControllerPageDishes];
	xOffset = (bounds.size.width - UI_SIZE_MIN_TOUCH) / 4;
	refFrame = dishSetup.view.frame;
	
	NSArray *elements = [NSArray arrayWithObjects:
		dishSetup.drinkStepper,
		dishSetup.drinkTextField,
		dishSetup.smallDishStepper,
		dishSetup.smallDishTextField,
		dishSetup.mediumDishStepper,
		dishSetup.mediumDishTextField,
		dishSetup.largeDishStepper,
		dishSetup.largeDishTextField,
		nil];

	// Starting point
	for (UIView *element in elements) {
		[self.animator setKeyFrameWithOffset: yOffset
			translate:CGPointMake(0, 0)
			scale:CGSizeMake(1, 1)
			rotate:0
			alpha:1
			forView:element
		];
	}
	[self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, 0)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:dishSetup.descriptionLabel
	];

	// Move with scroll for a bit
	difference = bounds.size.height / 8;
	for (int i = 0; i < elements.count; ++i) {
		[self.animator setKeyFrameWithOffset: yOffset + difference + (UI_SIZE_MIN_TOUCH * (i/2))
			translate:CGPointMake(0, difference + (UI_SIZE_MIN_TOUCH * (i/2)))
			scale:CGSizeMake(1, 1)
			rotate:0
			alpha:1
			forView:[elements objectAtIndex:i]
		];
	}
	[self.animator setKeyFrameWithOffset: yOffset + difference
		translate:CGPointMake(0, 0)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:0
		forView:dishSetup.descriptionLabel
	];
	
	// Hide
	difference = bounds.size.height / 4;
	for (int i = 0; i < elements.count; ++i) {
		[self.animator setKeyFrameWithOffset: yOffset + difference + (UI_SIZE_MIN_TOUCH * (i/2))
			translate:CGPointMake(0, 0)
			scale:CGSizeMake(1, 1)
			rotate:0
			alpha:0
			forView:[elements objectAtIndex:i]
		];
	}
	

	/////////////////////////////////////////////
	// Distribution Page
	yTempOffset = [self offsetForPageInScrollView:AppViewControllerPageDistribution];
	
	// Distribution description
	[self.animator setKeyFrameWithOffset: yTempOffset
		translate:CGPointMake(0, 0)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:distribution.descriptionLabel
	];
	[self.animator setKeyFrameWithOffset: yTempOffset + bounds.size.height / 3
		translate:CGPointMake(0, bounds.size.height / 3)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:distribution.descriptionLabel
	];
	
	// Distribution instructions
	[self.animator setKeyFrameWithOffset: yTempOffset
		translate:CGPointMake(0, 0)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:distribution.instructionLabel
	];
	[self.animator setKeyFrameWithOffset: yTempOffset + bounds.size.height / 6
		translate:CGPointMake(0, bounds.size.height / 6)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:0
		forView:distribution.instructionLabel
	];
	
	// Drink
	temp = UI_SIZE_MIN_TOUCH + bounds.size.height / 7;
	transform = dishSetup.drinkButton.transform;
	tempSize = CGSizeMake(transform.a, transform.d);
	targetSize = CGSizeMake(tempSize.width * 1.2, tempSize.height * 1.2);
	difference = 0;
	[self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, 0)
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.drinkButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + UI_SIZE_MIN_TOUCH
		translate:CGPointMake(-7, UI_SIZE_MIN_TOUCH)
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.drinkButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height / 4
		translate:CGPointMake(-10, bounds.size.height / 4)
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.drinkButton
	];
	targetFrame = [dishSetup.view convertRect:dishSetup.drinkButton.frame fromView:dishSetup.drinkButton.superview];
	targetPoint.y = refFrame.size.height - CGRectGetMaxY(targetFrame) + temp;
	targetPoint.x = 0;
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height / 2
		translate:targetPoint
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.drinkButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height / 2 + UI_SIZE_MIN_TOUCH
		translate:targetPoint
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.drinkButton
	];
	[self.animator setKeyFrameWithOffset: yTempOffset
		translate:targetPoint
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.drinkButton
	];
	targetPoint.y += bounds.size.height / 3;
	[self.animator setKeyFrameWithOffset: yTempOffset + bounds.size.height / 3
		translate:targetPoint
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.drinkButton
	];
	
	// Small dish
	transform = dishSetup.smallDishButton.transform;
	tempSize = CGSizeMake(transform.a, transform.d);
	targetSize = CGSizeMake(tempSize.width * 1.2, tempSize.height * 1.2);
	targetPoint = CGPointMake(0, UI_SIZE_MIN_TOUCH);
	difference = UI_SIZE_MIN_TOUCH / 4;
	[self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, 0)
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.smallDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + UI_SIZE_MIN_TOUCH + difference
		translate:CGPointMake(-7, UI_SIZE_MIN_TOUCH + difference)
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.smallDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height / 4 + difference
		translate:CGPointMake(-10, bounds.size.height / 4 + difference)
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.smallDishButton
	];
	targetFrame = [dishSetup.view convertRect:dishSetup.smallDishButton.frame fromView:dishSetup.smallDishButton.superview];
	targetPoint.y = refFrame.size.height - CGRectGetMaxY(targetFrame) + temp;
	targetPoint.x = 1 * xOffset;
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height / 2 
		translate:targetPoint
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.smallDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height / 2 + UI_SIZE_MIN_TOUCH
		translate:targetPoint
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.smallDishButton
	];
	[self.animator setKeyFrameWithOffset: yTempOffset
		translate:targetPoint
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.smallDishButton
	];
	targetPoint.y += bounds.size.height / 3;
	[self.animator setKeyFrameWithOffset: yTempOffset + bounds.size.height / 3
		translate:targetPoint
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.smallDishButton
	];
	
	// Medium dish
	transform = dishSetup.mediumDishButton.transform;
	tempSize = CGSizeMake(transform.a, transform.d);
	targetSize = CGSizeMake(tempSize.width * 1.2, tempSize.height * 1.2);
	targetPoint = CGPointMake(0, UI_SIZE_MIN_TOUCH);
	difference = UI_SIZE_MIN_TOUCH / 2;
	[self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, 0)
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.mediumDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + UI_SIZE_MIN_TOUCH + difference
		translate:CGPointMake(-7, UI_SIZE_MIN_TOUCH + difference)
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.mediumDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height / 4 + difference
		translate:CGPointMake(-10, bounds.size.height / 4 + difference)
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.mediumDishButton
	];
	targetFrame = [dishSetup.view convertRect:dishSetup.mediumDishButton.frame fromView:dishSetup.mediumDishButton.superview];
	targetPoint.y = refFrame.size.height - CGRectGetMaxY(targetFrame) + temp;
	targetPoint.x = 2 * xOffset;
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height / 2
		translate:targetPoint
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.mediumDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height / 2 + UI_SIZE_MIN_TOUCH
		translate:targetPoint
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.mediumDishButton
	];
	[self.animator setKeyFrameWithOffset: yTempOffset
		translate:targetPoint
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.mediumDishButton
	];
	targetPoint.y += bounds.size.height / 3;
	[self.animator setKeyFrameWithOffset: yTempOffset + bounds.size.height / 3
		translate:targetPoint
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.mediumDishButton
	];
	
	// Large dish
	transform = dishSetup.largeDishButton.transform;
	tempSize = CGSizeMake(transform.a, transform.d);
	targetSize = CGSizeMake(tempSize.width * 1.2, tempSize.height * 1.2);
	targetPoint = CGPointMake(0, UI_SIZE_MIN_TOUCH);
	difference = UI_SIZE_MIN_TOUCH / 4 * 3;
	[self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, 0)
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.largeDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + UI_SIZE_MIN_TOUCH + difference
		translate:CGPointMake(-7, UI_SIZE_MIN_TOUCH + difference)
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.largeDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height / 4 + difference
		translate:CGPointMake(-10, bounds.size.height / 4 + difference)
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.largeDishButton
	];
	targetFrame = [dishSetup.view convertRect:dishSetup.largeDishButton.frame fromView:dishSetup.largeDishButton.superview];
	targetPoint.y = refFrame.size.height - CGRectGetMaxY(targetFrame) + temp;
	targetPoint.x = 3 * xOffset;
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height / 2
		translate:targetPoint
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.largeDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height / 2 + UI_SIZE_MIN_TOUCH
		translate:targetPoint
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.largeDishButton
	];
	[self.animator setKeyFrameWithOffset: yTempOffset
		translate:targetPoint
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.largeDishButton
	];
	targetPoint.y += bounds.size.height / 3;
	[self.animator setKeyFrameWithOffset: yTempOffset + bounds.size.height / 3
		translate:targetPoint
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.largeDishButton
	];
	

	/////////////////////////////////////////////
	// Total Markup Page
}


#pragma mark - Class Functions

/** @brief Returns point offset for given page in scroll view */
- (CGFloat)offsetForPageInScrollView:(AppViewControllerPage)page
{
	return self.scrollView.bounds.size.height * page;
}

/** @brief Set textfield cursor position */
- (void)selectRangeInTextField:(UITextField *)input atRange:(NSRange)range
{
	UITextPosition *start = [input
		positionFromPosition:[input beginningOfDocument] offset:range.location];
    UITextPosition *end = [input
		positionFromPosition:start offset:range.length];
    [input setSelectedTextRange:[input
		textRangeFromPosition:start toPosition:end]];
}

/** @brief Update pages that need to depends on other pages' data */
- (void)updatePages
{
	BSHeadcountViewController *headCount = [self.viewControllers objectAtIndex:AppViewControllerPageHeadCount];
	BSDistributionViewController *distribution = [self.viewControllers objectAtIndex:AppViewControllerPageDistribution];
	
	// Update distribution page
	distribution.headCount = headCount.stepper.value;
	
	// Page-based update
	switch (self.pageControl.currentPage)
	{
		case AppViewControllerPageDistribution:
			self.pageControl.currentDotTintColor = [UIColor whiteColor];
			self.scrollView.delaysContentTouches = false;
			break;
		
		default:
			self.pageControl.currentDotTintColor = UIColorFromHex(COLOR_HEX_ACCENT);
			self.scrollView.delaysContentTouches = true;
			break;
	}
}


#pragma mark - UI Event Handlers

/** @brief Info button pressed */
- (void)showInfo:(id)sender
{
	InfoViewController *controller = [[InfoViewController alloc] init];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:[[InfoViewNavigationController alloc] initWithRootViewController:controller]
		animated:YES completion:nil];
}


#pragma mark - Delegates
#pragma mark - CustomPageControlDelegate

/** @brief When page control dot is tapped */
- (void)pageControlPageDidChange:(CustomPageControl *)pageControl
{
	CGRect frame = self.scrollView.bounds;
	frame.origin.y = [self offsetForPageInScrollView:pageControl.currentPage];
	[self.scrollView scrollRectToVisible:frame animated:true];
}


#pragma mark - BSKeyboardControlsDelegate

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [keyboardControls.activeField resignFirstResponder];
	
	// Re-enable animator
	self.enableAnimator = true;
	
	// Scroll back to normal page position
	[self.scrollView scrollRectToVisible:CGRectMake(
		0, [self offsetForPageInScrollView:self.lastShownPage],
		self.scrollView.bounds.size.width, self.scrollView.bounds.size.height
	) animated:true];
}

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
	// To prevent stuttering of scrolling
	self.scrollView.pagingEnabled = false;
	self.animator.enabled = false;
	
	// Animate scroll so field is visible above keyboard
	CGRect frame = [self.scrollView convertRect:field.frame fromView:field.superview];
	frame = CGRectMake(
		frame.origin.x, frame.origin.y - UI_SIZE_MIN_TOUCH * 3,
		self.scrollView.bounds.size.width, self.scrollView.bounds.size.height
	);
    [self.scrollView scrollRectToVisible:frame animated:YES];
	
	// Change last shown page based on which field
	self.lastShownPage = field.tag;
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	// To prevent stuttering of scrolling
	self.scrollView.pagingEnabled = false;
	self.animator.enabled = false;
	
	// Animate scroll so field is visible above keyboard
	CGRect frame = [self.scrollView convertRect:textField.frame fromView:textField.superview];
	frame = CGRectMake(
		frame.origin.x, frame.origin.y - UI_SIZE_MIN_TOUCH * 3,
		self.scrollView.bounds.size.width, self.scrollView.bounds.size.height
	);
    [self.scrollView scrollRectToVisible:frame animated:YES];
	
    [self.keyboardControl setActiveField:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	// Stepper to update
	UIVerticalStepper *stepper;
	switch (textField.tag)
	{
		// If integer type (headcount)
		case AppViewControllerPageHeadCount:
		{
			stepper = [[self.viewControllers objectAtIndex:textField.tag] stepper];
			
			// Get new text, add user entered text & replace $ signs and periods
			NSString *newText = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByReplacingOccurrencesOfString:@"$" withString:@""];
	
			// Make sure is a number
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
			NSNumber *number = [formatter numberFromString:newText];
				
			// Restrict value
			if (!number) {
				number = [NSNumber numberWithFloat:stepper.minimumValue];
			} else if (number.floatValue > stepper.maximumValue) {
				number = [NSNumber numberWithFloat:stepper.maximumValue];
			} else if (number.floatValue < 0) {
				number = [NSNumber numberWithFloat:stepper.minimumValue];
			}
			
			// Set stepper value, always to integer
			stepper.value = number.intValue;
			textField.text = [NSString stringWithFormat:@"%i", number.intValue];
			
			return NO;
		}

		// Price type (dish setup & total markup)
		case AppViewControllerPageTotal:
			stepper = [[self.viewControllers objectAtIndex:textField.tag] stepper];
		case AppViewControllerPageDishes:
		{
			if (!stepper) {
				stepper = [[self.viewControllers objectAtIndex:textField.tag] stepperForTextField:textField];
			}
			
			// Look for zeros in the decimal places so we can replace them
			NSString *currentText = textField.text;
			NSRange zeroDecimalRange = [currentText rangeOfString:@"0"
				options:NSCaseInsensitiveSearch
				range:NSMakeRange(currentText.length - 2, 2)];
				
			// If first zero is in tenths decimal place, need to make sure
			//	there is a zero in the hundredths decimal place
			bool hasZeroHundredthsDigit = (
				(zeroDecimalRange.location == currentText.length - 1)
				|| NSNotFound != [currentText rangeOfString:@"0"
					options:NSCaseInsensitiveSearch
					range:NSMakeRange(currentText.length - 1, 1)].location
			);
			
			// If they're trying to add another zero, means they want to shift
			bool userEnteredZero = [string isEqualToString:@"0"];
				
			// See if user is trying to add a number after the decimal point
			bool userEnteredAfterDecimalPoint = (range.location >= currentText.length - 2);
			
			// Get new text, if user was adding numbers at end
			//	and zero found in decimal place and user not adding a zero,
			//	then replace with number user typed,
			//	otherwise just shift number up and replace $ and periods
			NSMutableString *newText = [[[[currentText
				stringByReplacingCharactersInRange:(
					(!userEnteredZero
						&& userEnteredAfterDecimalPoint
						&& hasZeroHundredthsDigit
						&& zeroDecimalRange.location != NSNotFound)
						? zeroDecimalRange : range)
					withString:string]
				stringByReplacingOccurrencesOfString:@"$" withString:@""]
				stringByReplacingOccurrencesOfString:@"." withString:@""] mutableCopy];
			
			// Add in decimal point now
			[newText insertString:@"." atIndex:newText.length - 2];
	
			// Make sure is a number
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
			NSNumber *number = [formatter numberFromString:newText];
			
			// Restrict value	
			if (!number) {
				number = [NSNumber numberWithFloat:stepper.minimumValue];
			} else if (number.floatValue > stepper.maximumValue) {
				number = [NSNumber numberWithFloat:stepper.maximumValue];
			} else if (number.floatValue < 0) {
				number = [NSNumber numberWithFloat:stepper.minimumValue];
			}
			
			// Set stepper value
			stepper.value = number.floatValue;
			textField.text = [NSString stringWithFormat:@"$%.2f", number.floatValue];
			
			return NO;
		}
		
		default:
			break;
	}
	return YES;
}


#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.keyboardControl setActiveField:textView];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// Change page control accordingly:
	//	Update the page when more than 50% of the previous/next page is visible
    float pageSize = scrollView.bounds.size.height;
    int page = floor((scrollView.contentOffset.y - pageSize / 2) / pageSize) + 1;

	// Bound page limits
	if (page >= AppViewControllerPageCount) {
		page = AppViewControllerPageCount - 1;
	} else if (page < 0) {
		page = 0;
	}
		
	// If page is not the same as lastShownPage, let page know it'll be shown
	if (self.lastShownPage != page) {
		[[self.viewControllers objectAtIndex:page] viewWillAppear:true];
		[[self.viewControllers objectAtIndex:self.lastShownPage] viewWillDisappear:true];
	}
	
    self.pageControl.currentPage = page;
	[self updatePages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (self.lastShownPage != self.pageControl.currentPage) {
		self.lastShownPage = self.pageControl.currentPage;
		[self updatePages];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	if (self.enableAnimator) {
		self.animator.enabled = true;
		self.enableAnimator = false;
		self.scrollView.contentOffset = self.scrollView.contentOffset;
	}
	
	// Re-enable paging once done with animation
	self.scrollView.pagingEnabled = true;
}

#pragma mark - InfoViewControllerDelegate

- (void)infoViewController:(InfoViewController *)vc willCloseAnimated:(bool)animated
{
	[self dismissViewControllerAnimated:animated completion:nil];
}


@end
