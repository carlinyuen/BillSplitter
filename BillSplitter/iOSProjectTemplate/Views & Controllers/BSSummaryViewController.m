/**
	@file	BSSummaryViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSSummaryViewController.h"

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
    
    // Get dish setup to calculate proportions
    CGFloat drink = self.drinkStepper.value;
    CGFloat smallDish = self.smallDishStepper.value; 
    CGFloat mediumDish = self.mediumDishStepper.value; 
    CGFloat largeDish = self.largeDishStepper.value; 
    
    // Do some math...
    
    // Calculate how much each profile should pay
}


#pragma mark - UI Setup


#pragma mark - UI Events


#pragma mark - Utility Functions


#pragma mark - Delegates


@end
