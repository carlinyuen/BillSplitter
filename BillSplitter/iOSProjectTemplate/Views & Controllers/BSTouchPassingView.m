//
//  BSTouchPassingView.m
//  BillSplitter
//
//  Created by . Carlin on 12/23/13.
//  Copyright (c) 2013 Carlin. All rights reserved.
//

#import "BSTouchPassingView.h"

@implementation BSTouchPassingView

// If hitTest returns the container, then return targetView instead
- (UIView *) hitTest:(CGPoint) point withEvent:(UIEvent *)event 
{
	UIView* child = nil;
    if ((child = [super hitTest:point withEvent:event]) == self
        && self.targetView) {
    	return self.targetView;
	}
    return child;
}

@end
