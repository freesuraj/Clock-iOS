//
//  SPClockView.h
//  Clock
//
//  Created by Suraj on 16/8/14.
//  Copyright (c) 2014 Su Media. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

@interface SPDigitalClock :
#if TARGET_OS_IPHONE
UILabel
#else
NSTextField
#endif
@property (strong,nonatomic) NSTimeZone *timeZone;
@end

@interface SPClockView :
#if TARGET_OS_IPHONE
UIView
#else
NSView
#endif
@property (strong,nonatomic) NSTimeZone *timeZone;
@end
