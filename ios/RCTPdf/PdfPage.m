//
//  PdfPage.m
//  RCTPdf
//
//  Created by Johan Kasperi (DN) on 2018-01-16.
//  Copyright © 2018 wonday.org. All rights reserved.
//

#import "PdfPage.h"
#import "PdfManager.h"

@implementation PdfPage

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        [self setTransform:CGAffineTransformMakeScale(4.0, 4.0)];
//    }
//
//    return self;
//}
//
//-(void) setFrame:(CGRect)frame {
//    CGRect scaledFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width * 4, frame.size.height * 4);
//    [super setFrame:scaledFrame];
//}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // PDF page drawing expects a Lower-Left coordinate system, so we flip the coordinate system before drawing.
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGPDFDocumentRef pdfRef= [PdfManager getPdf:_fileNo];
    if (pdfRef!=NULL)
    {
        
        CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdfRef, _page);
        
        if (pdfPage != NULL) {
            
            CGContextSaveGState(context);
            CGRect pageBounds = CGRectMake(0,
                                    -self.bounds.size.height,
                                    self.bounds.size.width,
                                    self.bounds.size.height);
            
            // Fill the background with white.
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
            CGContextFillRect(context, pageBounds);
            
            CGAffineTransform pageTransform = CGPDFPageGetDrawingTransform(pdfPage, kCGPDFCropBox, pageBounds, 0, true);
            CGContextConcatCTM(context, pageTransform);
            
            CGContextDrawPDFPage(context, pdfPage);
            CGContextRestoreGState(context);
            
        }
        
    }
}

@end
