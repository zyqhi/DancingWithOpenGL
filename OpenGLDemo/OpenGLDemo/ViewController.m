//
//  ViewController.m
//  OpenGLDemo
//
//  Created by zyq on 12/12/2017.
//  Copyright © 2017 Mutsu. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

@interface ViewController ()

@property (nonatomic, strong) OpenGLView *glView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.glView = [[OpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
}

@end
