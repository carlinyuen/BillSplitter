/**
	@file	BSDistributionTableViewCell.m
	@author	Carlin
	@date	8/23/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSDistributionTableViewCell.h"

	#define UI_SIZE_MIN_CELL_HEIGHT 64

	#define IMG_DINER @"man.png"

@implementation BSDistributionTableViewCell

/** @brief Initialize data-related properties */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
	{
		// Button for drag-drop
		UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(
			0, 0, UI_SIZE_MIN_CELL_HEIGHT, UI_SIZE_MIN_CELL_HEIGHT
		)];
		[button setImage:[UIImage imageNamed:IMG_DINER] forState:UIControlStateNormal];
    }
    return self;
}


#pragma mark - Class Functions

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

/** @brief Returns default cell height */
+ (float)cellHeight
{
	return UI_SIZE_MIN_CELL_HEIGHT;
}

@end
