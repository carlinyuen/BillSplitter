//
//  BSScrollView.h
//  BillSplitter
//
//  Created by . Carlin on 12/21/13.
//  Copyright (c) 2013 Carlin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSScrollView;
@protocol BSScrollViewDelegate <NSObject>

    @optional
    /** Only gets called if you set delaysContentTouches to NO */
    - (bool)scrollView:(BSScrollView *)scrollView shouldDelayTouchesForView:(UIView *)view;

@end

@interface BSScrollView : UIScrollView
    
    @property (nonatomic, weak) id<BSScrollViewDelegate> bsDelegate;
    
@end
