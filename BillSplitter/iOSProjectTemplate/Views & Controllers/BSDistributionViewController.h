/**
	@file	BSDistributionViewController.h
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

#import "UIVerticalStepper.h"

@class BSDistributionViewController;
@protocol BSDistributionViewControllerDelegate <NSObject>

    @optional
    /** User requested to scroll to given page */
    - (void)distributionViewController:(BSDistributionViewController *)vc scrollToPage:(NSInteger)index;

@end


#pragma mark - BSDistributionViewController

	extern NSString* const BSDistributionViewControllerProfileViewDishes;
   	extern NSString* const BSDistributionViewControllerProfileViewDishCount;
	extern NSString* const BSDistributionViewControllerProfileViewImageButton;
	extern NSString* const BSDistributionViewControllerProfileViewRemoveButton;
	extern NSString* const BSDistributionViewControllerProfileViewTextField;
	extern NSString* const BSDistributionViewControllerProfileViewStepper;
	extern NSString* const BSDistributionViewControllerProfileViewCard;

@interface BSDistributionViewController : UIViewController <
	UIVerticalStepperDelegate,
	UIScrollViewDelegate
>

    /** Delegate */
    @property (nonatomic, weak) id<BSDistributionViewControllerDelegate> delegate;

    /** # from HeadCount view to bound # of people on profiles */
	@property (nonatomic, assign) int headCount;

    /** Profile add button */
	@property (nonatomic, strong) UIButton *addButton;

	/** For dragging items */
	@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

    /** Reference to the buttons from dish setup */
	@property (nonatomic, strong) UIButton *drinkButton;
	@property (nonatomic, strong) UIButton *smallDishButton;
	@property (nonatomic, strong) UIButton *mediumDishButton;
	@property (nonatomic, strong) UIButton *largeDishButton;
    
    /** Instructional image */
    @property (nonatomic, strong) UIView *instructionCover;
    @property (nonatomic, strong) UIView *instructionCover2; 
    @property (nonatomic, strong) UIImageView *instructionIV;
    
    /** Warning label */
    @property (nonatomic, strong) UILabel *warningLabel;

    /** List of profiles user sets up */
	@property (nonatomic, strong) NSMutableArray *profiles;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;
    
@end
