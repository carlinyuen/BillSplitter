/**
	@file	BSSummaryViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSSummaryViewController.h"

	NSString* const BSSummaryViewControllerProfileBill = @"bill";
    
@interface BSSummaryViewController ()

	@property (nonatomic, assign) CGRect frame;

    @property (nonatomic, assign) CGFloat priceDrink;
    @property (nonatomic, assign) CGFloat priceSmallDish; 
    @property (nonatomic, assign) CGFloat priceMediumDish; 
    @property (nonatomic, assign) CGFloat priceLargeDish; 
    
    @property (nonatomic, strong) NSNumberFormatter *numFormatter;

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

/** @brief Update UI elements to show new calculations */
- (void)updateUI
{
}


#pragma mark - UI Setup


#pragma mark - UI Events


#pragma mark - Utility Functions


#pragma mark - Delegates


@end
