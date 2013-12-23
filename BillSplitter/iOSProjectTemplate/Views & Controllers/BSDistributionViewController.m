/**
	@file	BSDistributionViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSDistributionViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "CustomPageControl.h"

#import "BSDishSetupViewController.h"

	#define TABLEVIEW_ROW_ID @"RowCell"

	#define HOVER_SCALE 1.05
	#define HOVER_SPEED 0.1
	#define DRAG_SPEED 0.05
	#define DRAG_ALPHA 0.66
       
    #define TAG_BADGE_LABEL -1 
   	#define SCALE_BADGE_CHANGE 0.25 

    #define UI_SIZE_STATUS_BAR_HEIGHT 20
	#define UI_SIZE_RESET_BUTTON_HEIGHT 16
	#define UI_SIZE_RESET_BUTTON_MARGIN 8 
	#define UI_SIZE_BADGE_HEIGHT 16 
    #define UI_SIZE_BADGE_CORNER_RADIUS 8 
	#define UI_SIZE_PAGECONTROL_HEIGHT 24
	#define UI_SIZE_DINER_MARGIN 8
	#define UI_SIZE_MARGIN 16
    
    #define FONT_SIZE_BADGE_LABEL 11

	#define IMAGEVIEW_SCALE_SMALLDISH 0.7
	#define IMAGEVIEW_SCALE_MEDIUMDISH 0.8
	#define IMAGEVIEW_SCALE_LARGEDISH 1.0

	#define STEPPER_MIN_VALUE 1
	#define STEPPER_DEFAULT_VALUE 1
	#define STEPPER_DEFAULT_MAX_VALUE 2

	#define IMG_ARROW @"arrow.png"
   	#define IMG_ARROWHEAD @"arrowhead.png" 
	#define IMG_DINER @"man.png"
	#define IMG_DRINK @"drink.png"
	#define IMG_DISH @"plate.png"
	#define IMG_PLUS @"plus.png"

	NSString* const BSDistributionViewControllerProfileViewDishes = @"dishes";
   	NSString* const BSDistributionViewControllerProfileViewDishCount = @"dishCount"; 
	NSString* const BSDistributionViewControllerProfileViewImageButton = @"image";
	NSString* const BSDistributionViewControllerProfileViewRemoveButton = @"remove";
	NSString* const BSDistributionViewControllerProfileViewTextField = @"textField";
	NSString* const BSDistributionViewControllerProfileViewStepper = @"stepper";
	NSString* const BSDistributionViewControllerProfileViewCard = @"card";

#pragma mark - Internal mini class for scrollView container

@interface BSDistributionContainerView : UIView
	@property (nonatomic, strong) UIView *targetView;
@end
@implementation BSDistributionContainerView
- (UIView *) hitTest:(CGPoint) point withEvent:(UIEvent *)event {
	UIView* child = nil;
    if ((child = [super hitTest:point withEvent:event]) == self) {
    	return self.targetView;
	}
    return child;
}
@end


#pragma mark - BSDistributionViewController

@interface BSDistributionViewController () <
    CustomPageControlDelegate,
    UIAlertViewDelegate
>

	@property (nonatomic, assign) CGRect frame;

	/** For dragging & dropping items */
    @property (nonatomic, strong) UIButton *drinkDragButton;
	@property (nonatomic, strong) UIButton *smallDishDragButton;
	@property (nonatomic, strong) UIButton *mediumDishDragButton;
	@property (nonatomic, strong) UIButton *largeDishDragButton;
    
	@property (nonatomic, assign) UIButton *tappedDish;
	@property (nonatomic, strong) UIImageView *draggedView;
	@property (nonatomic, strong) UIView *dragTargetView;
	@property (nonatomic, assign) CGPoint dragPointer;

	/** For sideswipping between diners */
	@property (nonatomic, strong) UIScrollView *scrollView;
	@property (nonatomic, strong) CustomPageControl *pageControl;
	@property (nonatomic, assign) int lastShownProfile;
    
    /** For formatting */
    @property (nonatomic, strong) NSNumberFormatter *numFormatter;

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
		
		_headCount = STEPPER_DEFAULT_MAX_VALUE;
		
		_addButton = [[UIButton alloc] initWithFrame:CGRectZero];
        
        _instructionIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IMG_ARROWHEAD]];
        _instructionCover = [[UIView alloc] initWithFrame:CGRectZero];
        _instructionCover2 = [[UIView alloc] initWithFrame:CGRectZero]; 
        
        _warningLabel = [[UILabel alloc] initWithFrame:CGRectZero];  
		
		_profiles = [NSMutableArray new];
		_lastShownProfile = 0;
		
		_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewPanned:)];
		_panGesture.delaysTouchesBegan = false;
        
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
	
	// UI Setup
	[self setupDishes:bounds];
	[self setupBackgroundView:bounds];
	[self setupScrollView:bounds];
	[self setupPageControl:bounds];
	[self setupAddView:bounds];
    [self setupInstructionIV:bounds]; 
	
	// Add pan gesture for dragging
	[self.view addGestureRecognizer:self.panGesture];
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
       
    // Refresh drag button positions for distro
    [self refreshDragButtonPositions]; 
    
    // Show the arrow if no profiles set
    [self showInstructionIV:(!self.profiles.count)];
}

/** @brief Dispose of any resources that can be recreated. */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
	// Reset view, remove all distribution profiles but first
	self.scrollView.userInteractionEnabled = false;
	for (int i = 0; i < self.profiles.count; ++i) {
		[[[self.profiles objectAtIndex:i]
			objectForKey:BSDistributionViewControllerProfileViewCard]
				removeFromSuperview];
	}
	[self.profiles removeAllObjects];
	
	// Update first, or will crash when adding diner
	[self refreshScrollView];
	[self updateSteppers];
	self.scrollView.userInteractionEnabled = true;
}

/** @brief Return supported orientations */
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - Class Functions

/** @brief When setting the number of diners, also update steppers maxes */
- (void)setHeadCount:(NSInteger)headCount
{
    // If going fewer, then need to clean up to avoid invalid state
    if (headCount < _headCount) {
        [self didReceiveMemoryWarning];
    }
    
	_headCount = headCount;
}

/** @brief Updates all steppers with headCount as max */
- (void)updateSteppers
{
	int currentCount = [self dinerCount];

	for (NSDictionary *profile in self.profiles)
	{
		UIVerticalStepper *stepper = [profile
			objectForKey:BSDistributionViewControllerProfileViewStepper];
		stepper.maximumValue = MAX(stepper.minimumValue,
			(self.headCount - currentCount) + stepper.value);
			
		UITextField *textField = [profile
			objectForKey:BSDistributionViewControllerProfileViewTextField];
		textField.text = [NSString stringWithFormat:@"%i", (NSInteger)stepper.value];
	}
}

/** @brief Scrolls scrollview to page */
- (void)scrollToPage:(NSInteger)page
{
	[self.scrollView scrollRectToVisible:CGRectMake(
		[self offsetForPageInScrollView:page], 0,
		self.scrollView.bounds.size.width, self.scrollView.bounds.size.height
	) animated:true];
}

/** @brief Adds a new diner */
- (void)addDiner:(UIView *)dish
{
    // Check if we can still add another diner and fit headcount
    if ([self dinerCount] >= self.headCount) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You're over your headcount! Would you like to go to the first screen to add more people to your party?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] show];
        return;
    }

    // Setup
	CGRect bounds = self.scrollView.bounds;
	CGRect frame = bounds;
	float itemSize = bounds.size.height - UI_SIZE_DINER_MARGIN * 2;
	
	// Container for elements
	frame.origin.x = -self.scrollView.frame.origin.x - bounds.size.width;
	frame = CGRectInset(frame, UI_SIZE_DINER_MARGIN, 0);
	UIView *containerView = [[UIView alloc] initWithFrame:frame];
	containerView.clipsToBounds = true;
	containerView.backgroundColor = [UIColor whiteColor];
	
	// Container for dishes
	UIView *dishView = [[UIView alloc] initWithFrame:CGRectMake(
		0, 0, UI_SIZE_MIN_TOUCH, itemSize
	)];
	dishView.backgroundColor = [UIColor clearColor];
	[containerView addSubview:dishView];

	// Remove Diner button
	UIButton *removeButton = [[UIButton alloc] initWithFrame:CGRectMake(
		containerView.bounds.size.width - UI_SIZE_MIN_TOUCH / 5 * 2 - UI_SIZE_DINER_MARGIN,
		UI_SIZE_DINER_MARGIN,
		UI_SIZE_MIN_TOUCH / 2, UI_SIZE_MIN_TOUCH / 2
	)];
	[removeButton setTitle:@"X" forState:UIControlStateNormal];
	removeButton.contentHorizontalAlignment
		= UIControlContentHorizontalAlignmentCenter;
	removeButton.contentVerticalAlignment
		= UIControlContentVerticalAlignmentCenter;
	[removeButton setTitleColor:UIColorFromHex(COLOR_HEX_BACKGROUND_GRAY_TRANSLUCENT)
		forState:UIControlStateNormal];
	[removeButton setTitleColor:[UIColor grayColor]
		forState:UIControlStateHighlighted];
	removeButton.titleLabel.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_COPY];
	[removeButton addTarget:self action:@selector(removeDinerButtonPressed:)
		forControlEvents:UIControlEventTouchUpInside];
	[containerView addSubview:removeButton];

	// Stepper for textfield
	UIVerticalStepper *stepper = [[UIVerticalStepper alloc] init];
	stepper.frame = CGRectMake(
		containerView.bounds.size.width - stepper.frame.size.width - UI_SIZE_DINER_MARGIN,
		containerView.bounds.size.height - stepper.frame.size.height - UI_SIZE_DINER_MARGIN,
		stepper.frame.size.width, stepper.frame.size.height
	);
	stepper.minimumValue = STEPPER_MIN_VALUE;
	stepper.maximumValue = MAX(STEPPER_MIN_VALUE,
		(self.headCount - [self dinerCount]));
	stepper.value = ([self dinerCount] >= self.headCount)
		? 0 : STEPPER_DEFAULT_VALUE;
	stepper.delegate = self;
	[containerView addSubview:stepper];
	
	// Textfield for count of diners
	frame = stepper.frame;
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(
		(containerView.frame.size.width - bounds.size.width / 2) / 2,
		CGRectGetMinY(frame),
		bounds.size.width / 2,
		CGRectGetHeight(frame)
	)];
	textField.text = [NSString stringWithFormat:@"%i", (NSInteger)stepper.value];
	textField.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_PRICE];
    textField.textColor = [UIColor grayColor];
	textField.textAlignment = NSTextAlignmentCenter;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	textField.userInteractionEnabled = false;
	[containerView addSubview:textField];
	
	// Image button to drag items onto
	frame = textField.frame;
	UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(
		CGRectGetMinX(frame), UI_SIZE_DINER_MARGIN,
		CGRectGetWidth(frame), bounds.size.height - UI_SIZE_DINER_MARGIN - CGRectGetHeight(frame)
	)];
	[imageButton setImage:[UIImage imageNamed:IMG_DINER]
		forState:UIControlStateNormal];
	imageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
	[containerView addSubview:imageButton];

	// Fade out instructional image if there are profiles
	if (!self.profiles.count) {
		[self showInstructionIV:false];
	}
	
	// Keeping track of elements, need to be mutable for edits later
    int addIndex = 0;
	[self.profiles insertObject:[@{
   		BSDistributionViewControllerProfileViewDishCount : [@{
            @(BSDishSetupViewControllerItemDrink): @0,
            @(BSDishSetupViewControllerItemSmallDish): @0, 
            @(BSDishSetupViewControllerItemMediumDish): @0, 
            @(BSDishSetupViewControllerItemLargeDish): @0, 
        } mutableCopy],
		BSDistributionViewControllerProfileViewDishes : dishView,
		BSDistributionViewControllerProfileViewImageButton : imageButton,
		BSDistributionViewControllerProfileViewRemoveButton : removeButton,
		BSDistributionViewControllerProfileViewTextField : textField,
		BSDistributionViewControllerProfileViewStepper : stepper,
		BSDistributionViewControllerProfileViewCard : containerView,
	} mutableCopy] atIndex:addIndex];
	[self.scrollView addSubview:containerView];
	
	// Update scrollview & scroll over to new card section
	[self refreshScrollView];
	[self updateSteppers];
	[self scrollToPage:0];
	
	// Animate card in and other cards over one
	frame = containerView.frame;
	frame.origin.x = 0;
	[UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
		options:UIViewAnimationOptionBeginFromCurrentState
			| UIViewAnimationOptionCurveEaseInOut
		animations:^
		{
			containerView.frame = frame;
			UIView *tempView;
			CGRect tempFrame;
			
			// Animate other cards to right
			for (int i = 1; i < self.profiles.count; ++i) {
				tempView = [[self.profiles objectAtIndex:i]
					objectForKey:BSDistributionViewControllerProfileViewCard];
				tempFrame = tempView.frame;
				tempFrame.origin.x += bounds.size.width;
				tempView.frame = tempFrame;
			}
		} completion:nil];
	
	// Adding dish if exists to profile added index
	if (dish) {
		[self addDish:dish toDinerAtIndex:addIndex completion:nil];
	}
}

/** @brief Add dish to diner */
- (void)addDish:(UIView *)dish toDinerAtIndex:(NSInteger)index completion:(void (^)(BOOL finished))completion
{
	UIView *dishView = [[self.profiles objectAtIndex:index]
		objectForKey:BSDistributionViewControllerProfileViewDishes];
    NSMutableDictionary *dishCount = [[self.profiles objectAtIndex:index]
		objectForKey:BSDistributionViewControllerProfileViewDishCount]; 

    // Get count of dishes for the profile
    NSInteger count = [dishCount[@(dish.tag)] integerValue];
    [dishCount setObject:[NSNumber numberWithInteger:count + 1] forKey:@(dish.tag)]; 
    
    // Add dish if DNS
    if (count <= 0)
    {
        // Frame should be in dish view
        CGRect frame = CGRectMake(
            UI_SIZE_DINER_MARGIN / 4,
            dishView.subviews.count * (dishView.bounds.size.width),
            dishView.bounds.size.width - UI_SIZE_DINER_MARGIN / 2, 
            dishView.bounds.size.width
        );
        
        // Reset to zero size, identity transform
        float scale = [self scaleForDishTag:dish.tag]; 
        dish.transform = CGAffineTransformIdentity;
        dish.frame = frame;
        dish.transform = CGAffineTransformMakeScale(0, 0);
        [dishView addSubview:dish];
        
        // Add badge number label in advance
        float badgeScale = 1 / scale;
        UILabel *badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(
            CGRectGetWidth(frame) - UI_SIZE_BADGE_HEIGHT, 
            CGRectGetHeight(frame) - UI_SIZE_BADGE_HEIGHT, 
            UI_SIZE_BADGE_HEIGHT, UI_SIZE_BADGE_HEIGHT
        )];
        badgeLabel.transform = CGAffineTransformMakeScale(badgeScale, badgeScale); 
        badgeLabel.backgroundColor = [UIColor redColor];
        badgeLabel.textColor = [UIColor whiteColor];
        badgeLabel.textAlignment = UITextAlignmentCenter;
        badgeLabel.font = [UIFont fontWithName:FONT_NAME_TAGLINE size:FONT_SIZE_BADGE_LABEL];
        badgeLabel.layer.cornerRadius = UI_SIZE_BADGE_CORNER_RADIUS;
        badgeLabel.alpha = 0;
        badgeLabel.text = @"1";
        badgeLabel.tag = TAG_BADGE_LABEL;
        [dish addSubview:badgeLabel];
        
        // Animate blow up in dish view
        [UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
            options:UIViewAnimationOptionBeginFromCurrentState
                | UIViewAnimationOptionCurveEaseOut
            animations:^{
                dish.transform
                    = CGAffineTransformMakeScale(
                        scale, scale);
                dish.alpha = 1;
            } completion:completion];
    }
    else    // Add to badge number label
    {
        // Find the dish that matches what is being added to
        for (UIView *subview in dishView.subviews) {
            if (subview.tag == dish.tag) {
                dish = subview;
                break;
            }
        }
        
        // Find the badge label
        UILabel *badgeLabel; 
        for (UIView *subview in dish.subviews) {
            if (subview.tag == TAG_BADGE_LABEL 
                && [subview isKindOfClass:[UILabel class]]) {
                badgeLabel = (UILabel *)subview;
                break;
            }
        }
        
        // Increment
        NSNumber *number = [self.numFormatter numberFromString:badgeLabel.text];
        if (number) {
            badgeLabel.text = [NSString stringWithFormat:@"%i", 
                [number integerValue] + 1];
        }
        else {  // This shouldn't happen
            NSLog(@"Error getting value from badgeLabel!");
        }
        
        // Animate Bounce on increment
        float scale = badgeLabel.transform.a;
        float bounceScale = scale + SCALE_BADGE_CHANGE;
        [UIView animateWithDuration:ANIMATION_DURATION_FASTEST delay:0 
            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut 
            animations:^{
                badgeLabel.transform = CGAffineTransformMakeScale(
                    bounceScale, bounceScale);
                badgeLabel.alpha = 1;
            } 
            completion:^(BOOL finished) {
                if (finished) {
                    [UIView animateWithDuration:ANIMATION_DURATION_FASTEST delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut 
                        animations:^{
                            badgeLabel.transform = CGAffineTransformMakeScale(scale, scale); 
                        } 
                        completion:nil];
                }
            }];
    }
}

/** @brief Removes diner */
- (void)removeDiner:(NSInteger)index
{
	// Insanity check
	if (!self.profiles.count) {
		return;
	}
	
	// Disable interaction while animating
	self.scrollView.userInteractionEnabled = false;

	UIView *card = [[self.profiles objectAtIndex:index]
		objectForKey:BSDistributionViewControllerProfileViewCard];
	CGRect bounds = self.scrollView.bounds;
	
	[UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
		options:UIViewAnimationOptionBeginFromCurrentState
			| UIViewAnimationOptionCurveEaseInOut
		animations:^
		{
			// Hide card being removed
			card.alpha = 0;
			
			// Setup for animation
			CGRect frame = card.frame;
			UIView *temp;
			
			// If is last card on right, then shift scrollview left
			if (index == self.profiles.count - 1)
			{
				frame.origin.x -= bounds.size.width;
				self.scrollView.contentOffset = frame.origin;
			}
			else	// Shift over cards on the right, display focus on next one
			{
				[self profileAtIndex:index + 1 shouldShowFocus:true];
			
				for (int i = index + 1; i < self.profiles.count; ++i) {
					temp = [[self.profiles objectAtIndex:i]
						objectForKey:BSDistributionViewControllerProfileViewCard];
					frame = temp.frame;
					frame.origin.x -= bounds.size.width;
					temp.frame = frame;
				}
			}
			
			// If no more cards, fade in instructions
			if (self.profiles.count == 1) {
                [self showInstructionIV:true];
			}
		}
		completion:^(BOOL finished)
		{
			// Remove card & data
			[card removeFromSuperview];
			[self.profiles removeObjectAtIndex:index];
			
			// Resize contentSize of scrollview
			[self refreshScrollView];
			self.scrollView.userInteractionEnabled = true;
			
			// Update steppers
			[self updateSteppers];
		}];
}

/** @brief Update page control & content size of scrollview */
- (void)refreshScrollView
{
	CGRect bounds = self.scrollView.bounds;
	self.pageControl.numberOfPages = self.profiles.count;
	self.scrollView.contentSize = CGSizeMake(
		bounds.size.width * self.pageControl.numberOfPages + 1,
		bounds.size.height
	);
}

/** @brief Refreshes positions of drag buttons to match the icons */
- (void)refreshDragButtonPositions
{
    // Custom width for drink
    CGRect frame = [self.view convertRect:self.drinkButton.frame fromView:self.drinkButton.superview];
    frame.origin.x += UI_SIZE_DINER_MARGIN;
    frame.size.width -= UI_SIZE_DINER_MARGIN * 2;
    self.drinkDragButton.frame = frame;
    
    self.smallDishDragButton.frame = [self.view convertRect:self.smallDishButton.frame fromView:self.smallDishButton.superview];
    
    self.mediumDishDragButton.frame = [self.view convertRect:self.mediumDishButton.frame fromView:self.mediumDishButton.superview];
    
    self.largeDishDragButton.frame = [self.view convertRect:self.largeDishButton.frame fromView:self.largeDishButton.superview];
}

/** @brief When bringing profile into focus / becomes the current page */
- (void)profileAtIndex:(NSInteger)index shouldShowFocus:(bool)show
{
	NSDictionary *profile = [self.profiles objectAtIndex:index];
	[[profile objectForKey:BSDistributionViewControllerProfileViewRemoveButton]
		setAlpha:show];
	[[profile objectForKey:BSDistributionViewControllerProfileViewStepper]
		setAlpha:show];
}

/** @brief Show instructional arrow */
- (void)showInstructionIV:(bool)show
{
    [UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
        options:UIViewAnimationOptionBeginFromCurrentState
            | UIViewAnimationOptionCurveEaseInOut
        animations:^{
            self.instructionIV.alpha = (show) ? 1 : 0;
        } completion:nil];
}


#pragma mark - UI Setup

/** @brief Setup buttons for dishes */
- (void)setupDishes:(CGRect)bounds
{
    NSMutableArray *dishes = [NSMutableArray new];
	CGRect frame = CGRectMake(
		UI_SIZE_MARGIN + UI_SIZE_DINER_MARGIN, 
        UI_SIZE_DINER_MARGIN,
		(bounds.size.width - UI_SIZE_DINER_MARGIN * 5 - UI_SIZE_MARGIN * 2) / 4,
		bounds.size.height / 6 - UI_SIZE_DINER_MARGIN * 2
	);
	self.drinkDragButton = [UIButton new];
	self.drinkDragButton.tag = self.drinkButton.tag;
    [dishes addObject:self.drinkDragButton];
	
	self.smallDishDragButton = [UIButton new];
	self.smallDishDragButton.tag = self.smallDishButton.tag;
    [dishes addObject:self.smallDishDragButton]; 
	
	self.mediumDishDragButton = [UIButton new];
	self.mediumDishDragButton.tag = self.mediumDishButton.tag;
    [dishes addObject:self.mediumDishDragButton];  
	
	self.largeDishDragButton = [UIButton new];
	self.largeDishDragButton.tag = self.largeDishButton.tag;
    [dishes addObject:self.largeDishDragButton];   
    
    for (UIButton *dragButton in dishes)
    {
        frame.origin.x = CGRectGetMaxX(frame) + UI_SIZE_DINER_MARGIN; 
        dragButton.frame = frame;
        [dragButton addTarget:self action:@selector(dishButtonPressed:) 
            forControlEvents:UIControlEventTouchDown]; 
        [self.view addSubview:dragButton];
    }
}

/** @brief Setup instructional image view */
- (void)setupInstructionIV:(CGRect)bounds
{
    CGRect frame = self.instructionIV.frame;
    frame.origin = CGPointMake(
        CGRectGetMaxX(self.addButton.frame) + UI_SIZE_DINER_MARGIN, 
        CGRectGetMinY(self.addButton.frame) - UI_SIZE_MARGIN
    );
    self.instructionIV.frame = frame;
    self.instructionIV.clipsToBounds = true;
    [self.view addSubview:self.instructionIV];
   
    self.instructionCover2.frame = self.instructionIV.bounds;
    self.instructionCover2.backgroundColor = UIColorFromHex(COLOR_HEX_ACCENT);
    [self.instructionIV addSubview:self.instructionCover2];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IMG_ARROW]];
    imageView.frame = self.instructionIV.bounds;
    [self.instructionIV addSubview:imageView]; 
     
    self.instructionCover.frame = self.instructionIV.bounds;
    self.instructionCover.backgroundColor = UIColorFromHex(COLOR_HEX_ACCENT);
    [self.instructionIV addSubview:self.instructionCover]; 
}
    
/** @brief Setup background view */
- (void)setupBackgroundView:(CGRect)bounds
{
	UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(
		0, bounds.size.height / 4,
		bounds.size.width, bounds.size.height * 1.15
	)];
	backgroundView.backgroundColor = UIColorFromHex(COLOR_HEX_ACCENT);
	[self.view addSubview:backgroundView];
}

/** @brief Setup scrollView */
- (void)setupScrollView:(CGRect)bounds
{
	BSDistributionContainerView *containerView
		= [[BSDistributionContainerView alloc] initWithFrame:CGRectMake(
		0, bounds.size.height / 4 + UI_SIZE_PAGECONTROL_HEIGHT,
		bounds.size.width, 
        bounds.size.height 
            - UI_SIZE_STATUS_BAR_HEIGHT
            - UI_SIZE_RESET_BUTTON_HEIGHT 
            - UI_SIZE_RESET_BUTTON_MARGIN * 2
            - (bounds.size.height / 4 + UI_SIZE_PAGECONTROL_HEIGHT)
	)];
	containerView.userInteractionEnabled = true;
	
	self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(
		bounds.size.width / 4, 0,
		bounds.size.width / 2, containerView.bounds.size.height
	)];
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

/** @brief Setup page control */
- (void)setupPageControl:(CGRect)bounds
{
	self.pageControl = [[CustomPageControl alloc] initWithFrame:CGRectMake(
		0, bounds.size.height / 4,
		bounds.size.width, UI_SIZE_PAGECONTROL_HEIGHT
	)];
	
	// Configure
	self.pageControl.delegate = self;
	self.pageControl.numberOfPages = 0;
	self.pageControl.currentPage = 0;
	self.pageControl.currentDotTintColor = UIColorFromHex(COLOR_HEX_COPY_DARK);
	self.pageControl.dotTintColor = UIColorFromHex(COLOR_HEX_BACKGROUND_LIGHT_TRANSLUCENT);
	
	[self.view addSubview:self.pageControl];
}

/** @brief Setup add view */
- (void)setupAddView:(CGRect)bounds
{
	self.addButton.frame = CGRectMake(
		0, self.pageControl.frame.origin.y + UI_SIZE_PAGECONTROL_HEIGHT,
		bounds.size.width / 8, self.scrollView.bounds.size.height
	);
	[self.addButton setImage:[UIImage imageNamed:IMG_PLUS] forState:UIControlStateNormal];
	self.addButton.imageEdgeInsets = UIEdgeInsetsMake(
		UI_SIZE_DINER_MARGIN, UI_SIZE_DINER_MARGIN,
		UI_SIZE_DINER_MARGIN, UI_SIZE_DINER_MARGIN
	);
	self.addButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	
	// Gradient background
	CAGradientLayer *gradientBG = [CAGradientLayer layer];
	gradientBG.colors = [NSArray arrayWithObjects:
		(id)UIColorFromHex(0xFFFFFF44).CGColor,
		(id)UIColorFromHex(0xFFFFFFBB).CGColor,
		(id)UIColorFromHex(0xFFFFFFFF).CGColor,
		nil
	];
	gradientBG.transform = CATransform3DMakeRotation(
		degreesToRadians(90), 0, 0, 1);
	gradientBG.frame = self.addButton.bounds;
	[self.addButton.layer insertSublayer:gradientBG atIndex:0];
	
	[self.addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	// Add gesture using swipe
	UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(addButtonSwiped:)];
	swipe.direction = UISwipeGestureRecognizerDirectionRight;
	swipe.delaysTouchesBegan = false;
	swipe.delaysTouchesEnded = false;
	[self.panGesture requireGestureRecognizerToFail:swipe];
	[self.addButton addGestureRecognizer:swipe];
	
	[self.view addSubview:self.addButton];
}


#pragma mark - UI Events

/** @brief Add button is pressed / dropped */
- (void)addButtonPressed:(UIView *)view
{
	[self addDiner:(view == self.addButton ? nil : view)];
}

/** @brief Add button is swiped on */
- (void)addButtonSwiped:(UISwipeGestureRecognizer *)gesture
{
	[self addDiner:nil];
}

/** @brief Droppable view not hovered over any more */
- (void)droppableHoveredOut:(UIView *)view
{
	if (view) {
		[UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
			options:UIViewAnimationOptionBeginFromCurrentState
				| UIViewAnimationOptionCurveEaseInOut
			animations:^{
				view.transform = CGAffineTransformIdentity;
			} completion:nil];
	}
}

/** @brief Droppable view hovered over */
- (void)droppableHoveredOver:(UIView *)view
{
	if (view) {
		[UIView animateWithDuration:HOVER_SPEED delay:0
			options:UIViewAnimationOptionBeginFromCurrentState
				| UIViewAnimationOptionCurveEaseOut
			animations:^{
				view.transform = CGAffineTransformMakeScale(
					HOVER_SCALE, HOVER_SCALE);
			} completion:nil];
	}
}

/** @brief X button pressed on diner profile card */
- (void)removeDinerButtonPressed:(UIButton *)button
{
	// Remove card at current page
    [self removeDiner:self.pageControl.currentPage];
}


/** @brief Dish button touch down on */
- (void)dishButtonPressed:(UIButton *)button
{
	self.tappedDish = button;
}

/** @brief View panned on, to do dragging */
- (void)viewPanned:(UIPanGestureRecognizer *)gesture
{
	// Create a draggable if panning started & tappedDish exists
	if (self.tappedDish && gesture.state == UIGestureRecognizerStateBegan)
	{
		// Figure out which dish was pressed
		UIButton *dish;
		switch (self.tappedDish.tag)
		{
			case BSDishSetupViewControllerItemDrink:
				dish = self.drinkButton; break;
				
			case BSDishSetupViewControllerItemSmallDish:
				dish = self.smallDishButton; break;
				
			case BSDishSetupViewControllerItemMediumDish:
				dish = self.mediumDishButton; break;
				
			case BSDishSetupViewControllerItemLargeDish:
				dish = self.largeDishButton; break;
				
			default: break;
		}
	
		// Create draggable
		self.draggedView = [[UIImageView alloc] initWithFrame:CGRectMake(
			self.tappedDish.frame.origin.x, self.tappedDish.frame.origin.y,
			dish.frame.size.width, dish.frame.size.height
		)];
		self.draggedView.image = dish.imageView.image;
		self.draggedView.contentMode = UIViewContentModeScaleAspectFit;
		self.draggedView.alpha = DRAG_ALPHA;
		self.draggedView.tag = self.tappedDish.tag;
		[self.view addSubview:self.draggedView];
	
		// Reset target
		self.dragTargetView = nil;
	}

	// Only do stuff if dragged view exists
	if (!self.draggedView) {
		return;
	}
	
	// Keep track of pointer
	self.dragPointer = [gesture locationInView:self.view];
	
	// Actions based on state
	switch (gesture.state)
	{
		// Stopped dragging, let go of item
		case UIGestureRecognizerStateEnded:
		{
			[UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
				options:UIViewAnimationOptionBeginFromCurrentState
					| UIViewAnimationOptionCurveEaseIn
				animations:^{
					// Shrink animation for drop
					self.draggedView.transform
						= CGAffineTransformMakeScale(0, 0);
				}
				completion:^(BOOL finished)
				{
					// If there's a target, add to it
					if (self.dragTargetView)
					{
						// Scale target back to normal
						[self droppableHoveredOut:self.dragTargetView];
						
						// If is add button, then add new diner with dish
						if (self.dragTargetView == self.addButton)
						{
							[self addDiner:self.draggedView];
							self.draggedView = nil;
						}
						else	// Find diner profile to add to
						{
							// Get index of view
							int index = [self indexOfProfileView:self.dragTargetView];
							
							// Insanity checks
							if (index == NSNotFound) {
								NSLog(@"Warning! Not a valid drop target!");
							}
							else	// Add dish to diner with animation
							{
								[self addDish:self.draggedView
									toDinerAtIndex:index
									completion:nil];
								self.draggedView = nil;
							}
						}
					}
					else	// Not dropped in anything, remove and clear
					{
						[self.draggedView removeFromSuperview];
						self.draggedView = nil;
					}
				}];
			
			// Reset tapped dish
			self.tappedDish = nil;
		} break;
		
		// Mid-drag, calculate potential targets
		case UIGestureRecognizerStateChanged:
		{
			// Find a view target
			UIView *targetView;
			
			// See if pointer is in add view
			if (CGRectContainsPoint(self.addButton.frame, self.dragPointer)) {
				targetView = self.addButton;
			}
			else	// Get potential profile target
			{
				targetView = [self profileViewIntersectedByPoint:self.dragPointer];
				
				// If dragged to profile not on current page, shift over one
				if (targetView && targetView.tag != self.pageControl.currentPage) {
					[self scrollToPage:targetView.tag];
				}
			}
			
			// If targetView and dragTargetView are different, animate change
			if (self.dragTargetView != targetView)
			{
				[self droppableHoveredOver:targetView];
				[self droppableHoveredOut:self.dragTargetView];
				self.dragTargetView = targetView;
			}
		} // No break to allow to fall through and translate
			
		// Move view to translated location
		default:
		{
			CGPoint translation = [gesture translationInView:gesture.view];
			CGRect frame = CGRectOffset(self.draggedView.frame,
				translation.x, translation.y);
			
			[UIView animateWithDuration:DRAG_SPEED delay:0
				options:UIViewAnimationOptionBeginFromCurrentState
					| UIViewAnimationOptionCurveEaseOut
				animations:^{
					self.draggedView.frame = frame;
				} completion:nil];
		} break;
	}
	
	// Reset so we can add incrementally
	[gesture setTranslation:CGPointZero inView:gesture.view];
}


#pragma mark - Utility Functions

/** @brief Returns first view that contains the given point, with the index in the view's tag property */
- (UIView *)profileViewIntersectedByPoint:(CGPoint)point
{
	UIView *tempView;
	
	// Loop through profiles and calculate
	for (int i = 0; i < self.profiles.count; ++i)
	{
		tempView = [[self.profiles objectAtIndex:i]
			objectForKey:BSDistributionViewControllerProfileViewCard];
		tempView.tag = i;
		
		if (CGRectContainsPoint(
			[self.view convertRect:tempView.frame fromView:tempView.superview], point)) {
			return tempView;
		}
	}
	return nil;
}

/** @brief Returns view that is most overlapped by the given CGRect, with the index in the view's tag property */
- (UIView *)profileViewMostIntersectedByRect:(CGRect)frame
{
	float largestArea = 0, tempArea = 0;
	UIView *largestView, *tempView;
	CGRect tempFrame;
	
	// Loop through profiles and calculate
	for (int i = 0; i < self.profiles.count; ++i)
	{
		tempView = [[self.profiles objectAtIndex:i]
			objectForKey:BSDistributionViewControllerProfileViewCard];
		tempView.tag = i;
		tempFrame = CGRectIntersection(frame,
			[self.view convertRect:tempView.frame fromView:tempView.superview]);
		tempArea = tempFrame.size.width * tempFrame.size.height;
		
		// Compare
		if (tempArea > largestArea)
		{
			largestArea = tempArea;
			largestView = tempView;
		}
	}
	
	return largestView;
}

/** @brief Get index of card, for dragging target finding */
- (NSInteger)indexOfProfileView:(UIView *)profile
{
	for (int i = 0; i < self.profiles.count; ++i) {
		if ([[self.profiles objectAtIndex:i]
				objectForKey:BSDistributionViewControllerProfileViewCard]
					== profile) {
			return i;
		}
	}
	
	return NSNotFound;
}

/** @brief Current number of diners set up */
- (NSInteger)dinerCount
{
	int count = 0;
	for (NSDictionary *profile in self.profiles) {
		UIVerticalStepper *stepper = [profile objectForKey:BSDistributionViewControllerProfileViewStepper];
		count += stepper.value;
	}
	return count;
}

/** Returns scaling for given dish tag */
- (CGFloat)scaleForDishTag:(BSDishSetupViewControllerItem)tag
{
    switch (tag)
    {
        case BSDishSetupViewControllerItemSmallDish:
            return IMAGEVIEW_SCALE_SMALLDISH;
        case BSDishSetupViewControllerItemMediumDish:
            return IMAGEVIEW_SCALE_MEDIUMDISH;
        default:
            return 1;
    }
}

/** @brief Returns point offset for given page in scroll view */
- (CGFloat)offsetForPageInScrollView:(NSInteger)page
{
	return self.scrollView.bounds.size.width * page;
}


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
    float pageSize = scrollView.bounds.size.width;
    int page = floor((scrollView.contentOffset.x - pageSize / 2) / pageSize) + 1;

	// Bound page limits
	if (page >= self.profiles.count) {
		page = self.profiles.count - 1;
	} else if (page < 0) {
		page = 0;
	}
	
	// If new page not the same as last shown page, update
	if (page != self.lastShownProfile && self.profiles.count)
	{
		// Show / hide remove buttons
		[UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
			options:UIViewAnimationOptionBeginFromCurrentState
				| UIViewAnimationOptionCurveEaseInOut
			animations:^{
				[self profileAtIndex:page shouldShowFocus:true];
				[self profileAtIndex:self.lastShownProfile shouldShowFocus:false];
			} completion:nil];

		self.lastShownProfile = page;
	}
		
    self.pageControl.currentPage = page;
}


#pragma mark - UIVerticalStepperDelegate

- (void)stepperValueDidChange:(UIVerticalStepper *)stepper
{
	[[[self.profiles objectAtIndex:self.pageControl.currentPage]
		objectForKey:BSDistributionViewControllerProfileViewTextField]
			setText:[NSString stringWithFormat:@"%i", (NSInteger)stepper.value]];
			
	// Update all other steppers
	[self updateSteppers];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex) {  // Selected Ok
        if (self.delegate && [self.delegate respondsToSelector:@selector(distributionViewController:scrollToPage:)]) {
            [self.delegate distributionViewController:self scrollToPage:0];
        }
    }
}


@end
