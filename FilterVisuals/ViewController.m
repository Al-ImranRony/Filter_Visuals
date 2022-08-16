//
//  ViewController.m
//  FilterVisuals
//
//  Created by iRny on 9/16/21.
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
#import <GPUImage/GPUImageThresholdSketchFilter.h>
#import <GPUImage/GPUImageLocalBinaryPatternFilter.h>
#import <GPUImage/GPUImageHarrisCornerDetectionFilter.h>
#import <GPUImage/GPUImagePosterizeFilter.h>
#import <GPUImage/GPUImagePerlinNoiseFilter.h>
#import <GPUImage/GPUImageColorPackingFilter.h>

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
            outputImage = [self poissonBlendFilter:inputImage overlayImageName:@"j10"];
            break;
        case 3:
            outputImage = [self glassDistortionFilter:inputImage overlayImageName:@"texture1"];
            break;
        case 4:
            outputImage = [self poissonBlendFilter:inputImage overlayImageName:@"j3"];
            break;
        case 5:
            outputImage = [self applyToneCurve2Filter:inputImage];
            break;
        case 6:
            outputImage = [self thresholdSketchFilter:inputImage overlayImageName:@"PurpleTexture"];
            break;
        case 7:
            outputImage = [self localBinaryPatternFilter:inputImage overlayImageName:@"lookup_miss_etikate"];
            break;
        case 8:
            outputImage = [self posterizeFilter:inputImage overlayImageName:@"texture2"];
            break;
        case 9:
            outputImage = [self perlinNoiseFilter:inputImage overlayImageName:@"texture2"];
            break;
        case 10:
            outputImage = [self colorPackingFilter:inputImage overlayImageName:@"PurpleTexture"];
            break;
        case 11:
            outputImage = [self normalNoiseFilter:inputImage overlayImageName:@"PurpleTexture"];
            break;
        case 12:
            outputImage = [self textureNoiseFilter:inputImage overlayImageName:@"texture12"];
            break;
        case 13:
            outputImage = [self textureNoiseFilter:inputImage overlayImageName:@"j3"];
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
    self.secondImageView.image = [self chooseFilter: self.sourceImage forNumber: 4];
//    [self RGBToneCurveFilter:self.sourceImage];
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
    [self presentViewController:detailsVC animated:YES completion:nil];
}

- (UIImage *)applyToneCurve2Filter:(UIImage *)inputImage{
    
    GPUImageToneCurveFilter *toneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Curve2"];
    UIImage* blurredImage = [toneCurveFilter imageByFilteringImage:inputImage];
    
    return blurredImage;
}

//Noise Filters
-(UIImage *) normalNoiseFilter:(UIImage *) inputImage overlayImageName:(NSString *)imageName{
    CIImage* image = [CIImage imageWithCGImage:inputImage.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter* colorNoise = [CIFilter filterWithName:@"CIRandomGenerator"];
    CIImage* noiseImage = colorNoise.outputImage;
    
    CIFilter* whiteningFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    CIVector* whitenVector = [CIVector vectorWithX:0 Y:1 Z:0 W:0];
    CIVector* fineGrain = [CIVector vectorWithX:0 Y:0.005 Z:0 W:0];
    CIVector* zeroVector = [CIVector vectorWithX:0 Y:0 Z:0 W:0];
    [whiteningFilter setValue:noiseImage forKey:kCIInputImageKey];
    [whiteningFilter setValue:whitenVector forKey:@"inputRVector"];
    [whiteningFilter setValue:whitenVector forKey:@"inputGVector"];
    [whiteningFilter setValue:whitenVector forKey:@"inputBVector"];
    [whiteningFilter setValue:fineGrain forKey:@"inputAVector"];
    [whiteningFilter setValue:zeroVector forKey:@"inputBiasVector"];
    CIImage* whiteSpecks = whiteningFilter.outputImage;
    
    CIFilter* speckCompositor = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [speckCompositor setValue:whiteSpecks forKey:kCIInputImageKey];
    [speckCompositor setValue:image forKey:kCIInputBackgroundImageKey];
    CIImage* speckledImage = speckCompositor.outputImage;
    
    CGAffineTransform verticalScale = CGAffineTransformMakeScale(1.5, 25);
    CIImage* transformedNoise = [noiseImage imageByApplyingTransform:verticalScale];
    
    CIFilter* darkeningFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    CIVector* darkenVector = [CIVector vectorWithX:4 Y:0 Z:0 W:0];
    CIVector* darkenBias = [CIVector vectorWithX:0 Y:1 Z:1 W:1];
    [darkeningFilter setValue:transformedNoise forKey:kCIInputImageKey];
    [darkeningFilter setValue:darkenVector forKey:@"inputRVector"];
    [darkeningFilter setValue:zeroVector forKey:@"inputGVector"];
    [darkeningFilter setValue:zeroVector forKey:@"inputBVector"];
    [darkeningFilter setValue:zeroVector forKey:@"inputAVector"];
    [darkeningFilter setValue:darkenBias forKey:@"inputBiasVector"];
    CIImage* randomScratches = darkeningFilter.outputImage;
    
    CIFilter* grayscaleFilter = [CIFilter filterWithName:@"CIMinimumComponent"];
    [grayscaleFilter setValue:randomScratches forKey:kCIInputImageKey];
    CIImage* darkScratches = grayscaleFilter.outputImage;
    
    CIFilter* oldFilmCompositor = [CIFilter filterWithName:@"CIMultiplyCompositing"];
    [oldFilmCompositor setValue:darkScratches forKey:kCIInputImageKey];
    [oldFilmCompositor setValue:speckledImage forKey:kCIInputBackgroundImageKey];
    CIImage* oldFilmImage = oldFilmCompositor.outputImage;
    
    CIImage* finalImage = [oldFilmImage imageByCroppingToRect:image.extent];
    UIImage *filteredImage = [UIImage imageWithCIImage:finalImage];
    CGImageRef cgimg = [context createCGImage:oldFilmImage fromRect:[oldFilmImage extent]];
    UIImage *newImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    context = nil;
    
    return filteredImage;
}

-(UIImage *) textureNoiseFilter:(UIImage *) inputImage overlayImageName:(NSString *)imageName{
    CIImage* image = [CIImage imageWithCGImage:inputImage.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    UIImage *mImage = [UIImage imageNamed: imageName];
    CIImage* maskImage = [CIImage imageWithCGImage:mImage.CGImage];
    
    CIFilter* compositor = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [compositor setValue:maskImage forKey:kCIInputImageKey];
    [compositor setValue:image forKey:kCIInputBackgroundImageKey];
    CIImage* outputImage = compositor.outputImage;
    
    CIImage* finalImage = [outputImage imageByCroppingToRect:image.extent];
    UIImage *filteredImage = [UIImage imageWithCIImage:finalImage];
    context = nil;
    
    return filteredImage;
}

- (UIImage *)thresholdSketchFilter:(UIImage *)inputImage overlayImageName:(NSString *)imageName{
    GPUImageThresholdSketchFilter *thresholdSketchFilter = [[GPUImageThresholdSketchFilter alloc] init];
    UIImage* filteredImage = [thresholdSketchFilter imageByFilteringImage:inputImage];
    return filteredImage;
}

- (UIImage *)localBinaryPatternFilter:(UIImage *)inputImage overlayImageName:(NSString *)imageName{
    UIImage *initialImage = inputImage;
    GPUImagePicture *inputPicture = [[GPUImagePicture alloc] initWithImage:initialImage];
    UIImage *overlayImage = [UIImage imageNamed:imageName];
    GPUImagePicture *overlayPicture = [[GPUImagePicture alloc] initWithImage:overlayImage];
    GPUImageLocalBinaryPatternFilter *lbpFilter = [[GPUImageLocalBinaryPatternFilter alloc] init];
    
    [lbpFilter useNextFrameForImageCapture];
    
    [inputPicture addTarget:lbpFilter];
    [inputPicture processImage];
    [overlayPicture addTarget:lbpFilter];
    [overlayPicture processImage];
    
    UIImage *processedImage = [lbpFilter imageFromCurrentFramebuffer];
    return processedImage;
}

- (UIImage *)harrisCornerDetectionFilter:(UIImage *)inputImage overlayImageName:(NSString *)imageName{
    GPUImageHarrisCornerDetectionFilter *hcdFilter = [[GPUImageHarrisCornerDetectionFilter alloc] init];
    UIImage* filteredImage = [hcdFilter imageByFilteringImage:inputImage];
    return filteredImage;
}

- (UIImage *)posterizeFilter:(UIImage *)inputImage overlayImageName:(NSString *)imageName{
    GPUImagePosterizeFilter *posterizeFilter = [[GPUImagePosterizeFilter alloc] init];
    UIImage* filteredImage = [posterizeFilter imageByFilteringImage:inputImage];
    return filteredImage;
}

- (UIImage *)perlinNoiseFilter:(UIImage *)inputImage overlayImageName:(NSString *)imageName{
    UIImage *initialImage = inputImage;
    GPUImagePicture *inputPicture = [[GPUImagePicture alloc] initWithImage:initialImage];
    UIImage *overlayImage = [UIImage imageNamed:imageName];
    GPUImagePicture *overlayPicture = [[GPUImagePicture alloc] initWithImage:overlayImage];
    GPUImagePerlinNoiseFilter *perlinFilter = [[GPUImagePerlinNoiseFilter alloc] init];
    perlinFilter.colorStart = (GPUVector4){0.0, 0.0, 0.0, 0.0};
    perlinFilter.colorFinish = (GPUVector4){1.0, 1.0, 1.0, 1.0};
    perlinFilter.scale = 1.0;
    
    [perlinFilter useNextFrameForImageCapture];
    
    [inputPicture addTarget:perlinFilter];
    [inputPicture processImage];
    [overlayPicture addTarget:perlinFilter];
    [overlayPicture processImage];
    
    UIImage *processedImage = [perlinFilter imageFromCurrentFramebuffer];
    return processedImage;
}

- (UIImage *)colorPackingFilter:(UIImage *)inputImage overlayImageName:(NSString *)imageName{
    GPUImageColorPackingFilter *colorPackingFilter = [[GPUImageColorPackingFilter alloc] init];
    UIImage* filteredImage = [colorPackingFilter imageByFilteringImage:inputImage];
    return filteredImage;
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
