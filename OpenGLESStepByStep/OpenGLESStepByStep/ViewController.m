//
//  ViewController.m
//  OpenGLESStepByStep
//
//  Created by zyq on 14/12/2017.
//  Copyright © 2017 Mutsu. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLESDemoView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    OpenGLESDemoView *glView = [[OpenGLESDemoView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:glView];
}



@end
