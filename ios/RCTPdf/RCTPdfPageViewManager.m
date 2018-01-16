/**
 * Copyright (c) 2017-present, Wonday (@wonday.org)
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import "RCTPdfPageViewManager.h"
#import "RCTPdfPageView.h"

@interface RCTPdfPageViewManager () <UIScrollViewDelegate>

@end@implementation RCTPdfPageViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    RCTPdfPageView *pageView = [[RCTPdfPageView alloc] init];
    pageView.delegate = self;
    return pageView;
}

RCT_EXPORT_VIEW_PROPERTY(fileNo, int);
RCT_EXPORT_VIEW_PROPERTY(page, int);

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:RCTPdfPageView.class]) {
        RCTPdfPageView *pdfPageView = (RCTPdfPageView *) scrollView;
        return pdfPageView.pdfPage;
    }
    return nil;
}

-(void) scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"%f", scrollView.zoomScale);
}
@end
