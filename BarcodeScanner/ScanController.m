//
//  ScanController.m
//  BarcodeScanner
//
//  Created by Vijay Subrahmanian on 09/05/15.
//  Copyright (c) 2015 Hasnain Jafri. All rights reserved.
//

#import "ScanController.h"
#import <AVFoundation/AVFoundation.h>
#import "LicenseParser.h"
#import "CameraFocusSquare.h"

@interface ScanController () <AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL isLayout;
}
@property (weak, nonatomic) IBOutlet UITextView *scannedBarcode;
@property (weak, nonatomic) IBOutlet UIView *cameraPreviewView;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureLayer;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;


@end

@implementation ScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Start the camera capture session as soon as the view appears completely.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if(isLayout == FALSE){
        isLayout = TRUE;
        [self setupScanningSession];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rescanButtonPressed:(id)sender {
    // Start scanning again.
    [self.captureSession startRunning];
}

- (IBAction)copyButtonPressed:(id)sender {
    // Copy the barcode text to the clipboard.
    [UIPasteboard generalPasteboard].string = self.scannedBarcode.text;
}

- (IBAction)doneButtonPressed:(id)sender {
    [self.captureSession stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void)AVCaptureInputPortFormatDescriptionDidChange:(NSNotification*)notification
{
    //_captureMetadataOutput.rectOfInterest = [self.captureLayer rectForMetadataOutputRectOfInterest:CGRectMake(0, 0, 500, 200)];
}

// Local method to setup camera scanning session.
- (void)setupScanningSession {
    // Initalising hte Capture session before doing any video capture/scanning.
    self.captureSession = [[AVCaptureSession alloc] init];
    
    NSError *error;
    // Set camera capture device to default and the media type to video.
    _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in videoDevices){
        
        if (device.position == AVCaptureDevicePositionBack){
            
            _captureDevice = device;
            break;
        }
    }
    
    if ([_captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
    }
    
    if([_captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
    {
        if([_captureDevice lockForConfiguration:nil]) {
            
            [_captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [_captureDevice unlockForConfiguration];
        
    }
    
    if([_captureDevice isLowLightBoostSupported]){
        [_captureDevice setAutomaticallyEnablesLowLightBoostWhenAvailable:YES];
    }
    
    // Set video capture input: If there a problem initialising the camera, it will give am error.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&error];
    
    if (!input) {
        NSLog(@"Error Getting Camera Input");
        return;
    }
    // Adding input souce for capture session. i.e., Camera
    [self.captureSession addInput:input];
    
    _captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    // Set output to capture session. Initalising an output object we will use later.
    [self.captureSession addOutput:_captureMetadataOutput];
    
    //_captureMetadataOutput.rectOfInterest = CGRectMake(0, 0, 1, 1);
    
    /* CGRect scanRect = CGRectMake(0, 50, self.view.frame.size.width, 200);
     float x = scanRect.origin.x/1334;
     float y = scanRect.origin.y/750;
     float width = scanRect.size.width/1334;
     float height = scanRect.size.height/750;
     CGRect scanRectTransformed = CGRectMake(x, y, width, height);
     _captureMetadataOutput.rectOfInterest = scanRectTransformed;*/
    
    
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureInputPortFormatDescriptionDidChange:) name:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil];
    
    // Create a new queue and set delegate for metadata objects scanned.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("scanQueue", NULL);
    [_captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    // Delegate should implement captureOutput:didOutputMetadataObjects:fromConnection: to get callbacks on detected metadata.
    [_captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypePDF417Code]];
    //captureMetadataOutput.rectOfInterest = self.cameraPreviewView.layer.bounds;
    
    // Layer that will display what the camera is capturing.
    self.captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.captureLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.captureLayer setFrame:self.cameraPreviewView.layer.bounds];
    //[self.captureLayer rectForMetadataOutputRectOfInterest:self.captureLayer.bounds];
    
    // Adding the camera AVCaptureVideoPreviewLayer to our view's layer.
    [self.cameraPreviewView.layer addSublayer:self.captureLayer];
    
    
    /*UIView *highlightView = [[UIView alloc] init];
     highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
     highlightView.layer.borderColor = [UIColor greenColor].CGColor;
     highlightView.layer.borderWidth = 2;
     [highlightView setFrame:CGRectMake(5, self.view.center.y-50, self.view.frame.size.width-10, 100)];
     //[highlightView setFrame:scanRect];
     [self.cameraPreviewView addSubview:highlightView];*/
    
    [self.captureSession startRunning];
}

// AVCaptureMetadataOutputObjectsDelegate method
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // Do your action on barcode capture here:
    NSString *capturedBarcode = nil;
    
    // Specify the barcodes you want to read here:
    NSArray *supportedBarcodeTypes = @[AVMetadataObjectTypeUPCECode,
                                       AVMetadataObjectTypeCode39Code,
                                       AVMetadataObjectTypeCode39Mod43Code,
                                       AVMetadataObjectTypeEAN13Code,
                                       AVMetadataObjectTypeEAN8Code,
                                       AVMetadataObjectTypeCode93Code,
                                       AVMetadataObjectTypeCode128Code,
                                       AVMetadataObjectTypePDF417Code,
                                       AVMetadataObjectTypeQRCode,
                                       AVMetadataObjectTypeAztecCode];
    
    //NSArray *supportedBarcodeTypes = @[AVMetadataObjectTypePDF417Code];
    
    // In all scanned values..
    for (AVMetadataObject *barcodeMetadata in metadataObjects) {
        // ..check if it is a suported barcode
        for (NSString *supportedBarcode in supportedBarcodeTypes) {
            
            if ([supportedBarcode isEqualToString:barcodeMetadata.type]) {
                // This is a supported barcode
                // Note barcodeMetadata is of type AVMetadataObject
                // AND barcodeObject is of type AVMetadataMachineReadableCodeObject
                AVMetadataMachineReadableCodeObject *barcodeObject = (AVMetadataMachineReadableCodeObject *)[self.captureLayer transformedMetadataObjectForMetadataObject:barcodeMetadata];
                capturedBarcode = [barcodeObject stringValue];
                // Got the barcode. Set the text in the UI and break out of the loop.
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.captureSession stopRunning];
                    self.scannedBarcode.text = capturedBarcode;
                    
                    [self parseLicenseData:capturedBarcode];
                });
                return;
            }
        }
    }
}

- (void) tapSent:(CGPoint)sender {
    
    
    CGPoint aPoint = sender;//[sender locationInView:_imageStreamV];
    if (_captureDevice != nil) {
        if([_captureDevice isFocusPointOfInterestSupported] &&
           [_captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            
            // we subtract the point from the width to inverse the focal point
            // focus points of interest represents a CGPoint where
            // {0,0} corresponds to the top left of the picture area, and
            // {1,1} corresponds to the bottom right in landscape mode with the home button on the right—
            // THIS APPLIES EVEN IF THE DEVICE IS IN PORTRAIT MODE
            // (from docs)
            // this is all a touch wonky
            double pX = aPoint.x / self.view.bounds.size.width;
            double pY = aPoint.y / self.view.bounds.size.height;
            double focusX = pY;
            // x is equal to y but y is equal to inverse x ?
            double focusY = 1 - pX;
            
            //NSLog(@"SC: about to focus at x: %f, y: %f", focusX, focusY);
            if([_captureDevice isFocusPointOfInterestSupported] && [_captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                
                if([_captureDevice lockForConfiguration:nil]) {
                    [_captureDevice setFocusPointOfInterest:CGPointMake(focusX, focusY)];
                    [_captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
                    [_captureDevice setExposurePointOfInterest:CGPointMake(focusX, focusY)];
                    [_captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                    
                    
                    //NSLog(@"SC: Done Focusing");
                }
                [_captureDevice unlockForConfiguration];
            }
        }
    }
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:touch.view];
    [self tapSent:touchPoint];
    
    CameraFocusSquare *oldCamFocus = (CameraFocusSquare*)[self.view viewWithTag:1010];
    
    if(oldCamFocus != nil){
        [oldCamFocus.layer removeAllAnimations];
        [oldCamFocus removeFromSuperview];
        oldCamFocus = nil;
    }
    
    CameraFocusSquare *camFocus = [[CameraFocusSquare alloc]initWithFrame:CGRectMake(touchPoint.x-40, touchPoint.y-40, 80, 80)];
    [camFocus setTag:1010];
    [camFocus setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:camFocus];
    [camFocus setNeedsDisplay];
    
    SEL animeEnd = NSSelectorFromString(@"animationDidEnd");
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:3.0];
    [UIView setAnimationDidStopSelector:animeEnd];
    [camFocus setAlpha:0.0];
    [UIView commitAnimations];
}

-(void)animationDidEnd{
    NSLog(@"");
    
    CameraFocusSquare *camFocus = (CameraFocusSquare*)[self.view viewWithTag:1010];
    [camFocus removeFromSuperview];
    camFocus = nil;
}

-(void)parseLicenseData:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Data" message:[[LicenseParser parseLicense:message] description] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.captureSession startRunning];
}

@end
