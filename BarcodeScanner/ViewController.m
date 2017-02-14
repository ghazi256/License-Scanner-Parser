//
//  ViewController.m
//  BarcodeScanner
//
//  Created by Vijay Subrahmanian on 09/05/15.
//  Copyright (c) 2015 Hasnain Jafri. All rights reserved.
//

#import "ViewController.h"
#import "ScanController.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *scannedBarcodeTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Reading the barcode (if any) from the clipboard and setting the text.
    self.scannedBarcodeTextView.text = [UIPasteboard generalPasteboard].string;
    
    ScanController *containerView = [self.storyboard instantiateViewControllerWithIdentifier:@"ScanController"];
    [self.navigationController pushViewController:containerView animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
