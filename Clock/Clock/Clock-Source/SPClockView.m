//
//  SPClockView.m
//  Clock
//
//  Created by Suraj on 16/8/14.
//  Copyright (c) 2014 Su Media. All rights reserved.
//

#import "SPClockView.h"

#define borderWidth         2
#define borderAlpha         1.0
#define graduationOffset    10
#define graduationLength    5.0
#define graduationWidth     1.0
#define digitOffset         0

@interface SPDigitalClock()

@property (assign, nonatomic) NSDate *time;
@property(assign,nonatomic) NSInteger seconds;
@property(assign,nonatomic) NSInteger minutes;
@property(assign,nonatomic) NSInteger hours;

@end

@implementation SPDigitalClock

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
#if TARGET_OS_IPHONE
    self.backgroundColor = [UIColor clearColor];
    self.font = [UIFont boldSystemFontOfSize:20.0];
    self.textColor = [UIColor redColor];
    self.textAlignment = NSTextAlignmentCenter;
#else
    self.backgroundColor = [NSColor clearColor];
    self.font = [NSFont boldSystemFontOfSize:20.0];
    self.textColor = [NSColor redColor];
    self.alignment = NSTextAlignmentCenter;
#endif
    return self;
}

- (void)timerFired:(id)sender
{
    _time = [NSDate date];
    static NSCalendar *gregorian;
    
    if (!gregorian) gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:_timeZone]; // Japan
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:_time];
    
    self.hours = [weekdayComponents hour];
    self.minutes = [weekdayComponents minute];
    self.seconds = [weekdayComponents second];
}

- (void)setTimeZone:(NSTimeZone *)timeZone
{
    _timeZone = timeZone;
    CADisplayLink *animationTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerFired:)];
    animationTimer.frameInterval = 8.0;
    [animationTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

@end

@interface SPClockView()

@property (assign, nonatomic) NSDate *time;
@property(assign,nonatomic) CGPoint boundsCenter;
@property(assign,nonatomic) NSInteger seconds;
@property(assign,nonatomic) NSInteger minutes;
@property(assign,nonatomic) NSInteger hours;

@property (nonatomic, strong)
#if TARGET_OS_IPHONE
UIColor
#else
NSColor
#endif
*clockBackgroundColor;

@property (nonatomic, strong)
#if TARGET_OS_IPHONE
UIColor
#else
NSColor
#endif
*borderColor;

@property (nonatomic, strong)
#if TARGET_OS_IPHONE
UIColor
#else
NSColor
#endif
*digitColor;

@property (nonatomic, strong)
#if TARGET_OS_IPHONE
UIFont
#else
NSFont
#endif
*digitFont;

@end

@implementation SPClockView

- (void)initOutlook{
#if TARGET_OS_IPHONE
    self.backgroundColor = [UIColor clearColor];
    _clockBackgroundColor = [UIColor blackColor];
    _borderColor = [UIColor whiteColor];
    _digitColor = [UIColor whiteColor];
    double fontSize = 8+self.frame.size.width/50;
    _digitFont = [UIFont systemFontOfSize:fontSize];
#else
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor clearColor].CGColor;
    _clockBackgroundColor = [NSColor blackColor];
    _borderColor = [NSColor whiteColor];
    _digitColor = [NSColor whiteColor];
    double fontSize = 8+self.frame.size.width/50;
    _digitFont = [NSFont systemFontOfSize:fontSize];
#endif
    _boundsCenter = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
}

- (void)setAsDay:(BOOL)day{
#if TARGET_OS_IPHONE
    _clockBackgroundColor = day? [UIColor whiteColor]:[UIColor blackColor];
    _digitColor = day ? [UIColor blackColor] : [UIColor whiteColor];
    _borderColor = day ? [UIColor blackColor] : [UIColor whiteColor];
#else
    _clockBackgroundColor = day? [NSColor whiteColor]:[NSColor blackColor];
    _digitColor = day ? [NSColor blackColor] : [NSColor whiteColor];
    _borderColor = day ? [NSColor blackColor] : [NSColor whiteColor];
#endif
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initOutlook];
    }
    return self;
}

- (CGPoint)secondsHandPosition {
    float secondsAsRadians = (float)self.seconds / 60.0 * 2.0 * M_PI - M_PI_2;
    float handRadius = self.frame.size.width / 3.2;
    return CGPointMake(handRadius*cosf(secondsAsRadians)+self.boundsCenter.x, handRadius*sinf(secondsAsRadians)+self.boundsCenter.y);
}

- (CGPoint)minutesHandPosition {
    float minutesAsRadians = (float)self.minutes / 60.0 * 2.0 * M_PI - M_PI_2;
    float handRadius = self.frame.size.width / 3.6;
    return CGPointMake(handRadius*cosf(minutesAsRadians)+self.boundsCenter.x, handRadius*sinf(minutesAsRadians)+self.boundsCenter.y);
}

- (CGPoint)hoursHandPosition {
    float hoursAsRadians = (float)(self.hours+(float)self.minutes/60.0) / 12.0 * 2.0 * M_PI - M_PI_2;
    float handRadius = self.frame.size.width / 4.2;
    return CGPointMake(handRadius*cosf(hoursAsRadians)+self.boundsCenter.x, handRadius*sinf(hoursAsRadians)+self.boundsCenter.y);
}

- (void)drawRect:(CGRect)rect {
    // CLOCK'S FACE
    CGContextRef ctx =
#if TARGET_OS_IPHONE
    UIGraphicsGetCurrentContext();
#else
    [[NSGraphicsContext currentContext] CGContext];
#endif
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColorWithColor(ctx, self.clockBackgroundColor.CGColor);
    CGContextFillPath(ctx);
    
    // CLOCK'S CENTER
    CGFloat radius = 6.0;
    CGRect center2 = CGRectMake(self.boundsCenter.x-radius, self.boundsCenter.y-radius, 2*radius, 2*radius);
    CGContextAddEllipseInRect(ctx, center2);
    CGContextSetFillColorWithColor(ctx, _digitColor.CGColor);
    CGContextFillPath(ctx);
    
    // CLOCK'S BORDER
    CGContextAddEllipseInRect(ctx, CGRectMake(rect.origin.x + borderWidth/2, rect.origin.y + borderWidth/2, rect.size.width - borderWidth, rect.size.height - borderWidth));
    CGContextSetStrokeColorWithColor(ctx, self.borderColor.CGColor);
    CGContextSetLineWidth(ctx,borderWidth);
    CGContextStrokePath(ctx);
    
    // CLOCK'S GRADUATION
    for (int i = 0; i<60; i++) {
        CGFloat gradLength = graduationLength;
        if((i+1)%5== 1) gradLength = gradLength + 10;
        CGPoint P1 = CGPointMake((self.frame.size.width/2 + ((self.frame.size.width - borderWidth*2 - graduationOffset) / 2) * cos((6*i)*(M_PI/180)  - (M_PI/2))), (self.frame.size.width/2 + ((self.frame.size.width - borderWidth*2 - graduationOffset) / 2) * sin((6*i)*(M_PI/180)  - (M_PI/2))));
        CGPoint P2 = CGPointMake((self.frame.size.width/2 + ((self.frame.size.width - borderWidth*2 - graduationOffset - gradLength) / 2) * cos((6*i)*(M_PI/180)  - (M_PI/2))), (self.frame.size.width/2 + ((self.frame.size.width - borderWidth*2 - graduationOffset - gradLength) / 2) * sin((6*i)*(M_PI/180)  - (M_PI/2))));
        
        CAShapeLayer  *shapeLayer = [CAShapeLayer layer];
        UIBezierPath *path1 = [UIBezierPath bezierPath];
        shapeLayer.path = path1.CGPath;
        [path1 setLineWidth:graduationWidth];
        [path1 moveToPoint:P1];
        [path1 addLineToPoint:P2];
        path1.lineCapStyle = kCGLineCapSquare;
        [_digitColor set];
        
        [path1 strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    }
    
    // DIGIT DRAWING
    CGPoint center = CGPointMake(rect.size.width/2.0f, rect.size.height/2.0f);
    CGFloat markingDistanceFromCenter = rect.size.width/2.0f - _digitFont.lineHeight/4.0f - 15 + digitOffset;
    NSInteger offset = 4;
    
    for(unsigned i = 0; i < 12; i ++){
        NSString *hourNumber = [NSString stringWithFormat:@"%@%d", [NSString stringWithFormat:@"%@", i+1<10 ? @" ": @""] , i + 1 ];
        CGFloat labelX = center.x + (markingDistanceFromCenter - _digitFont.lineHeight/2.0f) * cos((M_PI/180)* (i+offset) * 30 + M_PI);
        CGFloat labelY = center.y + - 1 * (markingDistanceFromCenter - _digitFont.lineHeight/2.0f) * sin((M_PI/180)*(i+offset) * 30);
        [hourNumber drawInRect:CGRectMake(labelX - _digitFont.lineHeight/2.0f,labelY - _digitFont.lineHeight/2.0f,_digitFont.lineHeight,_digitFont.lineHeight) withAttributes:@{NSForegroundColorAttributeName: self.digitColor, NSFontAttributeName: _digitFont}];
    }
    
    // Hands
    CGPoint secondsHandPosition = [self secondsHandPosition];
    
    CGContextSetStrokeColorWithColor(ctx,
#if TARGET_OS_IPHONE
    [UIColor redColor].CGColor
#else
    [NSColor redColor].CGColor
#endif
    );
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, self.boundsCenter.x, self.boundsCenter.y);
    CGContextSetLineWidth(ctx,1.0);
    CGContextAddLineToPoint(ctx, secondsHandPosition.x, secondsHandPosition.y);
    CGContextStrokePath(ctx);
    
    CGPoint minutesHandPosition = [self minutesHandPosition];
    
    CGContextSetStrokeColorWithColor(ctx, _digitColor.CGColor);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, self.boundsCenter.x, self.boundsCenter.y);
    CGContextSetLineWidth(ctx,4.0);
    CGContextAddLineToPoint(ctx, minutesHandPosition.x, minutesHandPosition.y);
    CGContextStrokePath(ctx);
    
    CGPoint hoursHandPosition = [self hoursHandPosition];
    
    CGContextSetStrokeColorWithColor(ctx, _digitColor.CGColor);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, self.boundsCenter.x, self.boundsCenter.y);
    CGContextSetLineWidth(ctx,4.0);
    CGContextAddLineToPoint(ctx, hoursHandPosition.x, hoursHandPosition.y);
    CGContextStrokePath(ctx);
    
    // SECOND's CENTER
    radius = 3.0;
    CGRect center3 = CGRectMake(self.boundsCenter.x-radius, self.boundsCenter.y-radius, 2*radius, 2*radius);
    CGContextAddEllipseInRect(ctx, center3);
    CGContextSetFillColorWithColor(ctx,
#if TARGET_OS_IPHONE
    [UIColor redColor].CGColor
#else
    [NSColor redColor].CGColor
#endif
    );
    CGContextFillPath(ctx);
}

- (void)timerFired:(id)sender
{
    NSDate * newtime = [NSDate date]; //here was an error when I was triying to use only the analog Clock

    static NSCalendar *gregorian;
    
    if (!gregorian) gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:_timeZone]; // Japan
    
    //    Update Deprecated Method
    //    Fix crash (deallocated _time variable)
    NSDateComponents *weekdayComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
    
    self.hours = [weekdayComponents hour];
    BOOL isDay = (self.hours > 6 && self.hours < 18);
    [self setAsDay:isDay];
    if (self.hours > 12) self.hours -= 12;
    
    self.minutes = [weekdayComponents minute];
    self.seconds = [weekdayComponents second];
    
    [self setNeedsDisplay];
}

- (void)setTimeZone:(NSTimeZone *)timeZone
{
    _timeZone = timeZone;
    CADisplayLink *animationTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerFired:)];
    animationTimer.frameInterval = 8.0;
    [animationTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

@end
