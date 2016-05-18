//
//  ViewController.m
//  TestNib
//
//  Created by AB on 5/8/16.
//  Copyright © 2016 Intellectsoft Group. All rights reserved.
//

#import "ViewController.h"
#import "AANib.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AANib *nib = [AANib nibWithNibName:@"View" bundle:[NSBundle mainBundle]];
    UIView *view = [[nib instantiateWithOwner:self options:nil] firstObject];
    
    [self.view addSubview:view];
    view.frame = self.view.bounds;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
