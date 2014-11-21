//
//  MyCustomCell.h
//  ArunPOC
//
//  Created by engineer on 19/11/14.
//  Copyright (c) 2014 Arun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCustomCell : UITableViewCell
@property(nonatomic,retain) UILabel *titleLabel;
@property(nonatomic,retain) UILabel *descriptionLabel;
@property(nonatomic,retain) UIImageView *cellImage;
@property (nonatomic,retain) UIActivityIndicatorView * activityIndicator;

+(CGFloat)sizeForCell:(NSString*)title andDescription:(NSString *)description andMaxWidth:(CGFloat)maxWidth isImageAvailable:(BOOL)imageAvailable;
-(void)formatCell;

@end
