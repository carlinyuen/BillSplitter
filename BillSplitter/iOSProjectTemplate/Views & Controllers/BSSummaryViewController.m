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
        [_numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
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

/** @brief Update calculations for variables to compute final payments */
- (void)updateCalculations
{
    // Get total
    NSNumber *total = [self.numFormatter numberFromString:
        [self.finalLabel.text stringByReplacingOccurrencesOfString:@"$" withString:@""]];
    if (!total) {   // This shouldn't happen
        NSLog(@"Error parsing number from final total field!");
        return;
    }
    NSLog(@"Total Cost: %@", total);
    
    // Get dish setup to calculate proportions
    CGFloat drinkValue = self.drinkStepper.value;
    CGFloat smallDishValue = self.smallDishStepper.value; 
    CGFloat mediumDishValue = self.mediumDishStepper.value; 
    CGFloat largeDishValue = self.largeDishStepper.value; 
    NSLog(@"Dish Values: %f, %f, %f, %f", 
        drinkValue, smallDishValue, mediumDishValue, largeDishValue);

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
    NSLog(@"Counts: %i, %i, %i, %i", 
        drinkCount, smallDishCount, mediumDishCount, largeDishCount);
    
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
    NSLog(@"A = %f", A);
    
    // Calculate how much each profile should pay and save it in
    NSNumber *bill;
    for (int i = 0; i < self.profiles.count; ++i)
    {
        NSMutableDictionary *profile = self.profiles[i];
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
        
        [profile setObject:bill forKey:BSSummaryViewControllerProfileBill];
    }
    
    // Update ui
    [self updateUI];
}

/** @brief Show error */
- (void)showError:(NSString *)message
{
    NSLog(@"showError: %@", message);

    // Setup frame and resize for message
    self.errorLabel.frame = CGRectMake(
        UI_SIZE_LABEL_MARGIN, UI_SIZE_MARGIN,
        self.view.frame.size.width - UI_SIZE_LABEL_MARGIN * 2,
        self.view.frame.size.height / 5
    );
    self.errorLabel.text = message;
    [self.errorLabel sizeToFit];
    CGRect frame = self.errorLabel.frame;
    frame.origin.x = (self.view.frame.size.width - CGRectGetWidth(frame)) / 2;
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

/** @brief Update UI elements to show new calculations */
- (void)updateUI
{
    // Fade out error message if showing
    [UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
        animations:^{
            self.errorLabel.alpha = 0;
        } completion:^(BOOL finished) {
            // Show error message in place
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
    _profileScrollView = profileScrollView;
    self.profileScrollViewCover.targetView = _profileScrollView; 
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


#pragma mark - UI Events


#pragma mark - Utility Functions


#pragma mark - Delegates


@end
