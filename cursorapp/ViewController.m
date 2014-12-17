//
//  ViewController.m
//  cursorapp
//
//  Created by Jesse Luoto on 17/12/14.
//  Copyright (c) 2014 Jesse Luoto. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIKeyInput>
@property (nonatomic) UIView *cursor;
@property (nonatomic) NSMutableString *currentText;
@property (nonatomic) UIImageView *textView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentText = [NSMutableString string];
    
    int cursorWidth = 24;
    int cursorHeight = 40;
    CGRect cursorSize = CGRectMake(self.view.frame.size.width/2-cursorWidth/2,
                                   self.view.frame.size.height/2-cursorHeight/2,
                                   cursorWidth,
                                   cursorHeight);
    self.cursor = [[UIView alloc] initWithFrame:cursorSize];
    [self.cursor setBackgroundColor:[UIColor grayColor]];
    
    [self.view addSubview:self.cursor];
    //[self blinkCursor];
    
    self.textView = [[UIImageView alloc] init];
//    [self.textView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:self.textView];
    
    [self becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)blinkCursor {
    [self.cursor setHidden:!self.cursor.hidden];
    [self performSelector:@selector(blinkCursor) withObject:self afterDelay:1.0];
}

#pragma mark - Text rendering
- (void)redrawText {
    UIFont *font = [UIFont fontWithName:@"Courier" size:80];
    CGSize size = CGSizeMake(48*self.currentText.length+0.1, 80);
    UIGraphicsBeginImageContext(size);
    //[self.textRenderImage drawInRect:CGRectMake(0,0,size.width,size.height)];
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [[UIColor blackColor] set];
    [self.currentText drawInRect:CGRectIntegral(rect) withAttributes:@{NSFontAttributeName:font}];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    newImage = [UIImage imageWithCGImage:[newImage CGImage]
                                   scale:[UIScreen mainScreen].scale
                             orientation:UIImageOrientationUp];
    
    CGRect textPos = CGRectMake(self.view.frame.size.width/2-14-size.width/2,
                                self.view.frame.size.height/2-20,
                                size.width/2,
                                size.height/2);
    [self.textView setImage:newImage];
    [self.textView setFrame:textPos];
}

#pragma mark - UIResponder

-(BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - UIKeyInput

- (void)insertText:(NSString *)text {
    [self.currentText appendString:text];
    NSLog(@"%@", self.currentText);
    [self redrawText];
}

- (void)deleteBackward {
    if(self.currentText.length < 1) return;
    NSRange lastChar = NSMakeRange(self.currentText.length-1, 1);
    [self.currentText deleteCharactersInRange:lastChar];
    NSLog(@"%@", self.currentText);
    [self redrawText];
}

- (BOOL)hasText {
    return self.currentText.length > 0;
}

@end
