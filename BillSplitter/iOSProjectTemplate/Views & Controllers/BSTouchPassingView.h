//
//  BSTouchPassingView.h
//  BillSplitter
//
//  Created by . Carlin on 12/23/13.
//  Copyright (c) 2013 Carlin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSTouchPassingView : UIView

    /** View to pass touches to when hit */
	@property (nonatomic, strong) UIView *targetView;
    
@end
