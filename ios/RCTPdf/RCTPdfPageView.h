/**
 * Copyright (c) 2017-present, Wonday (@wonday.org)
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#if __has_include(<React/RCTAssert.h>)
#import <React/UIView+React.h>
#else
#import "UIView+React.h"
#endif

#import "PDFScrollView.h"

@interface RCTPdfPageView : UIView

@property(nonatomic) int fileNo;
@property(nonatomic) int page;
@property(nonatomic) CGFloat maxZoom;
@property(nonatomic) CGFloat minZoom;
@property(nonatomic) BOOL allowZoom;

@property(nonatomic) CGFloat myScale;
@property(nonatomic) CGPDFPageRef pdfPage;
@property(nonatomic) PDFScrollView *pdfScrollView;

@property (nonatomic, copy) RCTBubblingEventBlock onPageSingleTap;
@property (nonatomic, copy) RCTBubblingEventBlock onScaleChanged;

@end
