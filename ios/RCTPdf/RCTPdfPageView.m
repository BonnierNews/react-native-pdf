/**
 * Copyright (c) 2017-present, Wonday (@wonday.org)
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTPdfPageView.h"

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#if __has_include(<React/RCTAssert.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTEventDispatcher.h>
#import <React/UIView+React.h>
#import <React/RCTLog.h>
#else
#import "RCTBridgeModule.h"
#import "RCTEventDispatcher.h"
#import "UIView+React.h"
#import "RCTLog.h"
#endif

#ifndef __OPTIMIZE__
// only output log when debug
#define DLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DLog( s, ... )
#endif

// output log both debug and release
#define RLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

@interface RCTPdfPageView ()
@end

@implementation RCTPdfPageView {
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = UIColor.blueColor;
        self.maximumZoomScale = 4.0;
        self.minimumZoomScale = 1.0;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.bounces = YES;
        self.bouncesZoom = YES;
        self.showsHorizontalScrollIndicator = YES;
        self.showsVerticalScrollIndicator = YES;
        self.pdfPage = [[PdfPage alloc] initWithFrame:self.bounds];
        self.pdfPage.backgroundColor = UIColor.clearColor;
        [self addSubview:self.pdfPage];
    }
    
    return self;
}

- (void)didSetProps:(NSArray<NSString *> *)changedProps
{
    long int count = [changedProps count];
    for (int i = 0 ; i < count; i++) {
        
        if ([[changedProps objectAtIndex:i] isEqualToString:@"page"]) {
            [self setNeedsDisplay];
        }

    }
    [self setNeedsDisplay];
}


- (void)reactSetFrame:(CGRect)frame
{
    [super reactSetFrame:frame];
    self.pdfPage.frame = frame;
    self.contentSize = frame.size;
}

-(void)setPage:(int)page {
    self.pdfPage.page = page;
}

-(void)setFileNo:(int)fileNo {
    self.pdfPage.fileNo = fileNo;
}

@end
