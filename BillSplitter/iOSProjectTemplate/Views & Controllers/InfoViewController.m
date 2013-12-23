/**
	@file	InfoViewController.m
	@author	Carlin
	@date	7/12/13
	@brief	iOSProjectTemplate
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "InfoViewController.h"

	#define UI_SIZE_TABLE_FOOTER_HEIGHT 64
    #define UI_SIZE_CORNER_RADIUS 12  

	#define FONT_SIZE_SECTION_HEADER 18
	
	#define COLOR_HEX_CELL_BACKGROUND 0x888888FF
	#define COLOR_HEX_CELL_SEPARATOR 0x555555FF

	#define TABLEVIEW_CELL_ID @"SettingsRow"
	#define TABLEVIEW_HEADER_ID @"SettingsSectionHeader"

	#define TABLEVIEW_DATA_KEY_LABEL @"label"
	#define TABLEVIEW_DATA_KEY_ROWS @"rows"
    #define TABLEVIEW_DATA_KEY_SWITCH @"switch"

@interface InfoViewController ()

	/** UI Elements */
	@property (nonatomic, strong) UIView *tableHeaderView;
	@property (nonatomic, strong) UITableView *tableView;
	@property (nonatomic, strong) UIView *tableFooterView;

	/** Settings views */
	@property (nonatomic, strong) NSArray *tableViewData;

@end


#pragma mark - Implementation

@implementation InfoViewController


#pragma mark - View Lifecycle

/** @brief Setup UI elements for viewing. */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"INFO_VIEW_TITLE", nil);
    
    bool isIOS7 = (getDeviceOSVersionNumber() >= 7);
	
	self.tableViewData = [[NSArray alloc] initWithObjects:
		@{
			TABLEVIEW_DATA_KEY_LABEL: @"Settings",
			TABLEVIEW_DATA_KEY_ROWS: @[
				@{
                    TABLEVIEW_DATA_KEY_LABEL: (isIOS7)
                        ? @"Round to Nearest Dollar"
                        : @"Round to Next Dollar",
                    TABLEVIEW_DATA_KEY_SWITCH: @(true),
                },
			],
		},
		@{
			TABLEVIEW_DATA_KEY_LABEL: @"Payments",
			TABLEVIEW_DATA_KEY_ROWS: @[
                @{
                    TABLEVIEW_DATA_KEY_LABEL: @"Venmo",
                    TABLEVIEW_DATA_KEY_SWITCH: @(false),
                }, 
                @{
                    TABLEVIEW_DATA_KEY_LABEL: @"Paypal",
                    TABLEVIEW_DATA_KEY_SWITCH: @(false),
                },
			],
		},
		nil];

	// Get device screen size
	CGRect bounds = getScreenFrame();
    if (isIOS7) {
        bounds.size.height += bounds.origin.y;
    }
	bounds.origin.x = bounds.origin.y = 0;
	
	[self setupNavBar];
	[self setupTableView:bounds];
	[self setupTableFooterView:bounds];
}

/** @brief Last-minute setup before view appears. */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    // iOS 7 fix for bouncing navigation bar after transition
    [self.navigationController.navigationBar.layer removeAllAnimations];
}

/** @brief Dispose of any resources that can be recreated. */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/** @brief Return supported orientations */
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - UI Setup

/** @brief Setup nav bar */
- (void)setupNavBar
{
    UINavigationBar *navBar = self.navigationController.navigationBar;
    bool isIOS7 = (getDeviceOSVersionNumber() >= 7); 

    // Rounded corners
    self.navigationController.view.layer.cornerRadius = UI_SIZE_CORNER_RADIUS;
   	self.navigationController.view.clipsToBounds = true;  
    
    if (!isIOS7 && getDeviceOSVersionNumber() > 5)
    {
        // Mask for rounded corners on top
        CGRect frame = navBar.frame;
        CAShapeLayer *mask = [CAShapeLayer new];
        CGPoint leftBottomCorner = CGPointMake(0, CGRectGetMaxY(frame));
        CGPoint rightBottomCorner = CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame)); 
        CGPoint leftTopArcCorner = CGPointMake(UI_SIZE_CORNER_RADIUS, UI_SIZE_CORNER_RADIUS);
        CGPoint rightTopArcCorner = CGPointMake(CGRectGetMaxX(frame) - UI_SIZE_CORNER_RADIUS, UI_SIZE_CORNER_RADIUS);
        
        // Drawing bounds
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, rightBottomCorner.x, rightBottomCorner.y);
        CGPathAddLineToPoint(path, NULL, leftBottomCorner.x, leftBottomCorner.y); 
        CGPathAddArc(path, NULL, leftTopArcCorner.x, leftTopArcCorner.y, UI_SIZE_CORNER_RADIUS, M_PI, M_PI / 2 * 3, NO);
        CGPathAddArc(path, NULL, rightTopArcCorner.x, rightTopArcCorner.y, UI_SIZE_CORNER_RADIUS, M_PI / 2 * 3, 0, NO); 
        CGPathCloseSubpath(path);
        
        // Set mask to cut off corners on top two
        mask.path = path;
        navBar.layer.mask = mask;
    }
    
    // Coloring navbar  
    if (isIOS7) {  
        [navBar setBarTintColor:UIColorFromHex(COLOR_HEX_NAVBAR_iOS7)];
        [navBar setTintColor:[UIColor whiteColor]];  
        [navBar setTitleTextAttributes:@{
            UITextAttributeTextColor: [UIColor whiteColor],
        }]; 
    } 
    else {  // Pre-iOS 7
        navBar.tintColor = UIColorFromHex(COLOR_HEX_ACCENT);  
    }

	// Close button
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
		initWithBarButtonSystemItem:UIBarButtonSystemItemDone
		target:self action:@selector(doneButtonPressed:)];
	self.navigationItem.leftBarButtonItem.tintColor = (isIOS7) 
        ? [UIColor whiteColor] : UIColorFromHex(COLOR_HEX_LIGHT_ACCENT);
}

/** @brief Setup tableview */
- (void)setupTableView:(CGRect)bounds
{
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
		style:UITableViewStyleGrouped];
	self.tableView.backgroundView = nil;
	self.tableView.backgroundColor = UIColorFromHex(COLOR_HEX_BACKGROUND_DARK_GRAY);
	self.tableView.separatorColor = UIColorFromHex(COLOR_HEX_CELL_SEPARATOR);
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	
    if (getDeviceOSVersionNumber() >= 6) {
        [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:TABLEVIEW_HEADER_ID];
    } else {
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor darkGrayColor]];
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setShadowColor:[UIColor clearColor]]; 
    }
	
	self.tableView.frame = bounds;
	[self.view addSubview:self.tableView];
}

/** @brief Setup tableFooterView */
- (void)setupTableFooterView:(CGRect)bounds
{
	self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
	
	self.tableFooterView.backgroundColor = self.tableView.backgroundColor;
	
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(
		0, 0, self.view.bounds.size.width, UI_SIZE_TABLE_FOOTER_HEIGHT)];
	button.backgroundColor = [UIColor clearColor];
	button.titleLabel.textAlignment = NSTextAlignmentCenter;
	button.titleLabel.font = [UIFont fontWithName:FONT_NAME_BRANDING
		size:FONT_SIZE_BRANDING];
	[button setTitle:NSLocalizedString(@"INFO_VIEW_BRANDING_TEXT", nil)
		forState:UIControlStateNormal];
	[button setTitleColor:UIColorFromHex(COLOR_HEX_COPY_LIGHT)
		forState:UIControlStateNormal];
	[button setTitleColor:UIColorFromHex(COLOR_HEX_COPY_DARK)
		forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(brandingPressed:)
		forControlEvents:UIControlEventTouchUpInside];
	
	[self.tableFooterView addSubview:button];
	
	self.tableFooterView.frame = CGRectMake(
		0, 0, self.view.bounds.size.width, UI_SIZE_TABLE_FOOTER_HEIGHT);
	self.tableView.tableFooterView = self.tableFooterView;
}


#pragma mark - Class Functions



#pragma mark - UI Event Handlers

/** @brief When branding is pressed */
- (void)brandingPressed:(UIButton*)sender
{
}

/** @brief When back button on navigation bar is pressed */
- (void)doneButtonPressed:(UIBarButtonItem *)sender
{
	if (self.delegate
		&& [self.delegate respondsToSelector:@selector(infoViewController:willCloseAnimated:)]) {
		[self.delegate infoViewController:self willCloseAnimated:true];
	}
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.tableViewData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[self.tableViewData objectAtIndex:section] objectForKey:TABLEVIEW_DATA_KEY_ROWS] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UI_SIZE_MIN_TOUCH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return UI_SIZE_MIN_TOUCH;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   	return [[self.tableViewData objectAtIndex:section]
		objectForKey:TABLEVIEW_DATA_KEY_LABEL]; 
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *view;
    
    if (getDeviceOSVersionNumber() < 6) {
        view = [UITableViewHeaderFooterView new];
    } else {
        view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:TABLEVIEW_HEADER_ID];
       	view.textLabel.textColor = [UIColor darkGrayColor];
        view.textLabel.shadowColor = [UIColor clearColor];  
    }
    
	view.textLabel.font = [UIFont fontWithName:FONT_NAME_HEADERS size:FONT_SIZE_SECTION_HEADER];
	
	return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_CELL_ID];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TABLEVIEW_CELL_ID];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
    
    // Get cell data to populate with
    NSDictionary *cellData = [[self.tableViewData[indexPath.section]
		objectForKey:TABLEVIEW_DATA_KEY_ROWS]
            objectAtIndex:indexPath.row];
	
	cell.backgroundColor = UIColorFromHex(COLOR_HEX_CELL_BACKGROUND);
	cell.textLabel.text = cellData[TABLEVIEW_DATA_KEY_LABEL];
        
    // Custom toggle for certain cells
    if ([cellData[TABLEVIEW_DATA_KEY_SWITCH] boolValue]) {
        cell.accessoryView = [UISwitch new];
    }
	
	return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Fade selection out
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}


@end
