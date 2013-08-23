/**
	@file	BSDistributionViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSDistributionViewController.h"

	#define TABLEVIEW_ROW_ID @"RowCell"

@interface BSDistributionViewController ()

	@property (nonatomic, assign) CGRect frame;

@end


#pragma mark - Implementation

@implementation BSDistributionViewController

/** @brief Initialize data-related properties */
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
	{
		_frame = frame;
		
		_tableView = [[UITableView alloc] init];
		_headerView = [[BSDistributionTableViewCell alloc] init];
		_imageViews = [[NSMutableArray alloc] init];
		_textFields = [[NSMutableArray alloc] init];
		_steppers = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - View Lifecycle

/** @brief Setup UI elements for viewing. */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.frame = self.frame;
	CGRect bounds = self.view.bounds;
	CGRect frame = CGRectZero;
	
	// Setup tableview
	self.tableView.frame = bounds;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	
	// Setup header view
	self.headerView.textLabel.text = @"Drag item here to add new diner";
	self.headerView.backgroundView = nil;
	self.headerView.backgroundColor = UIColorFromHex(COLOR_HEX_NAVBAR_BUTTON);
	
	self.tableView.tableHeaderView = self.headerView;
	self.tableView.tableFooterView = [[UIView alloc] init];
	[self.tableView registerClass:[BSDistributionTableViewCell class]
		forCellReuseIdentifier:TABLEVIEW_ROW_ID];
	[self.view addSubview:self.tableView];
	
	self.view.backgroundColor = UIColorFromHex(COLOR_HEX_ACCENT);
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


#pragma mark - Class Functions

/** @brief Returns one of the steppers used */
- (RPVerticalStepper *)stepperForTextField:(UITextField *)textField
{
	int index = [self.textFields indexOfObject:textField];
	return (self.steppers.count && index != NSNotFound)
		? [self.steppers objectAtIndex:index] : nil;
}


#pragma mark - UI Setup


#pragma mark - UI Events


#pragma mark - Utility Functions


#pragma mark - Delegates
#pragma mark - UITableViewDataSource

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.textFields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BSDistributionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_ROW_ID];
	
	cell.textLabel.text = @"Hello";
	
	return cell;
}


#pragma mark - UITableViewDelegate

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [BSDistributionTableViewCell cellHeight];
}


@end
