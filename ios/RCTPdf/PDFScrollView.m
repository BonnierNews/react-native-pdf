#import "PDFScrollView.h"
#import "TiledPDFView.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation PDFScrollView
{
    CGPDFPageRef _PDFPage;
}

@synthesize backgroundImageView=_backgroundImageView, tiledPDFView=_tiledPDFView, oldTiledPDFView=_oldTiledPDFView;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    if( self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

-(void)initialize {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.delegate = self;
    self.runningScale = 1;
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)setPDFPage:(CGPDFPageRef)PDFPage;
{
    if( PDFPage != NULL ) CGPDFPageRetain(PDFPage);
    if( _PDFPage != NULL ) CGPDFPageRelease(_PDFPage);
    _PDFPage = PDFPage;
    
    // PDFPage is null if we're requested to draw a padded blank page by the parent UIPageViewController
    if( PDFPage == NULL ) {
        self.pageRect = self.bounds;
    } else {
        self.pageRect = CGPDFPageGetBoxRect( _PDFPage, kCGPDFMediaBox );
        _PDFScale = self.frame.size.width/self.pageRect.size.width;
        self.pageRect = CGRectMake( self.pageRect.origin.x, self.pageRect.origin.y, self.pageRect.size.width*_PDFScale, self.pageRect.size.height*_PDFScale );
    }
    // Create the TiledPDFView based on the size of the PDF page and scale it to fit the view.
    [self replaceTiledPDFViewWithFrame:self.pageRect];
}

- (void)setMaxZoom:(CGFloat)maxZoom {
    _maxZoom = maxZoom;
    self.maximumZoomScale = maxZoom;
}

- (void)setMinZoom:(CGFloat)minZoom {
    _minZoom = minZoom;
    self.minimumZoomScale = minZoom;
}


- (void)dealloc
{
    // Clean up.
    if( _PDFPage != NULL ) CGPDFPageRelease(_PDFPage);
}


#pragma mark -
#pragma mark Override layoutSubviews to center content

// Use layoutSubviews to center the PDF page in the view.

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    //NSLog(@"%s bounds: %@",__PRETTY_FUNCTION__,NSStringFromCGRect(self.bounds));
    
    // Center the image as it becomes smaller than the size of the screen.
    
    CGSize boundsSize = self.bounds.size;
        
    CGRect frameToCenter = self.tiledPDFView.frame;
    
    // Center horizontally.
    
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // Center vertically.
    
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.tiledPDFView.frame = frameToCenter;
    self.backgroundImageView.frame = frameToCenter;
    
    /*
     To handle the interaction between CATiledLayer and high resolution screens, set the tiling view's contentScaleFactor to 1.0.
     If this step were omitted, the content scale factor would be 2.0 on high resolution screens, which would cause the CATiledLayer to ask for tiles of the wrong scale.
     */
    self.tiledPDFView.contentScaleFactor = 1.0;
}


#pragma mark -
#pragma mark Gesture recognizers
- (void) handleSingleTap: (UITapGestureRecognizer *)recognizer
{
    if (self.pdfDelegate != nil) {
        CGPoint touchPoint = [recognizer locationInView:self];
        CGPoint touchPointInPdf = [self.tiledPDFView convertPoint:touchPoint toView:recognizer.view];
        CGPoint relativeTouchPoint = CGPointMake(touchPointInPdf.x / [self.tiledPDFView frame].size.width, touchPointInPdf.y / [self.tiledPDFView frame].size.height);
        [self.pdfDelegate pdfScrollViewTap:touchPointInPdf relativeTouchPoint:relativeTouchPoint];
    }
}

- (void) handleDoubleTap: (UITapGestureRecognizer *)recognizer
{
    float newScale = [self zoomScale] * self.maxZoom;
    
    if (self.zoomScale > self.minimumZoomScale)
    {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
    else
    {
        CGRect zoomRect = [self zoomRectForScale:newScale
                                      withCenter:[recognizer locationInView:recognizer.view]];
        [self zoomToRect:zoomRect animated:YES];
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = [self.tiledPDFView frame].size.height / scale;
    zoomRect.size.width = [self.tiledPDFView frame].size.width  / scale;
    
    center = [self.tiledPDFView convertPoint:center fromView:self];
    
    zoomRect.origin.x = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}

#pragma mark -
#pragma mark UIScrollView delegate methods

/*
 A UIScrollView delegate callback, called when the user starts zooming.
 Return the current TiledPDFView.
 */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.allowZoom ? self.tiledPDFView : nil;
}

/*
 A UIScrollView delegate callback, called when the user begins zooming.
 When the user begins zooming, remove the old TiledPDFView and set the current TiledPDFView to be the old view so we can create a new TiledPDFView when the zooming ends.
 */
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    // Remove back tiled view.
    NSLog(@"%f", self.minimumZoomScale);
    NSLog(@"%f", self.maximumZoomScale);
    [self.oldTiledPDFView removeFromSuperview];
    
    // Set the current TiledPDFView to be the old view.
    self.oldTiledPDFView = self.tiledPDFView;
}


/*
 A UIScrollView delegate callback, called when the user stops zooming.
 When the user stops zooming, create a new TiledPDFView based on the new zoom level and draw it on top of the old TiledPDFView.
 */
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    // Set the new scale factor for the TiledPDFView.
    _PDFScale *= scale;
    self.runningScale *= scale;
    [self setMinimumZoomScale:self.minZoom / self.runningScale];
    [self setMaximumZoomScale:self.maxZoom / self.runningScale];

    // Create a new tiled PDF View at the new scale
    [self replaceTiledPDFViewWithFrame:self.oldTiledPDFView.frame];
    if (self.pdfDelegate != nil) {
        [self.pdfDelegate pdfScrollViewScaleChange:self.runningScale];
    }
}

-(void)replaceTiledPDFViewWithFrame:(CGRect)frame {
    // Create a new tiled PDF View at the new scale
    TiledPDFView *tiledPDFView = [[TiledPDFView alloc] initWithFrame:frame scale:_PDFScale];
    [tiledPDFView setPage:_PDFPage];
    // Add the new TiledPDFView to the PDFScrollView.
    [self addSubview:tiledPDFView];
    self.tiledPDFView = tiledPDFView;
}

@end
