//
//  ImageDetailViewController.h
//  FilterVisuals
//
//  Created by iRny on 10/11/21.
//

#import <UIKit/UIKit.h>
#import "RMPZoomTransitionAnimator.h"


NS_ASSUME_NONNULL_BEGIN

@interface ImageDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *imageDetailLabel;

@property (strong, nonatomic) IBOutlet UIImageView *detailImageView;

@property (strong, nonatomic) NSString *selectedImageName;


@end

NS_ASSUME_NONNULL_END
