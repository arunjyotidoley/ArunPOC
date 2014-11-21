//
//  ViewController.m
//  ArunPOC
//
//  Created by engineer on 19/11/14.
//  Copyright (c) 2014 Arun. All rights reserved.
//

#import "ViewController.h"
#import "MyCustomCell.h"
#import "Item.h"
#import <QuartzCore/QuartzCore.h>

#define kTitle @"title"
#define kRows @"rows"
#define kDescription @"description"
#define kImageUrl @"imageHref"
#define kDataUrl @"https://dl.dropboxusercontent.com/u/746330/facts.json"

@interface ViewController ()
@property (nonatomic, retain) NSMutableDictionary *imagesDownloading;

@end

@implementation ViewController
@synthesize tableView=_tableView;
@synthesize dataDictionary=_dataDictionary;
@synthesize dataArray=_dataArray;
@synthesize activityIndicator=_activityIndicator;
@synthesize imageDictionary;
@synthesize imagesDownloading=_imagesDownloading;

#pragma mark -Life Cycle Methods
// -------------------------------------------------------------------------------
//	viewDidLoad
//  This is the selector for Refresh Bar button.
// -------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(didTapRefresh)];
    
    _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    _tableView.autoresizingMask =UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_tableView];
    
    _imagesDownloading = [[NSMutableDictionary alloc] init];
    
    CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
    _activityIndicator = [[UIActivityIndicatorView alloc]
                          initWithFrame:frame];
    _activityIndicator.center=self.view.center;
    _activityIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    _activityIndicator.autoresizingMask =
    (UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleTopMargin |
     UIViewAutoresizingFlexibleBottomMargin);
    [self.view addSubview:_activityIndicator];
    [self.activityIndicator sizeToFit];
    [self downloadData];
    
}

// -------------------------------------------------------------------------------
//	dealloc
//  If this view controller is going away, we need to deallocate all instance objects.
// -------------------------------------------------------------------------------
- (void)dealloc
{
    [_tableView release];
    [_activityIndicator release];
    [self.imagesDownloading removeAllObjects];
    [_imagesDownloading release];
    [_dataDictionary release];
    [_dataArray release];
    [super dealloc];
}

#pragma mark -UIAlertView code
// -------------------------------------------------------------------------------
//	showAlertWithTitle
//  This is to show and alert in case of any error.
// -------------------------------------------------------------------------------
-(void)showAlertWithTitle:(NSString *)title andDescription:(NSString *)description{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

#pragma mark -UIButton selector
// -------------------------------------------------------------------------------
//	didTapRefresh
//  This is the selector for Refresh Bar button.
// -------------------------------------------------------------------------------
-(void)didTapRefresh{
    //self.dataArray=nil;
    //[_tableView reloadData];
    [self downloadData];
}

#pragma mark -Data download
// -------------------------------------------------------------------------------
//	downloadData
//  This method is used to download the JSON feed.
// -------------------------------------------------------------------------------
-(void)downloadData{
    [self.activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kDataUrl]];
        NSURLResponse *response;
        NSError *error=nil;
        NSData *data;
        @try {
            data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        }
        @catch (NSException *exception) {
            return;
        }
        @finally {
        }
        if (error) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSString *str=[[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
                NSError *err;
                _dataDictionary = [[NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err] retain];
                [str release];
                NSMutableArray *array =[[NSMutableArray alloc] init];
                if (([self.dataDictionary objectForKey:kRows])) {
                    for (NSDictionary *dict in [self.dataDictionary objectForKey:kRows]) {
                        Item *item=[[Item alloc] init];
                        item.titleText=([dict objectForKey:kTitle] && ![[dict objectForKey:kTitle] isEqual:[NSNull null]])?[dict objectForKey:kTitle]:@"";
                        item.descriptionText=([dict objectForKey:kDescription] && ![[dict objectForKey:kDescription] isEqual:[NSNull null]])?[dict objectForKey:kDescription]:@"";
                        item.imageURL=([dict objectForKey:kImageUrl] && ![[dict objectForKey:kImageUrl] isEqual:[NSNull null]])?[dict objectForKey:kImageUrl]:@"";
                        if (item.titleText.length==0 && item.descriptionText.length==0 && item.imageURL.length==0) {
                        }else{
                            [array addObject:item];
                        }
                        [item release];
                    }
                    
                }
                _dataArray=[array retain];
                [array release];
                self.navigationItem.title=[self.dataDictionary objectForKey:kTitle];
                [self.activityIndicator stopAnimating];
                [_tableView reloadData];
            }
            /*else if (error) {
                [self showAlertWithTitle:@"Error!" andDescription:error.localizedDescription];
            }*/
            else{
                [self showAlertWithTitle:@"Error!" andDescription:@"failed to download data"];
                
            }
            
        });
    });
}

// -------------------------------------------------------------------------------
//	downloadImagesForIndexPath
//  This method is used to download the images.
// -------------------------------------------------------------------------------
-(void)downloadImagesForIndexPath:(NSIndexPath *)indexPath{
    ImageDownloader *imageDownloader=[self.imagesDownloading objectForKey:indexPath];
    Item *item=[self.dataArray objectAtIndex:indexPath.row];
    if (imageDownloader == nil)
    {
        imageDownloader = [[ImageDownloader alloc] initWithIndexPath:indexPath];
        imageDownloader.item=[item retain];
        [item release];
        imageDownloader.delegate=self;
        [self.imagesDownloading setObject:imageDownloader forKey:indexPath];
        [imageDownloader startDownload];
        [imageDownloader release];
    }
}

#pragma mark -ImageDownloaderDelegate
// -------------------------------------------------------------------------------
//	didFinishDownloadingImageAtIndexPath
//  This method is used to download the images.
// -------------------------------------------------------------------------------
-(void)didFinishDownloadingImageAtIndexPath:(NSIndexPath *)indexPath forItem:(Item *)item{
    MyCustomCell *cell = (MyCustomCell*)[_tableView cellForRowAtIndexPath:indexPath];
    cell.cellImage.image = item.itemImage;
    [self.imagesDownloading removeObjectForKey:indexPath];
}

#pragma mark -UITableViewDataSource & UITableViewDelegate
// -------------------------------------------------------------------------------
//	tableView:numberOfRowsInSection:
//  Customize the number of rows in the table view.
// -------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

// -------------------------------------------------------------------------------
//	tableView:cellForRowAtIndexPath:
// -------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *kCellId = @"kCellId";
    MyCustomCell *cell = (MyCustomCell *)[tableView dequeueReusableCellWithIdentifier:kCellId];
    if(cell == nil)
    {
        cell=[[[MyCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellId] autorelease];
        cell.contentView.autoresizingMask =UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
    }
    Item *item =[self.dataArray objectAtIndex:indexPath.row];
    cell.titleLabel.text=item.titleText;
    cell.descriptionLabel.text=item.descriptionText;
    
    if (!item.itemImage)
    {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self downloadImagesForIndexPath:indexPath];
        }
        // a temporary placeholder image
        cell.cellImage.image = [UIImage imageNamed:@"error.png"];
    }
    else
    {
        cell.cellImage.image = item.itemImage;
    }
    [cell formatCell];
    return cell;
    
}

// -------------------------------------------------------------------------------
//	tableView:heightForRowAtIndexPath:
// -------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Item *item=[self.dataArray objectAtIndex:indexPath.row];
    if (item.titleText.length==0 && item.descriptionText.length==0 && item.imageURL.length==0) {
        return 0.0f;
    }
    else{
        return [MyCustomCell sizeForCell:item.titleText andDescription:item.descriptionText andMaxWidth:self.view.frame.size.width isImageAvailable:YES];
    }
}

// -------------------------------------------------------------------------------
//	tableView:heightForHeaderInSection:
// -------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1.0;
}

// -------------------------------------------------------------------------------
//	tableView:heightForFooterInSection:
// -------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.0;
}


// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have images yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if (self.dataArray.count > 0)
    {
        NSArray *visiblePaths = [_tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            Item *item = [self.dataArray objectAtIndex:indexPath.row];
            if (!item.itemImage)
            {
                [self downloadImagesForIndexPath:indexPath];
            }
        }
    }
}


#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the images that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
    
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
