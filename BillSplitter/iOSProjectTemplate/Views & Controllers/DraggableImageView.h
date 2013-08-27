/**
	@file	DraggableImageView.h
	@author	Carlin
	@date	8/27/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

@interface DraggableImageView : UIImageView

	/** Keep track of touch point at start of dragging */
	@property (nonatomic, assign) CGPoint startingPoint;

@end
