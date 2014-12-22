//
//  UIColor+HexString.m
//  cursorapp
//
//  Created by Jesse Luoto on 22/12/14.
//  Copyright (c) 2014 Jesse Luoto. All rights reserved.
//

#import "UIColor+HexString.h"

@implementation UIColor(HexString)

+ (UIColor *)colorWithHex:(int)rgbValue {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                           green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                            blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                           alpha:1.0];
}

@end
