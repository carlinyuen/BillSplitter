/**
	@file	InfoViewController.m
	@author	Carlin
	@date	7/12/13
	@brief	iOSProjectTemplate
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "InfoViewController.h"

	#define UI_SIZE_TABLE_HEADER_HEIGHT 64
	#define UI_SIZE_TABLE_FOOTER_HEIGHT 54

	#define COLOR_HEX_CELL_BACKGROUND 0x888888FF
	#define COLOR_HEX_CELL_SEPARATOR 0x555555FF

@interface InfoViewController ()

	/** UI Elements */
	@property (nonatomic, strong) UINavigationBar *navBar;
	@property (nonatomic, strong) UIView *tableHeaderView;
	@property (nonatomic, strong) UITableView *tableView;
	@property (nonatomic, strong) UIView *tableFooterView;

@end


#pragma mark - Implementation

@implementation InfoViewController

/** @brief Initialize data-related properties */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


#pragma mark - View Lifecycle

/** @brief Setup UI elements for viewing. */
- (void)viewDidLoad
{
    [super viewDidLoad];

	// Get device screen size
	CGRect bounds = getScreenFrame();
	bounds.origin.x = bounds.origin.y = 0;
	
	[self setupNavBar];
	[self setupTableView:bounds];
	[self setupTableHeaderView:bounds];
	[self setupTableFooterView:bounds];
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
}

/** @brief Return supported orientations */
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - UI Setup

/** @brief Setup nav bar */
- (void)setupNavBar
{
	self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(
		0, 0, self.view.frame.size.width, UI_SIZE_MIN_TOUCH
	)];
	self.navBar.tintColor = UIColorFromHex(COLOR_HEX_ACCENT);
	
	// Title
	UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:
		NSLocalizedString(@"INFO_VIEW_TITLE", nil)];
		
	// Back button
	item.leftBarButtonItem = [[UIBarButtonItem alloc]
		initWithBarButtonSystemItem:UIBarButtonSystemItemDone
		target:self action:@selector(backButtonPressed:)];
	item.leftBarButtonItem.tintColor = UIColorFromHex(COLOR_HEX_NAVBAR_BUTTON);
	
	[self.navBar pushNavigationItem:item animated:true];
	[self.view addSubview:self.navBar];
}

/** @brief Setup tableview */
- (void)setupTableView:(CGRect)bounds
{
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
		style:UITableViewStyleGrouped];
	self.tableView.backgroundView = nil;
	self.tableView.backgroundColor = UIColorFromHex(COLOR_HEX_BACKGROUND_DARK);
	self.tableView.separatorColor = UIColorFromHex(COLOR_HEX_CELL_SEPARATOR);
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	
	CGRect frame = bounds;
	frame.origin.y = UI_SIZE_MIN_TOUCH;
	self.tableView.frame = frame;
	[self.view addSubview:self.tableView];
}

/** @brief Setup tableHeaderView */
- (void)setupTableHeaderView:(CGRect)bounds
{
	self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];

	self.tableHeaderView.frame = CGRectMake(
		0, 0, self.view.bounds.size.width, UI_SIZE_TABLE_HEADER_HEIGHT);
	self.tableView.tableHeaderView = self.tableHeaderView;
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
- (void)backButtonPressed:(UIBarButtonItem *)sender
{
	if (self.delegate
		&& [self.delegate respondsToSelector:@selector(infoViewController:willCloseAnimated:)]) {
		[self.delegate infoViewController:self willCloseAnimated:true];
	}
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return section + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailedTableViewCell"];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"DetailedTableViewCell"];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	
	cell.backgroundColor = UIColorFromHex(COLOR_HEX_CELL_BACKGROUND);
	
	return cell;
}



@end
