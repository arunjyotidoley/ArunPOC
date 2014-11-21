//
//  MyCustomCell.m
//  andDescription
//
//  Created by engineer on 19/11/14.
//  Copyright (c) 2014 Arun. All rights reserved.
//

#import "MyCustomCell.h"
#define kCellHeaderPadding  5.0
#define kCellFooterPadding  5.0
#define kTitleSize 22.0
#define kDescriptionSize 18.0

#define CELL_TITLE [UIColor colorWithRed:15.0f/255.0f green:29.0f/255.0f blue:90.0f/255.0f alpha:1.0f]
#define CELL_DESCRIPTION [UIColor colorWithRed:49.0f/255.0f green:49.0f/255.0f blue:49.0f/255.0f alpha:1.0f]
#define CELL_GRADIENT_1 [UIColor colorWithRed:250.0f/255.0f green:250.0f/255.0f blue:250.0f/255.0f alpha:1.0f]
#define CELL_GRADIENT_2 [UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1.0f]
@implementation MyCustomCell
@synthesize titleLabel=_titleLabel;
@synthesize descriptionLabel=_descriptionLabel;
@synthesize cellImage=_cellImage;
@synthesize activityIndicator=_activityIndicator;


#pragma mark -Life Cycle Methods
// -------------------------------------------------------------------------------
//	initWithStyle:reuseIdentifier
// -------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(8.0f, 5.0f, self.frame.size.width-16, 30.0f)];
        _titleLabel.textColor=CELL_TITLE;
        _titleLabel.backgroundColor=[UIColor clearColor];
        _titleLabel.font=[UIFont boldSystemFontOfSize:kTitleSize];
        _titleLabel.numberOfLines=0;
        _titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
        _titleLabel.autoresizingMask=(UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin);
        [self.contentView addSubview:_titleLabel];
        
        _descriptionLabel=[[UILabel alloc] initWithFrame:CGRectMake(8.0f, 35.0f, self.frame.size.width*0.6, 50.0f)];
        _descriptionLabel.textColor=CELL_DESCRIPTION;
        _descriptionLabel.backgroundColor=[UIColor clearColor];
        _descriptionLabel.font=[UIFont systemFontOfSize:kDescriptionSize];
        _descriptionLabel.numberOfLines=0;
        _descriptionLabel.lineBreakMode=NSLineBreakByWordWrapping;
        _descriptionLabel.autoresizingMask=(UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin);
        [self.contentView addSubview:_descriptionLabel];
        
        _cellImage=[[UIImageView alloc] initWithFrame:CGRectMake(_descriptionLabel.frame.origin.x+_descriptionLabel.frame.size.width, 35.0f, (self.frame.size.width*0.4)-20.0, self.frame.size.width*0.4)];
        _cellImage.contentMode = UIViewContentModeScaleAspectFit;
        _cellImage.autoresizingMask=(UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin);
        [self.contentView addSubview:_cellImage];
        
       /* CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
        _activityIndicator = [[UIActivityIndicatorView alloc]
                                  initWithFrame:frame];
        _activityIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
        _activityIndicator.center=_cellImage.center;
        [self addSubview:_activityIndicator];*/
        
        CAGradientLayer *cellGrad = [CAGradientLayer layer];
        cellGrad.frame = self.contentView.bounds;
        cellGrad.colors = [NSArray arrayWithObjects:(id)[CELL_GRADIENT_1 CGColor], (id)[CELL_GRADIENT_2 CGColor], nil];
        [self.contentView.layer insertSublayer:cellGrad atIndex:0];
        
        
    }
    return self;
}

// -------------------------------------------------------------------------------
//	awakeFromNib
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{
    // Initialization code
}


#pragma mark -Cell modifier Methods
// -------------------------------------------------------------------------------
//	formatCell
//  Used to re-adjust the cell content dimensions
// -------------------------------------------------------------------------------
-(void)formatCell{
    
    //re-adjust title label based on text length and size
    CGSize maximumSize = CGSizeMake(self.frame.size.width, 9999);
    UIFont *labelFont = [UIFont boldSystemFontOfSize:kTitleSize];
    CGSize strRect;
    strRect = [self.titleLabel.text sizeWithFont:labelFont constrainedToSize:maximumSize lineBreakMode:NSLineBreakByWordWrapping];
    CGRect oldFrame = self.titleLabel.frame;
    CGRect newFrame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, strRect.height);
    self.titleLabel.frame = newFrame;
    
    //re-adjust Description label based on text length and size
    maximumSize = CGSizeMake(self.frame.size.width*0.6, 9999);
    labelFont = [UIFont systemFontOfSize:kDescriptionSize];
    strRect = [self.descriptionLabel.text sizeWithFont:labelFont constrainedToSize:maximumSize lineBreakMode:NSLineBreakByWordWrapping];
    oldFrame = self.descriptionLabel.frame;
    CGFloat newY=self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height;
    newFrame = CGRectMake(oldFrame.origin.x, newY, oldFrame.size.width, strRect.height);
    self.descriptionLabel.frame = newFrame;
    
    //re-adjust image y offset
    oldFrame=self.cellImage.frame;
    oldFrame.origin.y=newY;
    self.cellImage.frame=oldFrame;
    
    //re-adjust gradient size
    CALayer* gradientLayer = [self.contentView.layer.sublayers objectAtIndex:0];
    CGRect oldGradFrame=gradientLayer.frame;
    oldGradFrame.size.height=[MyCustomCell sizeForCell:self.titleLabel.text andDescription:self.descriptionLabel.text andMaxWidth:self.contentView.frame.size.width isImageAvailable:YES];
    oldGradFrame.size.width=self.contentView.frame.size.width;
    gradientLayer.frame = oldGradFrame;
}


// -------------------------------------------------------------------------------
//	sizeForCell:andDescription:andMaxWidth:
//  Used to re-adjust the cell height. 
// -------------------------------------------------------------------------------
+(CGFloat)sizeForCell:(NSString*)title andDescription:(NSString *)description andMaxWidth:(CGFloat)maxWidth isImageAvailable:(BOOL)imageAvailable{
    
    CGSize maximumSize = CGSizeMake(maxWidth, 9999);
    
    UIFont *labelFont = [UIFont boldSystemFontOfSize:kTitleSize];
    CGSize titleRect=CGSizeMake(0.0, 0.0);
    if (title) {
        titleRect = [title sizeWithFont:labelFont constrainedToSize:maximumSize lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    CGSize descriptionRect=CGSizeMake(0.0, 0.0);;
    labelFont = [UIFont systemFontOfSize:kDescriptionSize];
    maximumSize = CGSizeMake(maxWidth*0.6, 9999);
    if (description) {
        descriptionRect = [description sizeWithFont:labelFont constrainedToSize:maximumSize lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    CGFloat height=kCellHeaderPadding + titleRect.height+ descriptionRect.height+ kCellFooterPadding;
    CGFloat defaultHeight=(maxWidth*0.4)+30+kCellHeaderPadding+kCellFooterPadding;
    if (height<defaultHeight && imageAvailable) {
        return defaultHeight;
    }
    else{
        return height;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    [_titleLabel release];
    [_descriptionLabel release];
    [_cellImage release];
   // [_activityIndicator release];
    [super dealloc];
}

@end
