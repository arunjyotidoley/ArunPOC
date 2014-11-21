//
//  ImageDownloader.m
//  ArunPOC
//
//  Created by engineer on 20/11/14.
//  Copyright (c) 2014 Arun. All rights reserved.
//

#import "ImageDownloader.h"

@implementation ImageDownloader
@synthesize item=_item;
@synthesize itemIndexPath=_itemIndexPath;
@synthesize delegate;

// -------------------------------------------------------------------------------
//	initWithIndexPath
//  initialisation
// -------------------------------------------------------------------------------
- (id)initWithIndexPath:(NSIndexPath *)indexPath
{
    self = [super init];
    if (self != nil)
    {
        _itemIndexPath=[indexPath retain];
    }
    return self;
}


// -------------------------------------------------------------------------------
//	startDownload
//  image downloading
// -------------------------------------------------------------------------------
- (void)startDownload
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.item.imageURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
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
                UIImage *img=[[UIImage alloc] initWithData:data];
                _item.itemImage=img;
                [img release];
            }
            else{
                UIImage *img=[UIImage imageNamed:@"error.png"];
                _item.itemImage=img;
            }
            [self.delegate didFinishDownloadingImageAtIndexPath:self.itemIndexPath forItem:self.item];
        });
    });
}

- (void)dealloc
{
    [_item release];
    [_itemIndexPath release];
    [super dealloc];
}

@end
