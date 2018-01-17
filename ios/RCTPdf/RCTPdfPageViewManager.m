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

@implementation RCTPdfPageViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    RCTPdfPageView *pageView = [[RCTPdfPageView alloc] init];
    return pageView;
}

RCT_EXPORT_VIEW_PROPERTY(fileNo, int);
RCT_EXPORT_VIEW_PROPERTY(page, int);
RCT_EXPORT_VIEW_PROPERTY(maxZoom, CGFloat);
RCT_EXPORT_VIEW_PROPERTY(minZoom, CGFloat);
RCT_EXPORT_VIEW_PROPERTY(allowZoom, BOOL);

RCT_EXPORT_VIEW_PROPERTY(onPageSingleTap, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onScaleChanged, RCTBubblingEventBlock)

@end
