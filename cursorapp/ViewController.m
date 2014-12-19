//
//  ViewController.m
//  cursorapp
//
//  Created by Jesse Luoto on 17/12/14.
//  Copyright (c) 2014 Jesse Luoto. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIKeyInput, UIGestureRecognizerDelegate>
@property (nonatomic) NSMutableArray *currentTexts;
@property (nonatomic) NSMutableArray *textViews;
@property (nonatomic) UIView *cursorView;
@end

@implementation ViewController

CGFloat minScale = 0.1;
CGFloat maxScale = 1.5;

CGFloat lastScale = 1.0;
CGFloat lastRotation;

CGFloat firstX = 0;
CGFloat firstY = 0;

int cursorWidth = 24;
int cursorHeight = 40;
int currentChar = 0;
int currentLine = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentTexts = [NSMutableArray arrayWithObject:[NSMutableString string]];
    
    CGRect cursorSize = CGRectMake(self.view.frame.size.width/2-cursorWidth/2,
                                   self.view.frame.size.height/2-cursorHeight/2,
                                   cursorWidth,
                                   cursorHeight);
    self.cursorView = [[UIView alloc] initWithFrame:cursorSize];
    [self.cursorView setBackgroundColor:[UIColor grayColor]];
    
    [self.view addSubview:self.cursorView];
    //[self blinkCursor];
    
    self.textViews = [NSMutableArray arrayWithObject:[[UIImageView alloc] init]];
//    [self.textView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:self.textView];
    
    [self becomeFirstResponder];
    
    
    // Touch handlers
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    [pinchRecognizer setDelegate:self];
    [self.view addGestureRecognizer:pinchRecognizer];
    /*
    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    [rotationRecognizer setDelegate:self];
    [self.view addGestureRecognizer:rotationRecognizer];
    */
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [self.view addGestureRecognizer:panRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)blinkCursor {
    [self.cursorView setHidden:!self.cursorView.hidden];
    [self performSelector:@selector(blinkCursor) withObject:self afterDelay:1.0];
}

#pragma mark - Text rendering
- (void)redrawText {
    UIFont *font = [UIFont fontWithName:@"Courier" size:cursorHeight*2];
    CGSize size = CGSizeMake(cursorWidth*2*self.currentText.length+0.1, cursorHeight*2);
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
    
    float posX = cursorWidth*2*currentChar;
    CGRect textPos = CGRectMake(self.view.frame.size.width/2-12.5-posX/2,
                                self.view.frame.size.height/2-20,
                                size.width/2,
                                size.height/2);
    
    [self.textView setImage:newImage];
    [self.textView setFrame:textPos];
    
    int i = 0;
    for(UIImageView *line in self.textViews) {
        CGRect lineFrame = [line frame];
        lineFrame.origin.y = textPos.origin.y + (i-currentLine)*cursorHeight;
        lineFrame.origin.x = textPos.origin.x;
        [line setFrame:lineFrame];
        i++;
    }
}

- (NSMutableString *)currentText {
    return [self.currentTexts objectAtIndex:currentLine];
}

- (UIImageView *)textView {
    return [self.textViews objectAtIndex:currentLine];
}

#pragma mark - UIResponder

-(BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - UIKeyInput

- (void)insertText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        NSString *hoppingText;
        if(currentChar != self.currentText.length) {
            NSRange restOfTheLine = NSMakeRange(currentChar, self.currentText.length-currentChar);
            hoppingText = [self.currentText substringWithRange:restOfTheLine];
            [self.currentText deleteCharactersInRange:restOfTheLine];
            [self redrawText];
        }
        
        currentLine++;
        currentChar = 0;
        [self.currentTexts insertObject:[NSMutableString string] atIndex:currentLine];
        [self.textViews insertObject:[[UIImageView alloc] init] atIndex:currentLine];
        [self.view addSubview:self.textView];
        
        if(hoppingText) [self.currentText insertString:hoppingText atIndex:0];
    } else {
        [self.currentText insertString:text atIndex:currentChar];
        currentChar++;
    }
    //NSLog(@"%@", self.currentText);
    [self redrawText];
}

- (void)deleteBackward {
    if(currentChar == 0) {
        if(currentLine == 0) return;
        NSString *remainingText = self.currentText;
        [self.currentTexts removeObjectAtIndex:currentLine];
        [self.textView removeFromSuperview];
        [self.textViews removeObjectAtIndex:currentLine];
        currentLine--;
        currentChar = [self.currentText length];
        [self.currentText insertString:remainingText atIndex:currentChar];
    } else {
        NSRange lastChar = NSMakeRange(currentChar-1, 1);
        [self.currentText deleteCharactersInRange:lastChar];
        currentChar--;
    }
    //NSLog(@"%@", self.currentText);
    [self redrawText];
}

- (BOOL)hasText {
    return self.currentText.length > 0;
}

#pragma mark - UIGestureRecognizerDelegate
-(void)scale:(UIPinchGestureRecognizer *)sender {
    return;
    //[self.view bringSubviewToFront:[(UIPinchGestureRecognizer*)sender view]];
    
    if([sender state] == UIGestureRecognizerStateEnded) {
        lastScale = 1.0;
        return;
    }
    
    CGFloat currentScale = [[self.textView.layer valueForKeyPath:@"transform.scale"] floatValue];
    CGFloat scale = 1.0 - (lastScale - [sender scale]);
    
    scale = MIN(scale, maxScale / currentScale);
    scale = MAX(scale, minScale / currentScale);
    
    CGAffineTransform currentTransform = self.textView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    
    [self.textView setTransform:newTransform];
    [self.cursorView setTransform:newTransform];
    
    lastScale = [sender scale];
}

CGFloat padX;
CGFloat padY;
int firstChar;
int firstLine;
-(void)move:(UIPanGestureRecognizer *)sender {

    //[[[sender view] layer] removeAllAnimations];
    
    //[self.view bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
    CGPoint translatedPoint = [sender translationInView:self.textView];
    
    if([sender state] == UIGestureRecognizerStateBegan) {
        firstX = [self.textView center].x;
        firstY = [self.textView center].y;
        padX = fmodf(firstX, cursorWidth);
        padY = fmodf(firstY, cursorHeight);
        firstChar = currentChar;
        firstLine = currentLine;
    }
    
    currentLine = firstLine - (int)roundf(translatedPoint.y/cursorHeight);
    currentLine = (int)MIN(self.textViews.count-1,MAX(0,currentLine));
    currentChar = firstChar - (int)roundf(translatedPoint.x/cursorWidth);
    currentChar = (int)MIN(self.currentText.length,MAX(0,currentChar));
    [self redrawText];
    /*
    CGFloat x = roundf((firstX+translatedPoint.x)/cursorWidth)*cursorWidth+padX;
    CGFloat y = roundf((firstY+translatedPoint.y)/cursorHeight)*cursorHeight+padY;
    
    x = MIN(self.view.frame.size.width/2, x);
    
    translatedPoint = CGPointMake(x,[self.textView center].y);
    
    [self.textView setCenter:translatedPoint];*/
    /*
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        CGFloat finalX = translatedPoint.x + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].x);
        CGFloat finalY = translatedPoint.y + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
        
        if(UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
            if(finalX < 0) {
                finalX = 0;
            } else if(finalX > 768) {
                finalX = 768;
            }
            
            if(finalY < 0) {
                finalY = 0;
            } else if(finalY > 1024) {
                finalY = 1024;
            }
        } else {
            if(finalX < 0) {
                finalX = 0;
            } else if(finalX > 1024) {
                finalX = 768;
            }
            if(finalY < 0) {
                finalY = 0;
            } else if(finalY > 768) {
                finalY = 1024;
            }
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.35];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [[sender view] setCenter:CGPointMake(finalX, finalY)];
        [UIView commitAnimations];
    }*/
}

-(void)tapped:(id)sender {
    NSLog(@"See a tap gesture");
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
}

@end
