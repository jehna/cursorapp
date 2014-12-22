//
//  UIColor+HexString.h
//  cursorapp
//
//  Created by Jesse Luoto on 22/12/14.
//  Copyright (c) 2014 Jesse Luoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor(HexString)

+ (UIColor *)colorWithHex:(int)rgbValue;

@end