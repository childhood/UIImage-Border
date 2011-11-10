//
//  UIImage+Border.m
//
//  Created by Levey on 11/10/11.
//  Copyright (c) 2011 Vanillatech. All rights reserved.
//

#import "UIImage+Border.h"

static CGImageRef CreateMask(CGSize size, NSUInteger thickness)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                       size.width,
                                                       size.height,
                                                       8,
                                                       size.width * 32,
                                                       colorSpace,
                                                       kCGBitmapByteOrderDefault | kCGImageAlphaNone);
    if (bitmapContext == NULL) 
    {
        NSLog(@"create mask bitmap context failed");
		return nil;
    }
    
    // fill the black color in whole size, anything in black area will be transparent.
    CGContextSetFillColorWithColor(bitmapContext, [UIColor blackColor].CGColor);
    CGContextFillRect(bitmapContext, CGRectMake(0, 0, size.width, size.height));
    
    // fill the white color in whole size, anything in white area will keep.
    CGContextSetFillColorWithColor(bitmapContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(bitmapContext, CGRectMake(thickness, thickness, size.width - thickness * 2, size.height - thickness * 2));
    
    // acquire the mask
    CGImageRef maskImageRef = CGBitmapContextCreateImage(bitmapContext);
    
    // clean up
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    
    return maskImageRef;
}


@implementation UIImage(Border)

- (UIImage *)imageWithColoredBorder:(NSUInteger)thickness borderColor:(UIColor *)color
{
    size_t newWidth = self.size.width + 2 * thickness;
    size_t newHeight = self.size.height + 2 * thickness;
    
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = bitsPerPixel * newWidth;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();    
    if(colorSpace == NULL) 
    {
		NSLog(@"create color space failed");
		return nil;
	}
    
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                       newWidth,
                                                       newHeight,
                                                       bitsPerComponent,
                                                       bytesPerRow,
                                                       colorSpace,
                                                       kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
    if (bitmapContext == NULL) 
    {
        NSLog(@"create bitmap Context failed");
		return nil;
    }
    // acquire image with uncolored border
    CGRect imageRect = CGRectMake(thickness, thickness, self.size.width, self.size.height);
    CGContextDrawImage(bitmapContext, imageRect, self.CGImage);
    CGImageRef unColoredBorderImageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage *unColoredBorderImage = [UIImage imageWithCGImage:unColoredBorderImageRef];
    
    // clean up
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(bitmapContext);
    CGImageRelease(unColoredBorderImageRef);
    
    
    UIImageView *imgv = [[[UIImageView alloc] initWithImage:unColoredBorderImage] autorelease];
    imgv.frame = CGRectMake(0, 0, newWidth, newHeight);
    imgv.layer.borderColor = color.CGColor;
    imgv.layer.borderWidth = thickness;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [imgv.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    return img;
}

- (UIImage *)imageWithTransparentBorder:(NSUInteger)thickness
{      
    size_t newWidth = self.size.width + 2 * thickness;
    size_t newHeight = self.size.height + 2 * thickness;
    
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = bitsPerPixel * newWidth;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();    
    if(colorSpace == NULL) 
    {
		NSLog(@"create color space failed");
		return nil;
	}
    
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                newWidth,
                                                newHeight,
                                                bitsPerComponent,
                                                bytesPerRow,
                                                colorSpace,
                                                kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
    if (bitmapContext == NULL) 
    {
        NSLog(@"create bitmap context failed");
		return nil;
    }
        
    // acquire image with opaque border 
    CGRect imageRect = CGRectMake(thickness, thickness, self.size.width, self.size.height);
    CGContextDrawImage(bitmapContext, imageRect, self.CGImage);
    CGImageRef opaqueBorderImageRef = CGBitmapContextCreateImage(bitmapContext);
    
    // acquire image with transparent border 
    CGImageRef maskImageRef = CreateMask(CGSizeMake(newWidth, newHeight), thickness);
    CGImageRef transparentBorderImageRef = CGImageCreateWithMask(opaqueBorderImageRef, maskImageRef);
    UIImage *transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef];
    
    // clean up
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(bitmapContext);
    CGImageRelease(opaqueBorderImageRef);
    CGImageRelease(maskImageRef);
    CGImageRelease(transparentBorderImageRef);
    
    return transparentBorderImage;
}


@end
