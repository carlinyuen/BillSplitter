/**
	@file	BSHeadcountViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSHeadcountViewController.h"

   	#define UI_SIZE_LABEL_HEIGHT 36 
	#define UI_SIZE_LABEL_MARGIN 24
	#define UI_SIZE_MARGIN 16

	#define STEPPER_MIN_VALUE 1
	#define STEPPER_MAX_VALUE 50
   	#define STEPPER_DEFAULT_VALUE 2
    
    #define SCALE_TEXTFIELD_CHANGE 1.1

	#define IMG_MAN @"man.png"
   	#define IMG_DOWN @"down.png" 
    
    #define KEY_TIMER_DURATION @"duration"
    #define KEY_TIMER_VIEW @"view" 

@interface BSHeadcountViewController ()

	@property (nonatomic, assign) CGRect frame;
    
   	@property (nonatomic, strong) NSTimer *flashTimer;

@end


#pragma mark - Implementation

@implementation BSHeadcountViewController

/** @brief Initialize data-related properties */
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
	{
		_frame = frame;
		
		_taglineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_welcomeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		_textField = [[UITextField alloc] initWithFrame:CGRectZero];
		_stepper = [[UIVerticalStepper alloc] initWithFrame:CGRectZero];
        
        _instructionIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IMG_DOWN]];
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
	CGRect frame;

	self.taglineLabel.text = NSLocalizedString(@"HEADCOUNT_TAGLINE_TEXT", nil);
	self.taglineLabel.backgroundColor = [UIColor whiteColor];
	self.taglineLabel.textAlignment = NSTextAlignmentCenter;
	self.taglineLabel.textColor = [UIColor darkGrayColor];
	self.taglineLabel.font = [UIFont fontWithName:FONT_NAME_TAGLINE size:FONT_SIZE_TAGLINE];
	self.taglineLabel.frame = CGRectMake(
		UI_SIZE_MARGIN, UI_SIZE_MARGIN,
		bounds.size.width - UI_SIZE_MARGIN * 2, UI_SIZE_LABEL_HEIGHT
	);
	
	frame = self.taglineLabel.frame;
	self.welcomeLabel.text = NSLocalizedString(@"HEADCOUNT_DESCRIPTION_TEXT", nil);
	self.welcomeLabel.numberOfLines = 0;
	self.welcomeLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.welcomeLabel.backgroundColor = [UIColor whiteColor];
	self.welcomeLabel.textAlignment = NSTextAlignmentCenter;
	self.welcomeLabel.textColor = [UIColor grayColor];
	self.welcomeLabel.font = [UIFont fontWithName:FONT_NAME_COPY size:FONT_SIZE_COPY];
	self.welcomeLabel.frame = CGRectMake(
		UI_SIZE_LABEL_MARGIN, CGRectGetMaxY(frame),
		bounds.size.width - UI_SIZE_LABEL_MARGIN * 2, 
        bounds.size.height
	);
    [self.welcomeLabel sizeToFit];
   	frame = self.welcomeLabel.frame; 
    frame.origin.x = (bounds.size.width - CGRectGetWidth(frame)) / 2;
   	self.welcomeLabel.frame = frame;
	
	frame = self.welcomeLabel.frame;
	self.imageView.frame = CGRectMake(
		bounds.size.width / 8, 
        CGRectGetMaxY(frame),
		bounds.size.width / 4, 
        bounds.size.height / 3 * 2
	);
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	self.imageView.image = [UIImage imageNamed:IMG_MAN];
	self.imageView.clipsToBounds = true;
	
	frame = self.imageView.frame;
	self.textField.frame = CGRectMake(
		CGRectGetMaxX(frame),
		(frame.size.height - (bounds.size.height / 3)) / 2 + frame.origin.y,
		bounds.size.width / 3,
        bounds.size.height / 3
	);
	self.textField.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_HEADCOUNT];
	self.textField.borderStyle = UITextBorderStyleNone;
	self.textField.keyboardAppearance = UIKeyboardAppearanceAlert;
	self.textField.keyboardType = UIKeyboardTypeNumberPad;
	self.textField.textAlignment = NSTextAlignmentCenter;
	self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	frame = self.textField.frame;
	self.stepper.frame = CGRectMake(
		CGRectGetMaxX(frame),
		(frame.size.height - self.stepper.frame.size.height) / 2 + frame.origin.y,
		self.stepper.frame.size.width, 
        self.stepper.frame.size.height
	);
	self.stepper.delegate = self;
	self.stepper.maximumValue = STEPPER_MAX_VALUE;
	self.stepper.minimumValue = STEPPER_MIN_VALUE;
	self.stepper.value = STEPPER_DEFAULT_VALUE;
	
	frame = self.imageView.frame;
	
	[self.view addSubview:self.taglineLabel];
	[self.view addSubview:self.welcomeLabel];
	[self.view addSubview:self.imageView];
	[self.view addSubview:self.stepper];
	[self.view addSubview:self.textField];
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
	
	// Reset values
	self.stepper.value = STEPPER_DEFAULT_VALUE;
}

/** @brief Return supported orientations */
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - Class Functions

/** @brief Show instructionIV by flashing */
- (void)showInstructions:(bool)show
{
    if (show)
    {
        self.flashTimer = [NSTimer scheduledTimerWithTimeInterval:ANIMATION_DURATION_SLOW * 2 
            target:self selector:@selector(flashView:) userInfo:@{
                KEY_TIMER_VIEW: self.instructionIV,
                KEY_TIMER_DURATION: @(ANIMATION_DURATION_SLOW * 2),
            } repeats:true];
    }
    else    // Hide
    {
        if (self.flashTimer) {
            [self.flashTimer invalidate];
            self.flashTimer = nil;
        }
    
        // Fade out
        [UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
            options:UIViewAnimationOptionBeginFromCurrentState
                | UIViewAnimationOptionCurveEaseInOut
            animations:^{
                self.instructionIV.alpha = 1;
            } completion:nil];
    }
}

/** @brief Animate flash view with duration (one flash) */
- (void)flashView:(NSTimer *)timer
{
    // Get data from timer if exists
    CGFloat duration = ANIMATION_DURATION_SLOW;
    UIView *view = nil;
    if (timer)
    {
        duration = [timer.userInfo[KEY_TIMER_DURATION] floatValue];
        view = timer.userInfo[KEY_TIMER_VIEW];
    }
    
    // Animate
    [UIView animateWithDuration:duration / 2 delay:0
        options:UIViewAnimationOptionBeginFromCurrentState
        animations:^{
            [view setAlpha:1];
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:duration / 2 delay:0
                    options:UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
                        [view setAlpha:0.20];
                    } completion:nil];
            }
        }];  
}


#pragma mark - Utility Functions


#pragma mark - Delegates
#pragma mark - UIVerticalStepperDelegate

- (void)stepperValueDidChange:(UIVerticalStepper *)stepper
{
	self.textField.text = [NSString stringWithFormat:@"%i", (NSInteger)stepper.value];
	
	// Change image based on number
	// TODO
    
    // Let delegate know
    if (self.delegate && [self.delegate respondsToSelector:@selector(headCountViewController:countChanged:)]) {
        [self.delegate headCountViewController:self countChanged:(NSInteger)stepper.value];
    }
     
    // Bounce on change
    [UIView animateWithDuration:ANIMATION_DURATION_FASTEST delay:0 
        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut 
        animations:^{
            self.textField.transform = CGAffineTransformMakeScale(
                SCALE_TEXTFIELD_CHANGE, SCALE_TEXTFIELD_CHANGE);
        } 
        completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:ANIMATION_DURATION_FASTEST delay:0 
                    options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut 
                    animations:^{
                        self.textField.transform = CGAffineTransformIdentity;
                    } 
                    completion:nil];
            }
        }];
}


@end
