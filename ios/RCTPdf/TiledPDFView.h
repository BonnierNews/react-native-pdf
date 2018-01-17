#import <UIKit/UIKit.h>

@interface TiledPDFView : UIView

@property CGPDFPageRef pdfPage;
@property CGFloat myScale;

- (id)initWithFrame:(CGRect)frame scale:(CGFloat)scale;
- (void)setPage:(CGPDFPageRef)newPage;

@end
