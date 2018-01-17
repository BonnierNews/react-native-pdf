#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TiledPDFView.h"

@class PDFScrollView;
@protocol PDFScrollViewDelegate
@optional
- (void)pdfScrollViewTap:(CGPoint)touchPoint relativeTouchPoint:(CGPoint)relativeTouchPoint;
- (void)pdfScrollViewScaleChange:(CGFloat)scale;
@end

@interface PDFScrollView : UIScrollView <UIScrollViewDelegate>


// Frame of the PDF
@property (nonatomic) CGRect pageRect;
// A low resolution image of the PDF page that is displayed until the TiledPDFView renders its content.
@property (nonatomic, weak) UIView *backgroundImageView;
// The TiledPDFView that is currently front most.
@property (nonatomic, weak) TiledPDFView *tiledPDFView;
// The old TiledPDFView that we draw on top of when the zooming stops.
@property (nonatomic, weak) TiledPDFView *oldTiledPDFView;
// Current PDF zoom scale.
@property (nonatomic) CGFloat PDFScale;
// Current running scroll view scale
@property (nonatomic) CGFloat runningScale;

@property(nonatomic) CGFloat maxZoom;
@property(nonatomic) CGFloat minZoom;
@property(nonatomic) BOOL allowZoom;

@property(nonatomic) id<PDFScrollViewDelegate> pdfDelegate;

- (void)setPDFPage:(CGPDFPageRef)PDFPage;
-(void)replaceTiledPDFViewWithFrame:(CGRect)frame;

@end
