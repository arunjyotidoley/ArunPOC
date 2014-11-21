//
//  ImageDownloader.h
//  ArunPOC
//
//  Created by engineer on 20/11/14.
//  Copyright (c) 2014 Arun. All rights reserved.
//

#import "Item.h"
@protocol ImageDownloaderDelegate;
@interface ImageDownloader : NSObject
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) NSIndexPath *itemIndexPath;

@property(nonatomic,assign) id<ImageDownloaderDelegate> delegate;

- (id)initWithIndexPath:(NSIndexPath *)indexPath;
- (void)startDownload;

@end

@protocol ImageDownloaderDelegate <NSObject>

-(void)didFinishDownloadingImageAtIndexPath:(NSIndexPath *)indexPath forItem:(Item *)item;

@end