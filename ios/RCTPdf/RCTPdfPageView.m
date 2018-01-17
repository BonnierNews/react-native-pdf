/**
 * Copyright (c) 2017-present, Wonday (@wonday.org)
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTPdfPageView.h"
#import "PdfManager.h"
#import "PDFScrollView.h"
#import "TiledPDFView.h"

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

@interface RCTPdfPageView () <PDFScrollViewDelegate>
@end

@implementation RCTPdfPageView {
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.pdfScrollView = [[PDFScrollView alloc] init];
        self.pdfScrollView.pdfDelegate = self;
        [self addSubview:self.pdfScrollView];
    }
    
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self restoreScale];
}

- (void)reactSetFrame:(CGRect)frame
{
    [super reactSetFrame:frame];
    self.pdfScrollView.frame = frame;
}

-(void)setMinZoom:(CGFloat)minZoom {
    _minZoom = minZoom;
    self.pdfScrollView.minZoom = minZoom;
}

-(void)setMaxZoom:(CGFloat)maxZoom {
    _maxZoom = maxZoom;
    self.pdfScrollView.maxZoom = maxZoom;
}

-(void)setAllowZoom:(BOOL)allowZoom {
    _allowZoom = allowZoom;
    self.pdfScrollView.allowZoom = allowZoom;
}

-(void)setPage:(int)page {
    _page = page;
    [self loadPdfPage];
}

-(void)setFileNo:(int)fileNo {
    _fileNo = fileNo;
    [self loadPdfPage];
}

-(void)loadPdfPage {
    CGPDFDocumentRef pdfRef = [PdfManager getPdf: self.fileNo];
    NSLog(@"%@", pdfRef);
    self.pdfPage = CGPDFDocumentGetPage(pdfRef, self.page);
    if (self.pdfPage != nil) {
        [self.pdfScrollView setPDFPage:self.pdfPage];
    }
}

-(void)restoreScale {
    if (self.pdfPage == NULL) return;
    CGRect pageRect = CGPDFPageGetBoxRect( self.pdfPage, kCGPDFMediaBox );
    CGFloat yScale = self.frame.size.height/pageRect.size.height;
    CGFloat xScale = self.frame.size.width/pageRect.size.width;
    self.myScale = MIN( xScale, yScale );
    NSLog(@"%s self.myScale=%f",__PRETTY_FUNCTION__, self.myScale);
    self.pdfScrollView.bounds = self.bounds;
    self.pdfScrollView.zoomScale = 1.0;
    self.pdfScrollView.PDFScale = self.myScale;
    self.pdfScrollView.tiledPDFView.bounds = self.bounds;
    self.pdfScrollView.tiledPDFView.myScale = self.myScale;
    [self.pdfScrollView.tiledPDFView.layer setNeedsDisplay];
}

#pragma mark -
#pragma mark PDFScrollView delegate methods
- (void) pdfScrollViewTap:(CGPoint)touchPoint relativeTouchPoint:(CGPoint)relativeTouchPoint {
    if (self.onPageSingleTap) {
        self.onPageSingleTap(@{
            @"point": @{@"x": [NSNumber numberWithDouble:touchPoint.x], @"y": [NSNumber numberWithDouble:touchPoint.y]},
            @"relativePoint": @{@"x": [NSNumber numberWithDouble:relativeTouchPoint.x], @"y": [NSNumber numberWithDouble:touchPoint.y]}
        });
    }
}

- (void) pdfScrollViewScaleChange:(CGFloat)scale {
    if (self.onScaleChanged) {
        self.onScaleChanged(@{@"scale": [NSNumber numberWithDouble:scale]});
    }
}

@end
