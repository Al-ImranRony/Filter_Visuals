//
//  ViewController.h
//  FilterVisuals
//
//  Created by iRny on 9/16/21.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface ViewController : UIViewController

@property UIImage *sourceImage;

@property (strong, nonatomic) IBOutlet UIImageView *firstImageView;
@property (weak, nonatomic) IBOutlet UILabel *inputFilterName;
@property (strong, nonatomic) IBOutlet UIImageView *secondImageView;
@property (weak, nonatomic) IBOutlet UILabel *appliedFilterName;

@property (strong, nonatomic) IBOutlet UICollectionView *testImageCollectionView;

@property (strong, nonatomic) UIImage *hImage;


-(UIImage*)chooseFilter:(UIImage*) inputImage forNumber: (int) filterNumber;

@end

