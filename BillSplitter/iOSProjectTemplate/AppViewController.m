/**
	@file	AppViewController.m
	@author	Carlin
	@date	7/12/13
	@brief	iOSProjectTemplate
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "AppViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "ParallaxScrollingFramework.h"
#import "CustomPageControl.h"
#import "BSKeyboardControls.h"
#import "UIViewDebugger.h"

#import "BSScrollView.h"
#import "InfoViewController.h"
#import "BSHeadcountViewController.h"
#import "BSDishSetupViewController.h"
#import "BSDistributionViewController.h"
#import "BSTotalMarkupViewController.h"
#import "BSSummaryViewController.h"

	#define UI_SIZE_INFO_BUTTON_MARGIN 8
	#define UI_SIZE_RESET_BUTTON_HEIGHT 16
	#define UI_SIZE_RESET_BUTTON_MARGIN 8 
	#define UI_SIZE_CORNER_RADIUS 12
	#define UI_SIZE_PAGECONTROL_WIDTH 24
	#define UI_SIZE_PAGECONTROL_HEIGHT 94

	#define IMG_RESET @"reset.png"
	#define IMG_RESET_PRESSED @"reset_pressed.png"

	typedef enum {
		AppViewControllerPageHeadCount,
        AppViewControllerPageTotal, 
		AppViewControllerPageDishes,
		AppViewControllerPageDistribution,
		AppViewControllerPageSummary,
		AppViewControllerPageCount
	} AppViewControllerPage;


#pragma mark - Internal mini class for restricted navigation controller

@interface InfoViewNavigationController : UINavigationController @end
@implementation InfoViewNavigationController
    - (void)viewDidLoad {
        [super viewDidLoad];
        
    }
	- (NSUInteger)supportedInterfaceOrientations {
		return UIInterfaceOrientationMaskPortrait;
	}
@end


#pragma mark - AppViewController

@interface AppViewController () <
	CustomPageControlDelegate,
	InfoViewControllerDelegate,
    BSHeadcountViewControllerDelegate,
    BSDistributionViewControllerDelegate,
	BSKeyboardControlsDelegate,
    BSScrollViewDelegate
>

	/** For scrolling effect */
	@property (nonatomic, strong) ParallaxScrollingFramework *animator;
	@property (nonatomic, assign) bool enableAnimator;

	/** Main UI Elements */
	@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
	@property (weak, nonatomic) IBOutlet BSScrollView *scrollView;
	@property (nonatomic, strong) CustomPageControl *pageControl;
	@property (nonatomic, strong) BSKeyboardControls *keyboardControl;
	@property (nonatomic, strong) UIButton *resetButton;
    
    @property (nonatomic, strong) NSNumberFormatter *numberFormatter;

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
        
        // Formatter
        _numberFormatter = [NSNumberFormatter new];
        [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle]; 
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
    if (getDeviceOSVersionNumber() >= 7) {
        bounds.size.height += bounds.origin.y;  // Adjust for status bar
    } else {
        bounds.origin.y = 0;
    }
	bounds.origin.x = 0;
	
	// Setup view
	self.view.layer.cornerRadius = UI_SIZE_CORNER_RADIUS;
	self.view.clipsToBounds = true;
	
	// UI Setup
	[self setupNavBar:bounds];
	[self setupScrollView:bounds];
	[self setupAnimation:bounds];
}

/** @brief Last-minute setup before view appears. */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
   	
	// Get device screen size
	CGRect bounds = getScreenFrame();
    if (getDeviceOSVersionNumber() >= 7) {
        bounds.size.height += bounds.origin.y;
    } else {
        bounds.origin.y = 0; 
    }
	bounds.origin.x = 0;
    self.scrollView.frame = bounds;
    
    [self updatePages];
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
    bool isIOS7 = (getDeviceOSVersionNumber() >= 7);
    if (isIOS7)
    {
        [self.navBar setBarTintColor:UIColorFromHex(COLOR_HEX_NAVBAR_iOS7)]; 
        [self.navBar setTintColor:[UIColor whiteColor]];
        [self.navBar setTitleTextAttributes:@{
            UITextAttributeTextColor: [UIColor whiteColor],
        }];
       	CGRect frame = self.navBar.frame; 
        frame.size.height += 20;
        self.navBar.frame = frame;
    } 
    else {
        self.navBar.tintColor = UIColorFromHex(COLOR_HEX_ACCENT); 
       	self.navBar.translucent = true; 
    }

	// Info button
	UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	CGRect frame = infoButton.frame;
	frame.size.width += (!isIOS7) ? UI_SIZE_INFO_BUTTON_MARGIN : 0;
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
//    self.scrollView.bsDelegate = self;
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
	[self setupResetButton:bounds];
}

/** @brief Setup headcount view */
- (UIViewController *)setupHeadCount:(CGRect)bounds
{
	BSHeadcountViewController *vc = [[BSHeadcountViewController alloc]
		initWithFrame:CGRectMake(
		0, [self offsetForPageInScrollView:AppViewControllerPageHeadCount] + UI_SIZE_MIN_TOUCH,
		bounds.size.width, bounds.size.height - UI_SIZE_MIN_TOUCH
	)];
    vc.delegate = self;
	
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
		bounds.size.width, bounds.size.height - UI_SIZE_MIN_TOUCH - bounds.origin.y
	)];
    vc.delegate = self;
	
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
	
    BSHeadcountViewController *headCountVC = [self.viewControllers objectAtIndex:AppViewControllerPageHeadCount];  
    vc.headCountStepper = headCountVC.stepper;
    
	[self.inputFields addObject:vc.totalField];
	[self.inputFields addObject:vc.tipField];
//   	[self.inputFields addObject:vc.tipAmountField]; 
	vc.totalField.tag = AppViewControllerPageTotal;
	vc.tipField.tag = AppViewControllerPageTotal;
   	vc.tipAmountField.tag = AppViewControllerPageTotal; 
	vc.totalField.delegate = self;
	vc.tipField.delegate = self;	
   	vc.tipAmountField.delegate = self;	 
    
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
	
    BSTotalMarkupViewController *totalVC = [self.viewControllers objectAtIndex:AppViewControllerPageTotal]; 
    BSDishSetupViewController *dishesVC = [self.viewControllers objectAtIndex:AppViewControllerPageDishes];  
    BSDistributionViewController *distributionVC = [self.viewControllers objectAtIndex:AppViewControllerPageDistribution];  
    vc.finalLabel = totalVC.finalLabel;
    vc.drinkStepper = dishesVC.drinkStepper;
    vc.smallDishStepper = dishesVC.smallDishStepper; 
    vc.mediumDishStepper = dishesVC.mediumDishStepper; 
    vc.largeDishStepper = dishesVC.largeDishStepper; 
    vc.profiles = distributionVC.profiles;
    vc.profileScrollView = distributionVC.profileScrollView;
    vc.profilePageControl = distributionVC.profilePageControl; 
        
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
	self.pageControl.dotTintColor = UIColorFromHex(COLOR_HEX_BACKGROUND_DARK_GRAY_TRANSLUCENT);
	
	// Set images
	
	[self.view addSubview:self.pageControl];
}

/** @brief Setup control for keyboard */
- (void)setupKeyboardControl
{
	self.keyboardControl = [[BSKeyboardControls alloc] initWithFields:self.inputFields];
	self.keyboardControl.delegate = self;
}

/** @brief Setup reset button */
- (void)setupResetButton:(CGRect)bounds
{
	self.resetButton = [[UIButton alloc] initWithFrame:CGRectMake(
		UI_SIZE_RESET_BUTTON_MARGIN,
		bounds.size.height - UI_SIZE_RESET_BUTTON_HEIGHT - UI_SIZE_RESET_BUTTON_MARGIN,
		UI_SIZE_RESET_BUTTON_HEIGHT, UI_SIZE_RESET_BUTTON_HEIGHT
	)];
	[self.resetButton setBackgroundImage:[UIImage imageNamed:IMG_RESET]
		forState:UIControlStateNormal];
	[self.resetButton setBackgroundImage:[UIImage imageNamed:IMG_RESET_PRESSED]
		forState:UIControlStateHighlighted];
	self.resetButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.resetButton addTarget:self action:@selector(resetButtonPressed:)
		forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.resetButton];
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
	CGFloat yOffset = 0, xOffset = 0;
	CGFloat yTempOffset = 0;
	CGFloat difference = 0, temp = 0;
	
	BSHeadcountViewController *headCount = [self.viewControllers objectAtIndex:AppViewControllerPageHeadCount];
	BSDishSetupViewController *dishSetup = [self.viewControllers objectAtIndex:AppViewControllerPageDishes];
	BSDistributionViewController *distribution = [self.viewControllers objectAtIndex:AppViewControllerPageDistribution];
	BSTotalMarkupViewController *totalMarkup = [self.viewControllers objectAtIndex:AppViewControllerPageTotal];
	BSSummaryViewController *summary = [self.viewControllers objectAtIndex:AppViewControllerPageSummary];


	/////////////////////////////////////////////
	// Headcount Page
	yOffset = [self offsetForPageInScrollView:AppViewControllerPageHeadCount];
		
	[self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, 0)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:headCount.welcomeLabel
	];	
	[self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, 0)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:headCount.taglineLabel
	];
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
	[self.animator setKeyFrameWithOffset: yOffset + difference
		translate:CGPointMake(0, difference)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:0
		forView:headCount.welcomeLabel
	];
	[self.animator setKeyFrameWithOffset: yOffset + difference
		translate:CGPointMake(0, difference)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:0
		forView:headCount.taglineLabel
	];
    
    
    /////////////////////////////////////////////
    // Total Markup Page
   	yOffset = [self offsetForPageInScrollView:AppViewControllerPageTotal]; 
     
    // Even Split
    [self.animator setKeyFrameWithOffset: yOffset - UI_SIZE_MIN_TOUCH
		translate:CGPointMake(0, UI_SIZE_MIN_TOUCH)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:0
		forView:totalMarkup.evenSplitLabel
	]; 
    [self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointZero
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:totalMarkup.evenSplitLabel
	]; 
    [self.animator setKeyFrameWithOffset: yOffset + UI_SIZE_MIN_TOUCH * 2
		translate:CGPointZero
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:0
		forView:totalMarkup.evenSplitLabel
	];
    
    // Final Label
    [self.animator setKeyFrameWithOffset: yOffset - UI_SIZE_MIN_TOUCH
   		translate:CGPointMake(0, UI_SIZE_MIN_TOUCH) 
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:0
		forView:totalMarkup.finalLabel
	]; 
    [self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointZero
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:totalMarkup.finalLabel
	];
    [self.animator setKeyFrameWithOffset: yOffset + UI_SIZE_MIN_TOUCH * 2
		translate:CGPointZero
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:0
		forView:totalMarkup.finalLabel
	];
     
    // Divider
    [self.animator setKeyFrameWithOffset: yOffset
   		translate:CGPointZero
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:totalMarkup.finalDivider
	]; 
    [self.animator setKeyFrameWithOffset: yOffset + UI_SIZE_MIN_TOUCH * 2
		translate:CGPointMake(0, UI_SIZE_MIN_TOUCH * 2)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:totalMarkup.finalDivider
	]; 
    [self.animator setKeyFrameWithOffset: yOffset + UI_SIZE_MIN_TOUCH * 4
		translate:CGPointMake(0, UI_SIZE_MIN_TOUCH * 4)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:0
		forView:totalMarkup.finalDivider
	];
     
    // Cover view
    [self.animator setKeyFrameWithOffset: yOffset
   		translate:CGPointZero
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:totalMarkup.coverView
	]; 
    [self.animator setKeyFrameWithOffset: yOffset + UI_SIZE_MIN_TOUCH * 2
		translate:CGPointMake(0, UI_SIZE_MIN_TOUCH * 2)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:totalMarkup.coverView
	];
	

	/////////////////////////////////////////////
	// Dish Setup Page
	yOffset = [self offsetForPageInScrollView:AppViewControllerPageDishes];
	xOffset = (bounds.size.width - UI_SIZE_MIN_TOUCH) / 4;
	refFrame = dishSetup.view.frame;
   

	/////////////////////////////////////////////
	// Distribution Page
	yTempOffset = [self offsetForPageInScrollView:AppViewControllerPageDistribution];

	// Drink
	temp = UI_SIZE_MIN_TOUCH + bounds.size.height / 6;
	transform = dishSetup.drinkButton.transform;
	tempSize = CGSizeMake(transform.a, transform.d);
	targetSize = CGSizeMake(tempSize.width * 1.2, tempSize.height * 1.2);
	targetFrame = [dishSetup.view convertRect:dishSetup.drinkButton.frame fromView:dishSetup.drinkButton.superview];
	targetPoint.y = refFrame.size.height - CGRectGetMaxY(targetFrame)
		+ temp + targetFrame.size.height / 8;
	targetPoint.x = 0;
	difference = 0;
	tempPoint = CGPointMake(
		(UI_SIZE_MIN_TOUCH + difference) / (bounds.size.height - UI_SIZE_MIN_TOUCH * 2),
		(UI_SIZE_MIN_TOUCH + difference) / (bounds.size.height - UI_SIZE_MIN_TOUCH * 2));
		
	[self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, 0)
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.drinkButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + UI_SIZE_MIN_TOUCH
		translate:CGPointMake(
			targetPoint.x * tempPoint.x, targetPoint.y * tempPoint.y)
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.drinkButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height - UI_SIZE_MIN_TOUCH
		translate:targetPoint
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.drinkButton
	];
	[self.animator setKeyFrameWithOffset: yTempOffset	// Distribution Page
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
	targetFrame = [dishSetup.view convertRect:dishSetup.smallDishButton.frame fromView:dishSetup.smallDishButton.superview];
	targetPoint.y = refFrame.size.height - CGRectGetMaxY(targetFrame) + temp;
	targetPoint.x = 1 * xOffset;	
	difference = UI_SIZE_MIN_TOUCH / 4;
	tempPoint = CGPointMake(
		(UI_SIZE_MIN_TOUCH + difference) / (bounds.size.height - UI_SIZE_MIN_TOUCH * 2),
		(UI_SIZE_MIN_TOUCH + difference) / (bounds.size.height - UI_SIZE_MIN_TOUCH * 2));
	[self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, 0)
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.smallDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + UI_SIZE_MIN_TOUCH + difference
		translate:CGPointMake(
			targetPoint.x * tempPoint.x, targetPoint.y * tempPoint.y)
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.smallDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height - UI_SIZE_MIN_TOUCH
		translate:targetPoint
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.smallDishButton
	];
	[self.animator setKeyFrameWithOffset: yTempOffset	// Distribution Page
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
	targetFrame = [dishSetup.view convertRect:dishSetup.mediumDishButton.frame fromView:dishSetup.mediumDishButton.superview];
	targetPoint.y = refFrame.size.height - CGRectGetMaxY(targetFrame)
		+ temp + targetFrame.size.height / 16;
	targetPoint.x = 2 * xOffset;
	difference = UI_SIZE_MIN_TOUCH / 2;
	tempPoint = CGPointMake(
		(UI_SIZE_MIN_TOUCH + difference) / (bounds.size.height - UI_SIZE_MIN_TOUCH * 2),
		(UI_SIZE_MIN_TOUCH + difference) / (bounds.size.height - UI_SIZE_MIN_TOUCH * 2));
	[self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, 0)
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.mediumDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + UI_SIZE_MIN_TOUCH + difference
		translate:CGPointMake(
			targetPoint.x * tempPoint.x, targetPoint.y * tempPoint.y)
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.mediumDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height - UI_SIZE_MIN_TOUCH
		translate:targetPoint
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.mediumDishButton
	];
	[self.animator setKeyFrameWithOffset: yTempOffset	// Distribution Page
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
	targetFrame = [dishSetup.view convertRect:dishSetup.largeDishButton.frame fromView:dishSetup.largeDishButton.superview];
	targetPoint.y = refFrame.size.height - CGRectGetMaxY(targetFrame)
		+ temp + targetFrame.size.height / 8;
	targetPoint.x = 3.1 * xOffset;
	difference = UI_SIZE_MIN_TOUCH / 4 * 3;
	tempPoint = CGPointMake(
		(UI_SIZE_MIN_TOUCH + difference) / (bounds.size.height - UI_SIZE_MIN_TOUCH * 2),
		(UI_SIZE_MIN_TOUCH + difference) / (bounds.size.height - UI_SIZE_MIN_TOUCH * 2));
	[self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, 0)
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.largeDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + UI_SIZE_MIN_TOUCH + difference
		translate:CGPointMake(
			targetPoint.x * tempPoint.x, targetPoint.y * tempPoint.y)
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.largeDishButton
	];
	[self.animator setKeyFrameWithOffset: yOffset + bounds.size.height - UI_SIZE_MIN_TOUCH
		translate:targetPoint
		scale:targetSize
		rotate:0
		alpha:1
		forView:dishSetup.largeDishButton
	];
	[self.animator setKeyFrameWithOffset: yTempOffset // Distribution Page
		translate:targetPoint
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.largeDishButton
	];
	targetPoint.y += bounds.size.height / 3;	// Let them be covered
	[self.animator setKeyFrameWithOffset: yTempOffset + bounds.size.height / 3
		translate:targetPoint
		scale:tempSize
		rotate:0
		alpha:1
		forView:dishSetup.largeDishButton
	];

    // Instructional Arrow Cover
    refFrame = distribution.instructionCover.frame;
    [self.animator setKeyFrameWithOffset: yTempOffset - UI_SIZE_MIN_TOUCH   * 3
		translate:CGPointZero
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:distribution.instructionCover
	]; 
    [self.animator setKeyFrameWithOffset: yTempOffset - UI_SIZE_MIN_TOUCH * 2
		translate:CGPointMake(0, refFrame.size.height / 2)
		scale:CGSizeMake(1, 1)
		rotate:M_PI / 8
		alpha:1
		forView:distribution.instructionCover
	]; 
    [self.animator setKeyFrameWithOffset: yTempOffset - UI_SIZE_MIN_TOUCH
		translate:CGPointMake(-refFrame.size.width, refFrame.size.height)
		scale:CGSizeMake(1, 1)
		rotate:M_PI / 4
		alpha:1
		forView:distribution.instructionCover
	];
 
    refFrame = distribution.instructionCover2.frame;
    [self.animator setKeyFrameWithOffset: yTempOffset - UI_SIZE_MIN_TOUCH    * 3
		translate:CGPointZero
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:distribution.instructionCover2
	]; 
    [self.animator setKeyFrameWithOffset: yTempOffset
		translate:CGPointMake(0, refFrame.size.height)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:distribution.instructionCover2
	];
       
    // Warning label
    [self.animator setKeyFrameWithOffset: yTempOffset - UI_SIZE_MIN_TOUCH
		translate:CGPointMake(0, UI_SIZE_MIN_TOUCH)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:0
		forView:distribution.warningLabel
	]; 
    [self.animator setKeyFrameWithOffset: yTempOffset
		translate:CGPointZero
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:distribution.warningLabel
	];
    [self.animator setKeyFrameWithOffset: yTempOffset + UI_SIZE_MIN_TOUCH
		translate:CGPointMake(0, UI_SIZE_MIN_TOUCH * 2)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:0
		forView:distribution.warningLabel
	];  
    
    
    //////////////////////////////////////////
    // Summary Page
    yOffset = [self offsetForPageInScrollView:AppViewControllerPageSummary];
    
    [self.animator setKeyFrameWithOffset: yTempOffset
		translate:CGPointZero
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:distribution.profileScrollView
	];    
    [self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, yOffset - yTempOffset)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:distribution.profileScrollView
	]; 
    
     
    [self.animator setKeyFrameWithOffset: yTempOffset
		translate:CGPointZero
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:distribution.profilePageControl
	];    
    [self.animator setKeyFrameWithOffset: yOffset
		translate:CGPointMake(0, yOffset - yTempOffset)
		scale:CGSizeMake(1, 1)
		rotate:0
		alpha:1
		forView:distribution.profilePageControl
	]; 
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
    if (self.viewControllers.count)
    {
        BSHeadcountViewController *headCountVC = [self.viewControllers objectAtIndex:AppViewControllerPageHeadCount];
        BSDishSetupViewController *dishSetupVC = [self.viewControllers objectAtIndex:AppViewControllerPageDishes]; 
        BSDistributionViewController *distributionVC = [self.viewControllers objectAtIndex:AppViewControllerPageDistribution];
        
         
        // If only 1 person, only show total markup
        int headCount = (NSInteger)headCountVC.stepper.value;
        if (distributionVC.headCount != headCount)
        { 
            self.pageControl.numberOfPages 
                = (headCount == 1) 
                    ? 2 : AppViewControllerPageCount;
            self.scrollView.contentSize = CGSizeMake(
                self.scrollView.bounds.size.width, 
                self.scrollView.bounds.size.height
                    * self.pageControl.numberOfPages); 
            
            CGRect frame = self.pageControl.frame;
            frame.origin.y = self.view.bounds.size.height - frame.size.height / (headCount == 1 ? 1.35 : 1);
            [UIView animateWithDuration:ANIMATION_DURATION_FASTEST delay:0 
                options:UIViewAnimationOptionBeginFromCurrentState 
                animations:^{
                    self.pageControl.frame = frame; 
                    dishSetupVC.view.alpha = (headCount == 1 ? 0 : 1);
                } completion:nil];
                           
            // Update distribution page
            distributionVC.headCount = headCount;
        }
        
        // Page-based update
        switch (self.pageControl.currentPage)
        {
            case AppViewControllerPageDistribution:
                self.pageControl.currentDotTintColor = UIColorFromHex(COLOR_HEX_DARK_ACCENT);
                self.pageControl.dotTintColor = UIColorFromHex(COLOR_HEX_BACKGROUND_DARK_GRAY_TRANSLUCENT);
                self.scrollView.delaysContentTouches = false;
                break;
            
            default:
                self.pageControl.currentDotTintColor = UIColorFromHex(COLOR_HEX_ACCENT);
                self.pageControl.dotTintColor = UIColorFromHex(COLOR_HEX_BACKGROUND_DARK_GRAY_TRANSLUCENT); 
                self.scrollView.delaysContentTouches = true;
                break;
        }
       
    }
}

/** @brief Resets all the pages to defaults */
- (void)resetPages
{
	for (UIViewController *vc in self.viewControllers) {
		[vc didReceiveMemoryWarning];	// Reset
	}
	
	// Scroll to first page
	self.pageControl.currentPage = AppViewControllerPageHeadCount;
	[self pageControlPageDidChange:self.pageControl];
}


#pragma mark - UI Event Handlers

/** @brief Info button pressed */
- (void)showInfo:(id)sender
{
	InfoViewController *controller = [InfoViewController new];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:[[InfoViewNavigationController alloc] initWithRootViewController:controller]
		animated:YES completion:nil];
}

/** @brief Reset button pressed */
- (void)resetButtonPressed:(UIButton *)sender
{
	[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"APP_VIEW_WARNING_TITLE", nil)
		message:NSLocalizedString(@"APP_VIEW_WARNING_RESET", nil)
		delegate:self
		cancelButtonTitle:NSLocalizedString(@"POPUP_CANCEL", nil)
		otherButtonTitles:NSLocalizedString(@"APP_VIEW_WARNING_RESET_OK", nil), nil] show];
}

/** @brief Alert view button pressed */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex)	// Not cancel, reset data
	{
		[self resetPages];
	}
}


#pragma mark - Delegates
#pragma mark - CustomPageControlDelegate

/** @brief When page control dot is tapped */
- (void)pageControlPageDidChange:(CustomPageControl *)pageControl
{
    int page = pageControl.currentPage;
    
    // Scroll to page
   	CGRect frame = self.scrollView.bounds;
	frame.origin.y = [self offsetForPageInScrollView:page]; 
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
		frame.origin.x, frame.origin.y - UI_SIZE_MIN_TOUCH * 2,
		self.scrollView.bounds.size.width, self.scrollView.bounds.size.height
	);
    [self.scrollView scrollRectToVisible:frame animated:YES];
	
	// Change last shown page based on which field
	self.lastShownPage = field.tag;
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updatePages];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	// To prevent stuttering of scrolling
	self.scrollView.pagingEnabled = false;
	self.animator.enabled = false;
	
	// Animate scroll so field is visible above keyboard
	CGRect frame = [self.scrollView convertRect:textField.frame fromView:textField.superview];
	frame = CGRectMake(
		frame.origin.x, frame.origin.y - UI_SIZE_MIN_TOUCH * 2,
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
            [self formatIntegerTextField:textField toStepper:stepper whenChangingCharactersInRange:range withString:string];
			return NO;
		}

		// Price type (dish setup & total markup)
		case AppViewControllerPageTotal:
        {
            BSTotalMarkupViewController *vc = [self.viewControllers objectAtIndex:textField.tag];
            stepper = [vc stepperForTextField:textField]; 
            if (stepper == vc.tipStepper) {
                [self formatIntegerTextField:textField toStepper:stepper whenChangingCharactersInRange:range withString:string]; 
            } else {
                [self formatDecimalTextField:textField toStepper:stepper whenChangingCharactersInRange:range withString:string]; 
            }  
            [vc updateCalculations]; 
            return NO;
        }
		case AppViewControllerPageDishes:
		{
            stepper = [[self.viewControllers objectAtIndex:textField.tag] stepperForTextField:textField];
			[self formatDecimalTextField:textField toStepper:stepper whenChangingCharactersInRange:range withString:string];
			return NO;
		}
		
		default:
			break;
	}
	return YES;
}

- (void)formatIntegerTextField:(UITextField *)textField toStepper:(UIVerticalStepper *)stepper whenChangingCharactersInRange:(NSRange)range withString:(NSString *)string
{
    // Get new text, add user entered text & replace $ signs and periods
    NSString *newText = [[[textField.text stringByReplacingCharactersInRange:range withString:string] stringByReplacingOccurrencesOfString:@"$" withString:@""] stringByReplacingOccurrencesOfString:@"%" withString:@""];

    // Make sure is a number
    NSNumber *number = [self.numberFormatter numberFromString:newText];
        
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
}


- (void)formatDecimalTextField:(UITextField *)textField toStepper:(UIVerticalStepper *)stepper whenChangingCharactersInRange:(NSRange)range withString:(NSString *)string
{
    // Look for zeros in the decimal places so we can replace them
    NSString *currentText = textField.text;
    
    // Get new text, shift number up and replace $ and periods
    NSMutableString *newText = [[[[currentText
        stringByReplacingCharactersInRange:range withString:string]
        stringByReplacingOccurrencesOfString:@"$" withString:@""]
        stringByReplacingOccurrencesOfString:@"." withString:@""] mutableCopy];
    
    // Add in decimal point now
    [newText insertString:@"." atIndex:newText.length - 2];

    // Make sure is a number
    NSNumber *number = [self.numberFormatter numberFromString:newText];
    
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
    CGFloat pageSize = scrollView.bounds.size.height;
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
	if (self.lastShownPage != self.pageControl.currentPage) 
    {
        [[self.viewControllers objectAtIndex:self.pageControl.currentPage] viewDidAppear:true];
        [[self.viewControllers objectAtIndex:self.lastShownPage] viewDidDisappear:true]; 
        self.lastShownPage = self.pageControl.currentPage; 
		[self updatePages];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // Re-enable animator if needed
	if (self.enableAnimator) 
    {
		self.animator.enabled = true;
		self.enableAnimator = false;
        
        // Needed to get animator to refresh and show elements again
		self.scrollView.contentOffset = self.scrollView.contentOffset;
	}
       	
	// If page is not the same as lastShownPage, let page know it'll be shown
	if (self.lastShownPage != self.pageControl.currentPage) {
        [[self.viewControllers objectAtIndex:self.pageControl.currentPage] viewDidAppear:true]; 
        [[self.viewControllers objectAtIndex:self.lastShownPage] viewDidDisappear:true];
        self.lastShownPage = self.pageControl.currentPage; 
	}
	
	// Re-enable paging once done with animation
	self.scrollView.pagingEnabled = true;
}


#pragma mark - InfoViewControllerDelegate

- (void)infoViewController:(InfoViewController *)vc willCloseAnimated:(bool)animated
{
	[self dismissViewControllerAnimated:animated completion:nil];
}


#pragma mark - BSHeadCountViewControllerDelegate

- (void)headCountViewController:(BSHeadcountViewController *)vc countChanged:(NSInteger)count
{
    if (self.viewControllers.count) {
        [self.viewControllers[AppViewControllerPageTotal] updateCalculations];
    }
    [self updatePages];
}


#pragma mark - BSScrollViewDelegate

- (bool)scrollView:(BSScrollView *)scrollView shouldDelayTouchesForView:(UIView *)view
{
    if (view == self.resetButton) {
        return false;
    }
    
    return true;
}


#pragma mark - BSDistributionViewControllerDelegate

- (void)distributionViewController:(BSDistributionViewController *)vc scrollToPage:(NSInteger)index
{
    self.pageControl.currentPage = index;
    [self pageControlPageDidChange:self.pageControl];
}


@end
