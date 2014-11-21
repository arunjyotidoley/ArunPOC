//
//  ViewController.h
//  ArunPOC
//
//  Created by engineer on 19/11/14.
//  Copyright (c) 2014 Arun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDownloader.h"

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ImageDownloaderDelegate>
@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,retain) NSDictionary *dataDictionary;
@property(nonatomic,retain) NSArray *dataArray;
@property(nonatomic,retain) NSMutableDictionary *imageDictionary;
@property (nonatomic,retain) UIActivityIndicatorView * activityIndicator;

@end
