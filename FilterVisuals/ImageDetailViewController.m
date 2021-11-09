//
//  ImageDetailViewController.m
//  FilterVisuals
//
//  Created by Bitmorpher 4 on 10/11/21.
//

#import "ImageDetailViewController.h"
#import "ViewController.h"

@interface ImageDetailViewController ()

@end

@implementation ImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.imageDetailLabel.text = self.selectedImageName;
    self.detailImageView.image = [UIImage imageNamed:self.selectedImageName];
}


- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
