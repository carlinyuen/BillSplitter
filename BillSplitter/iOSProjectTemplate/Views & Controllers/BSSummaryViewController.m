/**
	@file	BSSummaryViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSSummaryViewController.h"

#import "BSTouchPassingView.h"

	#define UI_SIZE_LABEL_MARGIN 24
	#define UI_SIZE_MARGIN 16

	NSString* const BSSummaryViewControllerProfileBill = @"bill";
    
#pragma mark - BSSummaryViewController
    
@interface BSSummaryViewController ()

	@property (nonatomic, assign) CGRect frame;

    @property (nonatomic, assign) CGFloat priceDrink;
    @property (nonatomic, assign) CGFloat priceSmallDish; 
    @property (nonatomic, assign) CGFloat priceMediumDish; 
    @property (nonatomic, assign) CGFloat priceLargeDish; 
    
    @property (nonatomic, strong) NSNumberFormatter *numFormatter;

    /** Pass events to target view */
    @property (nonatomic, strong) BSTouchPassingView *profileScrollViewCover;
    @property (nonatomic, strong) BSTouchPassingView *profilePageControlCover; 
    
@end


#pragma mark - Implementation

@implementation BSSummaryViewController

/** @brief Initialize data-related properties */
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
	{
		_frame = frame;
		
        _numFormatter = [NSNumberFormatter new];
        [_numFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _profileScrollViewCover = [[BSTouchPassingView alloc] initWithFrame:CGRectZero];
        _profilePageControlCover = [[BSTouchPassingView alloc] initWithFrame:CGRectZero];

        _errorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
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
    
    [self setupProfileCover:bounds];
    [self setupErrorLabel:bounds];
    [self setupScrollView:bounds];
}


/** @brief Last-minute setup before view appears. */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

/** @brief Actions to take when view is shown */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Refresh cover positions
    [self refreshCoverPositions];
       
    // Calculate costs
    [self updateCalculations]; 
}

/** @brief Actions to take when view is leaving */
- (void)viewWillDisappear:(BOOL)animated
{
    // Fade out error message if showing
    if (self.errorLabel.alpha == 1) {
        [UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
            animations:^{
                self.errorLabel.alpha = 0;
            } completion:nil];
    }

    [super viewWillDisappear:animated];
}

/** @brief Dispose of any resources that can be recreated. */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Reset fields
    [self clearScrollView:nil];
}

/** @brief Return supported orientations */
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - Class Functions

/** @brief Update calculations for variables to compute final payments */
- (void)updateCalculations
{
    // Get total
    NSNumber *total = [self.numFormatter numberFromString:self.finalLabel.text];
//        [self.finalLabel.text stringByReplacingOccurrencesOfString:@"$" withString:@""]];
    if (!total) {   // This shouldn't happen
        NSLog(@"Error parsing number from final total field!");
        return;
    }

    // Get dish setup to calculate proportions
    CGFloat drinkValue = self.drinkStepper.value;
    CGFloat smallDishValue = self.smallDishStepper.value; 
    CGFloat mediumDishValue = self.mediumDishStepper.value; 
    CGFloat largeDishValue = self.largeDishStepper.value; 

    // Insanity Check
    if (drinkValue + smallDishValue + mediumDishValue + largeDishValue <= 0) {
        [self showError:NSLocalizedString(@"SUMMARY_ERROR_ZERO_VALUE", nil)];
        return;
    }
    
    // Count up all the different dishes people had
    NSInteger drinkCount = 0;
    NSInteger smallDishCount = 0; 
    NSInteger mediumDishCount = 0; 
    NSInteger largeDishCount = 0; 
    for (NSDictionary *profile in self.profiles)
    {
        NSDictionary *dishCount = profile[BSDistributionViewControllerProfileViewDishCount];
        for (NSNumber *tag in dishCount) 
        {
            switch ([tag integerValue])
            {
                case BSDishSetupViewControllerItemDrink:
                    drinkCount += [dishCount[tag] integerValue];
                    break;
                case BSDishSetupViewControllerItemSmallDish: 
                    smallDishCount += [dishCount[tag] integerValue];
                    break; 
                case BSDishSetupViewControllerItemMediumDish: 
                    mediumDishCount += [dishCount[tag] integerValue];
                    break;  
                case BSDishSetupViewControllerItemLargeDish: 
                    largeDishCount += [dishCount[tag] integerValue];
                    break;  
                default: break;
            }
        }
    }

    // Insanity Check
    if (drinkCount + smallDishCount + mediumDishCount + largeDishCount <= 0) {
        [self showError:NSLocalizedString(@"SUMMARY_ERROR_ZERO_COUNT", nil)];
        return;
    }

    // Do some math... calculate for mysterious A 
    //  A stands for the lowest unit of cost of a shared part
    CGFloat A = [total floatValue] / (
        (drinkValue * drinkCount) 
        + (smallDishValue * smallDishCount)
        + (mediumDishValue * mediumDishCount) 
        + (largeDishValue * largeDishCount)
    );

    // Calculate how much each profile should pay and save it in
    NSNumber *bill;
    bool billHasChanged = false;
    for (int i = 0; i < self.profiles.count; ++i)
    {
        NSMutableDictionary *profile = self.profiles[i];
        NSNumber *lastBill = profile[BSSummaryViewControllerProfileBill];
        NSDictionary *dishCount = profile[BSDistributionViewControllerProfileViewDishCount];
        
        // Figure out bill
        bill = @(
            A * (
                [dishCount[@(BSDishSetupViewControllerItemDrink)] integerValue] * drinkValue
                + [dishCount[@(BSDishSetupViewControllerItemSmallDish)] integerValue] * smallDishValue
                + [dishCount[@(BSDishSetupViewControllerItemMediumDish)] integerValue] * mediumDishValue
                + [dishCount[@(BSDishSetupViewControllerItemLargeDish)] integerValue] * largeDishValue
            )
        );
        NSLog(@"Bill for profile %i: %@", i, bill);

        if (!lastBill || ![bill isEqualToNumber:lastBill]) {
            [profile setObject:bill forKey:BSSummaryViewControllerProfileBill];
            billHasChanged = true;
        }
    }
    
    // Update scrollview with new results if bill has changed
    if (billHasChanged) {
        [self updateScrollView];
    }
}

/** @brief Show error */
- (void)showError:(NSString *)message
{
    // Setup frame and resize for message
    CGRect viewFrame = self.view.frame;
    self.errorLabel.frame = CGRectMake(
        UI_SIZE_LABEL_MARGIN, UI_SIZE_MARGIN,
        viewFrame.size.width - UI_SIZE_LABEL_MARGIN * 2, viewFrame.size.height
    );
    self.errorLabel.text = message;
    [self.errorLabel sizeToFit];
    CGRect frame = self.errorLabel.frame;
    frame.origin.x = (self.view.frame.size.width - CGRectGetWidth(frame)) / 2;
    frame.size.height = viewFrame.size.height / 5 - UI_SIZE_MARGIN;
    self.errorLabel.frame = frame;

    // Fade out scrollview with results
    [UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
        animations:^{
            self.scrollView.alpha = 0;
        } completion:^(BOOL finished) {
            // Show error message in place
            [UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                animations:^{
                    self.errorLabel.alpha = 1;
                } completion:nil];
        }];
}

/** @brief Clear scroll view's elements */
- (void)clearScrollView:(void(^)())completion
{
    [UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
        animations:^{
            self.scrollView.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                for (UIView *subview in self.scrollView.subviews) {
                    [subview removeFromSuperview];
                }
                if (completion) {
                    completion();
                }
            }
        }];
}

/** @brief Create UI elements to show new calculations */
- (void)updateScrollView
{
    // Clear old views
    [self clearScrollView:^
    {
        // Build elements
        for (int i = 0; i < self.profiles.count; ++i)
        {
            NSMutableDictionary *profile = self.profiles[i];
            NSNumber *bill = profile[BSSummaryViewControllerProfileBill];

            UIButton *button = [[UIButton alloc] initWithFrame:self.scrollView.bounds];
            button.titleLabel.textColor = [UIColor whiteColor];
            button.titleLabel.backgroundColor = [UIColor clearColor];
            button.titleLabel.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_HEADCOUNT];
            button.titleLabel.adjustsFontSizeToFitWidth = true;
            button.titleLabel.minimumFontSize = FONT_SIZE_HEADCOUNT / 3;
            button.titleLabel.text = [self.numFormatter stringFromNumber:bill];

            [self.scrollView addSubview:button];
        }

        // Show scrollview with results
        [UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
            animations:^{
                self.scrollView.alpha = 1;
            } completion:nil];
    }];
}

/** @brief Refresh the cover positions so they match their target views */
- (void)refreshCoverPositions
{
    self.profilePageControlCover.frame = [self.view convertRect:self.profilePageControl.frame fromView:self.profilePageControl.superview];
    
    CGRect frame = [self.view convertRect:self.profileScrollView.frame fromView:self.profileScrollView.superview];
    frame.origin.x = 0;
    frame.size.width = CGRectGetWidth(self.view.bounds);
    self.profileScrollViewCover.frame = frame;
}


#pragma mark - UI Setup

/** @brief Set target view of cover when set */
- (void)setProfileScrollView:(UIScrollView *)profileScrollView
{
    // Clean up observer and replace
	[_profileScrollView removeObserver:self forKeyPath:@"contentOffset"];
    _profileScrollView = profileScrollView;
   
    // Add target for cover and add observer
    self.profileScrollViewCover.targetView = _profileScrollView;
	[_profileScrollView addObserver:self forKeyPath:@"contentOffset"
		options:NSKeyValueObservingOptionNew context:nil];
}

/** @brief Set target view of cover when set */
- (void)setProfilePageControl:(CustomPageControl *)profilePageControl
{
    _profilePageControl = profilePageControl;
    self.profilePageControlCover.targetView = _profilePageControl; 
}

/** @brief Set up view to pass events to scroll view */
- (void)setupProfileCover:(CGRect)bounds
{
    [self.view addSubview:self.profileScrollViewCover];
    [self.view addSubview:self.profilePageControlCover]; 
}

/** @brief Set up error label for messages to display to user */
- (void)setupErrorLabel:(CGRect)bounds
{
    self.errorLabel.backgroundColor = [UIColor clearColor];
    self.errorLabel.textColor = [UIColor whiteColor];
    self.errorLabel.font = [UIFont fontWithName:FONT_NAME_COPY size:FONT_SIZE_COPY];
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.errorLabel.textAlignment = UITextAlignmentCenter;
    self.errorLabel.alpha = 0;

    [self.view addSubview:self.errorLabel];
}

/** @brief Set up scroll view for results */
- (void)setupScrollView:(CGRect)bounds
{
    BSTouchPassingView *containerView
		= [[BSTouchPassingView alloc] initWithFrame:CGRectMake(
		0, 0, bounds.size.width, bounds.size.height / 5
	)];
	containerView.userInteractionEnabled = true;
	
	self.scrollView.frame = CGRectMake(
		bounds.size.width / 4, 0,
		bounds.size.width / 2, containerView.bounds.size.height
	);
	self.scrollView.contentSize = CGSizeMake(
		bounds.size.width + 1, self.scrollView.bounds.size.height);
	self.scrollView.showsHorizontalScrollIndicator = false;
	self.scrollView.showsVerticalScrollIndicator = false;
	self.scrollView.directionalLockEnabled = true;
	self.scrollView.pagingEnabled = true;
	self.scrollView.clipsToBounds = false;
	self.scrollView.delegate = self;
	
	containerView.targetView = self.scrollView;
	[containerView addSubview:self.scrollView];
	[self.view addSubview:containerView];
}


#pragma mark - UI Events


#pragma mark - Utility Functions


#pragma mark - Delegates

/** @brief Tracking the updating of the scrollview */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
	change:(NSDictionary *)change context:(void *)context
{
	if (object == self.profileScrollView) {
		[self.scrollView setContentOffset:self.profileScrollView.contentOffset animated:true];
	}
}

@end
