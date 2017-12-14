//
//  ViewController.m
//  GLKitDemo
//
//  Created by zyq on 13/12/2017.
//  Copyright © 2017 Mutsu. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import "DemoGLKViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    DemoGLKViewController *glkVC = [DemoGLKViewController new];
    [self presentViewController:glkVC animated:NO completion:nil];
}

@end
