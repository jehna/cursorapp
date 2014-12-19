//
//  ViewController.h
//  cursorapp
//
//  Created by Jesse Luoto on 17/12/14.
//  Copyright (c) 2014 Jesse Luoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (void)save;

@end

enum AppMode {
    AppMode_Insert,
    AppMode_Edit
};
