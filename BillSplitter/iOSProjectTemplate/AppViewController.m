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
	@property (nonatomic, assign) CGRect keyboardFrame;

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
		
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(keyboardWillShow:)
			name:UIKeyboardWillShowNotification object:nil];
			
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

/** @brief When keyboard is shown */
- (void)keyboardWillShow:(NSNotification *)sender
{
	// Get keyboard position
	NSDictionary* keyboardInfo = [sender userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    self.keyboardFrame = [keyboardFrameBegin CGRectValue];
	
	// Get position of field that is active
	UIView *field = self.keyboardControl.activeField;
	CGRect frame = [field convertRect:field.frame toView:self.scrollView];
	
	// Animate scroll so field is visible above keyboard
	frame.origin.y += self.keyboardFrame.size.height - UI_SIZE_MIN_TOUCH * 2;
    [self.scrollView scrollRectToVisible:frame animated:YES];
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
	
	// Scroll back to normal page position
	[self.scrollView scrollRectToVisible:CGRectMake(
		0, [self offsetForPageInScrollView:self.lastShownPage],
		self.scrollView.bounds.size.width, self.scrollView.bounds.size.height
	) animated:true];
}

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
	// Animate scroll so field is visible above keyboard
	CGRect frame = [field convertRect:field.frame toView:self.scrollView];
	frame.origin.y += self.keyboardFrame.size.height;
    [self.scrollView scrollRectToVisible:frame animated:YES];
	
	// Change last shown page based on which field
	self.lastShownPage = field.tag;
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControl setActiveField:textField];
	[textField selectAll:self];
	[UIMenuController sharedMenuController].menuVisible = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString *newText = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByReplacingOccurrencesOfString:@"$" withString:@""];
	
	// Make sure is a number
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber *number = [formatter numberFromString:newText];
	
	// Stepper to update
	RPVerticalStepper *stepper;
	switch (textField.tag)
	{
		// If integer type (headcount & distribution page)
		case AppViewControllerPageHeadCount:
			stepper = [[self.viewControllers objectAtIndex:textField.tag] stepper];
		case AppViewControllerPageDistribution:
		{
			if (!stepper) {
				stepper = [[self.viewControllers objectAtIndex:textField.tag] stepperForTextField:textField];
			}
			
			// Restrict value
			if (!number) {
				number = [NSNumber numberWithFloat:stepper.minimumValue];
			} else if (number.floatValue > stepper.maximumValue) {
				number = [NSNumber numberWithFloat:stepper.maximumValue];
			} else if (number.floatValue < 0) {
				number = [NSNumber numberWithFloat:stepper.minimumValue];
			}
			
			// Set stepper value
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
	
	// If page is not the same as lastShownPage, let page know it'll be shown
	if (self.lastShownPage != page) {
		[[self.viewControllers objectAtIndex:page] viewWillAppear:true];
		[[self.viewControllers objectAtIndex:self.lastShownPage] viewWillDisappear:true];
	}
	
	// Bound page limits
	if (page >= AppViewControllerPageCount) {
		page = AppViewControllerPageCount - 1;
	} else if (page < 0) {
		page = 0;
	}
	
    self.pageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (self.lastShownPage != self.pageControl.currentPage) {
		self.lastShownPage = self.pageControl.currentPage;
	}
}


#pragma mark - InfoViewControllerDelegate

- (void)infoViewController:(InfoViewController *)vc willCloseAnimated:(bool)animated
{
	[self dismissViewControllerAnimated:animated completion:nil];
}


@end
