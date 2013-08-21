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

#import "InfoViewController.h"
#import "BSHeadcountViewController.h"
#import "BSDishSetupViewController.h"
#import "BSDistributionViewController.h"
#import "BSTotalMarkupViewController.h"
#import "BSSummaryViewController.h"

	#define UI_SIZE_INFO_BUTTON_MARGIN 8

	#define UI_SIZE_PAGECONTROL_WIDTH 30
	#define UI_SIZE_PAGECONTROL_HEIGHT 100
	
	typedef enum {
		AppViewControllerPageHeadCount,
		AppViewControllerPageDishes,
		AppViewControllerPageDistribution,
		AppViewControllerPageTotal,
		AppViewControllerPageSummary,
		AppViewControllerPageCount
	} AppViewControllerPage;

@interface AppViewController () <
	CustomPageControlDelegate,
	InfoViewControllerDelegate,
	BSKeyboardControlsDelegate
>

	/** For scrolling effect */
	@property (nonatomic, strong) ParallaxScrollingFramework *animator;

	/** Main UI Elements */
	@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
	@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
	@property (nonatomic, strong) CustomPageControl *pageControl;
	@property (nonatomic, strong) BSKeyboardControls *keyboardControl;

	/** Controllers for user actions */
	@property (nonatomic, strong) NSArray *viewControllers;
	@property (nonatomic, strong) NSMutableArray *inputFields;

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
	self.viewControllers = vcs;
	
	[self setupPageControl:bounds];
	[self setupKeyboardControl];
}

/** @brief Setup headcount view */
- (UIViewController *)setupHeadCount:(CGRect)bounds
{
	BSHeadcountViewController *vc = [[BSHeadcountViewController alloc] initWithFrame:bounds];
	
	[self.inputFields addObject:vc.textField];
	
	CGRect frame = vc.view.frame;
	frame.origin.y = [self offsetForPageInScrollView:AppViewControllerPageHeadCount] + bounds.size.height / 3;
	vc.view.frame = frame;
	
	[self.scrollView addSubview:vc.view];
	return vc;
}

/** @brief Setup dishes and costs view */
- (UIViewController *)setupDishes:(CGRect)bounds
{
	BSDishSetupViewController *vc = [[BSDishSetupViewController alloc] initWithFrame:bounds];
	
	vc.view.frame = CGRectMake(
		0, [self offsetForPageInScrollView:AppViewControllerPageDishes],
		bounds.size.width, bounds.size.height);
	
	[self.scrollView addSubview:vc.view];
	return vc;
}

/** @brief Setup distribution of dishes to people view */
- (UIViewController *)setupDistribution:(CGRect)bounds
{
	BSDistributionViewController *vc = [[BSDistributionViewController alloc] initWithFrame:bounds];
	
	vc.view.frame = CGRectMake(
		0, [self offsetForPageInScrollView:AppViewControllerPageDistribution],
		bounds.size.width, bounds.size.height);
	
	[self.scrollView addSubview:vc.view];
	return vc;
}

/** @brief Setup total markup view view */
- (UIViewController *)setupTotalMarkup:(CGRect)bounds
{
	BSTotalMarkupViewController *vc = [[BSTotalMarkupViewController alloc] initWithFrame:bounds];
	
	vc.view.frame = CGRectMake(
		0, [self offsetForPageInScrollView:AppViewControllerPageTotal],
		bounds.size.width, bounds.size.height);
	
	[self.scrollView addSubview:vc.view];
	return vc;
}

/** @brief Setup summary & payments options view */
- (UIViewController *)setupSummary:(CGRect)bounds
{
	BSSummaryViewController *vc = [[BSSummaryViewController alloc] initWithFrame:bounds];
	
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
	self.pageControl.currentDotTintColor = UIColorFromHex(COLOR_HEX_ACCENT);
	self.pageControl.dotTintColor = UIColorFromHex(COLOR_HEX_BACKGROUND_LIGHT_TRANSLUCENT);
	
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
}


#pragma mark - Class Functions

- (CGFloat)offsetForPageInScrollView:(AppViewControllerPage)page
{
	return self.scrollView.bounds.size.height * page;
}


#pragma mark - UI Event Handlers

/** @brief Info button pressed */
- (void)showInfo:(id)sender
{
	InfoViewController *controller = [[InfoViewController alloc] init];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:controller]
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
}

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
	CGRect frame = field.frame;
	frame = [self.scrollView convertRect:frame fromView:field];
	debugRect(frame);
    [self.scrollView scrollRectToVisible:frame animated:YES];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControl setActiveField:textField];
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
	
    self.pageControl.currentPage = page;
}


#pragma mark - InfoViewControllerDelegate

- (void)infoViewController:(InfoViewController *)vc willCloseAnimated:(bool)animated
{
	[self dismissViewControllerAnimated:animated completion:nil];
}


@end
