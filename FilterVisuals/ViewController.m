//
//  ViewController.m
//  FilterVisuals
//
//  Created by Bitmorpher 4 on 9/16/21.
//

#import "ViewController.h"
#import "HolderCollectionViewCell.h"
#import "FilterVisuals-Bridging-Header.h"
#import <FilterVisuals-Swift.h>

#include <GPUImage/GPUImageFilter.h>
#include <GPUImage/GPUImagePicture.h>
#include <GPUImage/GPUImageLookupFilter.h>
#include <GPUImage/GPUImageToneCurveFilter.h>
#import <GPUImage/GPUImageAlphaBlendFilter.h>
#import <GPUImage/GPUImagePoissonBlendFilter.h>
#import <GPUImage/GPUImageSourceOverBlendFilter.h>
#import <GPUImage/GPUImageTwoInputCrossTextureSamplingFilter.h>

#import "ImageDetailViewController.h"
#import "RMPZoomTransitionAnimator/RMPZoomTransitionAnimator.h"


@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) NSArray *sampleImages;

@end

@implementation ViewController

NSString *ImagesCollectionCellID = @"ImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.sampleImages = @[@"Photo1", @"test", @"test1", @"test2", @"test3", @"test4", @"test5", @"test6", @"test7", @"test8", @"test9", @"test10"];
    
    [self.testImageCollectionView reloadData];
    
    self.sourceImage = [UIImage imageNamed:@"Photo1"];
    self.firstImageView.image = self.sourceImage;
    self.secondImageView.image = self.sourceImage;
    
    self.testImageCollectionView.delegate = self;
    self.testImageCollectionView.dataSource = self;
    
    UINib *cellNib = [UINib nibWithNibName:@"HolderCollectionViewCell" bundle:nil];
    [self.testImageCollectionView registerNib:cellNib forCellWithReuseIdentifier:ImagesCollectionCellID];
    
//    UIView *filterDetailView = [[FilterDetail alloc] initWithFrame:CGRectMake(20, 140, 380, 190)];
//    filterDetailView.backgroundColor=[UIColor lightGrayColor];
//    [self.view addSubview: filterDetailView];
}


//-(UIImage *)getFilterImage:(UIImage *)selectedImage{
//    return selectedImage;
//}

- (UIImage *)chooseFilter:(UIImage *)inputImage forNumber:(int)filterNumber{
    UIImage *outputImage;
    
    switch (filterNumber) {
        case 0:
            outputImage = [self applyGPULookupFilter:inputImage];
            break;
        case 1:
            outputImage = [self applyCIColorCubeFilter: inputImage];
            break;
        case 2:
            outputImage = [self poissonBlendFilter:inputImage overlayImageName:@"PurpleTexture"];
            break;
        case 3:
            outputImage = [self glassDistortionFilter:inputImage overlayImageName:@"texture1"];
            break;
        case 4:
            outputImage = [self displacementDistortionFilter:inputImage overlayImageName:@"texture1"];
            break;
        case 5:
            outputImage = [self applyToneCurve2Filter:inputImage];
            break;
        default:
            outputImage = [self applyCIZoomBlurFilter:inputImage];
            break;
    }
    
    return outputImage;
}


//Collection view data source

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sampleImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    HolderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ImagesCollectionCellID forIndexPath:indexPath];
    
    UIImage *holderImage = [UIImage imageNamed:self.sampleImages[indexPath.item]];
    cell.holderImageView.image = holderImage;
    self.hImage = holderImage;
    
    return cell;
}


// Collection view delgate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UIImage *holderImage = [UIImage imageNamed:self.sampleImages[indexPath.item]];
    self.sourceImage = holderImage;

    self.firstImageView.image = [self chooseFilter: self.sourceImage forNumber: 2];
//    self.inputFilterName.text = self.sampleImages[indexPath.item];
    self.secondImageView.image = [self chooseFilter: self.sourceImage forNumber: 5];
    [self RGBToneCurveFilter:self.sourceImage];
//    self.appliedFilterName.text = self.sampleImages[indexPath.item];
    
    NSString *currentImageName = [self.sampleImages objectAtIndex:indexPath.row];
    NSLog(@"selected=%@", currentImageName);
    
//    ImageDetailViewController *detailVC = [[ImageDetailViewController alloc] init];
//    detailVC.selectedImageName = currentImageName;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(100.0, 100.0);
}


- (void)RGBToneCurveFilter:(UIImage *)inputImage{
    UIViewController *detailsVC = [[CurveDetailsInterface new] makeHostingVCWithSourceImage:inputImage];
    [self presentModalViewController:detailsVC animated:YES];
}

- (UIImage *)applyToneCurve2Filter:(UIImage *)inputImage{
    
    GPUImageToneCurveFilter *toneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Curve2"];
    UIImage* blurredImage = [toneCurveFilter imageByFilteringImage:inputImage];
    
    return blurredImage;
}

- (UIImage *)alphaBlendFilter:(UIImage *)inputImage overlayImageName:(NSString *)imageName {
    UIImage *initialImage = inputImage;
    GPUImagePicture *inputPicture = [[GPUImagePicture alloc] initWithImage:initialImage];
    UIImage *overlayImage = [UIImage imageNamed:imageName];
    
    GPUImagePicture *overlayPicture = [[GPUImagePicture alloc] initWithImage:overlayImage];
    
    GPUImageAlphaBlendFilter *overlayBlendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    overlayBlendFilter.mix = 0.9;
    [overlayBlendFilter useNextFrameForImageCapture];
    
    [inputPicture addTarget:overlayBlendFilter];
    [inputPicture processImage];
    [overlayPicture addTarget:overlayBlendFilter];
    [overlayPicture processImage];
    
    UIImage *processedImage = [overlayBlendFilter imageFromCurrentFramebuffer];
    return processedImage;
}


- (UIImage *)poissonBlendFilter:(UIImage *)inputImage overlayImageName:(NSString *)imageName {
    UIImage *initialImage = inputImage;
    
    GPUImagePicture *inputPicture = [[GPUImagePicture alloc] initWithImage:initialImage];
    UIImage *overlayImage = [UIImage imageNamed:imageName];
    
    GPUImagePicture *overlayPicture = [[GPUImagePicture alloc] initWithImage:overlayImage];
    
    GPUImagePoissonBlendFilter *overlayBlendFilter = [[GPUImagePoissonBlendFilter alloc] init];
    overlayBlendFilter.mix = 1.0;
//    overlayBlendFilter.numIterations = 10;
    [overlayBlendFilter useNextFrameForImageCapture];
    
    [inputPicture addTarget:overlayBlendFilter];
    [inputPicture processImage];
    [overlayPicture addTarget:overlayBlendFilter];
    [overlayPicture processImage];
    
    UIImage *processedImage = [overlayBlendFilter imageFromCurrentFramebuffer];
    
//    processedImage = [self applyGPULookupFilter:processedImage];
    
    return processedImage;
}

-(UIImage *) glassDistortionFilter:(UIImage *) inputImage overlayImageName:(NSString *)imageName {
    
    CIImage* image = [CIImage imageWithCGImage:inputImage.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGlassDistortion"];
    
    UIImage *mImage = [UIImage imageNamed: imageName];

    CIImage* maskImage = [CIImage imageWithCGImage:mImage.CGImage];
    
    [filter setValue:maskImage forKey:@"inputTexture"];
    [filter setValue:[NSNumber numberWithFloat:100.0] forKey:@"inputScale"];
//    [filter setValue:[CIVector vectorWithX:200 Y:200] forKey:@"inputCenter"];
    [filter setValue:image forKey:kCIInputImageKey];

    
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newPhoto = [UIImage imageWithCGImage:cgimg];
    
//    newPhoto = [self applyGPULookupFilter:newPhoto];

    CGImageRelease(cgimg);
    context = nil;
    return newPhoto;
}

-(UIImage *) displacementDistortionFilter:(UIImage *) inputImage overlayImageName:(NSString *)imageName {
    
    CIImage* image = [CIImage imageWithCGImage:inputImage.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIDisplacementDistortion"];
    
    UIImage *mImage = [UIImage imageNamed: imageName];

    CIImage* maskImage = [CIImage imageWithCGImage:mImage.CGImage];
    
    [filter setValue:maskImage forKey:@"inputDisplacementImage"];
    [filter setValue:[NSNumber numberWithFloat:100.0] forKey:@"inputScale"];
    [filter setValue:image forKey:kCIInputImageKey];

    
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newPhoto = [UIImage imageWithCGImage:cgimg];
    
    newPhoto = [self applyGPULookupFilter:newPhoto];

    CGImageRelease(cgimg);
    context = nil;
    return newPhoto;
}

-(UIImage *) drosteFilter:(UIImage *) inputImage{
    
    CIImage* image = [CIImage imageWithCGImage:inputImage.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIDroste"];

    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:@10 forKey:@"inputRotation"];
    [filter setValue:@10 forKey:@"inputPeriodicity"];
    [filter setValue:@5 forKey:@"inputStrands"];
//    [filter setValue:[CIVector vectorWithX:200 Y:200] forKey:@"inputCenter"];
    
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newPhoto = [UIImage imageWithCGImage:cgimg];
    
//    newPhoto = [self applyGPULookupFilter:newPhoto];

    CGImageRelease(cgimg);
    context = nil;
    return newPhoto;
}

- (UIImage *)sourceOverBlendFilter:(UIImage *)inputImage overlayImageName:(NSString *)imageName {
    UIImage *initialImage = inputImage;
    GPUImagePicture *inputPicture = [[GPUImagePicture alloc] initWithImage:initialImage];
    UIImage *overlayImage = [UIImage imageNamed:imageName];
    
    GPUImagePicture *overlayPicture = [[GPUImagePicture alloc] initWithImage:overlayImage];
    
    GPUImageSourceOverBlendFilter *overlayBlendFilter = [[GPUImageSourceOverBlendFilter alloc] init];
    [overlayBlendFilter useNextFrameForImageCapture];
    
    [inputPicture addTarget:overlayBlendFilter];
    [inputPicture processImage];
    [overlayPicture addTarget:overlayBlendFilter];
    [overlayPicture processImage];
    
    UIImage *processedImage = [overlayBlendFilter imageFromCurrentFramebuffer];
    return processedImage;
}


- (UIImage *)applyCIZoomBlurFilter:(UIImage *)inputImage{
    CIImage* image = [CIImage imageWithCGImage:inputImage.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIZoomBlur"];
    [filter setValue:image forKey:@"inputImage"];
    CIVector *vector = [[CIVector alloc] initWithX:150.0 Y:160.0];
    [filter setValue:vector forKey:@"inputCenter"];
    [filter setValue:@25 forKey:@"inputAmount"];
    
    CIImage* outputImage = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    context = nil;
    
    return newImage;
}

-(UIImage *)applyCIColorCubeFilter:(UIImage *)inputImage{
    CIImage* image = [CIImage imageWithCGImage:inputImage.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    NSString *acvFilePath = [[NSBundle mainBundle] pathForResource:@"Curve1" ofType:@"acv"];
    NSData *data = [NSData dataWithContentsOfFile: acvFilePath ];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorCube"];
    [filter setValue:image forKey:@"inputImage"];
    [filter setValue:@2 forKey:@"inputCubeDimension"];
    [filter setValue:data forKey:@"inputCubeData"];
    
    CIImage* outputImage = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    context = nil;
    
    return newImage;
}

- (UIImage *)applyGPULookupFilter:(UIImage *)inputImage{
    GPUImagePicture *image = [[GPUImagePicture alloc] initWithImage:inputImage];
    //    NSString *acvFilePath = [[NSBundle mainBundle] pathForResource:@"Curve1" ofType:@"acv"];
    GPUImagePicture *lookupImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"lookup_amatorka.png"]];
    
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    
    [image addTarget: lookupFilter];
    [lookupImageSource addTarget: lookupFilter];
    [lookupFilter useNextFrameForImageCapture];
    
    [image processImage];
    [lookupImageSource processImage];
    
    UIImage* filteredImage = [lookupFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    
    return filteredImage;
}

@end
