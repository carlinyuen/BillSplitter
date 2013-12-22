//
//  BSScrollView.m
//  BillSplitter
//
//  Created by . Carlin on 12/21/13.
//  Copyright (c) 2013 Carlin. All rights reserved.
//

#import "BSScrollView.h"

@implementation BSScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    // Delegate touches should cancel
    if (self.bsDelegate && [self.bsDelegate respondsToSelector:@selector(scrollView:shouldDelayTouchesForView:)]) {
        return [self.bsDelegate scrollView:self shouldDelayTouchesForView:view];
    }
    
    return [super touchesShouldCancelInContentView:view];
}

@end
