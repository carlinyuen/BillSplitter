/**
	@file	DraggableImageView.m
	@author	Carlin
	@date	8/27/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "DraggableImageView.h"

@interface DraggableImageView ()
@end


#pragma mark - Implementation

@implementation DraggableImageView


#pragma mark - Class Functions

/** @brief Start dragging */
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    // Record touch point
    CGPoint pt = [[touches anyObject] locationInView:self];
    self.startingPoint = pt;
}

/** @brief Dragging */
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    // Move relative to the original touch point
    CGPoint pt = [[touches anyObject] locationInView:self];
    CGRect frame = self.frame;
    frame.origin.x += pt.x - self.startingPoint.x;
    frame.origin.y += pt.y - self.startingPoint.y;
	self.frame = frame;
}


#pragma mark - UI Setup



@end
