//
//  UIScrollView+ScrollerAdditions.m
//
//  Created by Stefan Ceriu on 14/06/2013.
//  Copyright (c) 2013 Stefan Ceriu. All rights reserved.
//

#import "UIScrollView+ScrollerAdditions.h"
#import <objc/runtime.h>

static NSString * const kKeyScrollViewVerticalIndicatorAlpha = @"_verticalScrollIndicator.alpha";
static NSString * const kKeyScrollViewHorizontalIndicatorAlpha = @"_horizontalScrollIndicator.alpha";

static NSString * const kKeyScrollViewVerticalIndicator = @"_verticalScrollIndicator";
static NSString * const kKeyScrollViewHorizontalIndicator = @"_horizontalScrollIndicator";

@implementation UIScrollView (ScrollerAdditions)
@dynamic horizontalScroller;
@dynamic verticalScroller;

#pragma mark - Cleanup

+ (void)load
{
    SwizzleInstanceMethod(self, @selector(removeFromSuperview), @selector(customRemoveFromSuperview));
}

- (void)customRemoveFromSuperview
{
    @try {
        [self removeObserver:self forKeyPath:kKeyScrollViewVerticalIndicatorAlpha];
        [self removeObserver:self forKeyPath:kKeyScrollViewHorizontalIndicatorAlpha];
    }
    @catch (id exception) {

    }
    
    [self customRemoveFromSuperview];
}

#pragma mark - Public

- (void)setAlwaysShowScrollIndicators:(BOOL)alwaysVisible
{
    if(alwaysVisible) {
        [self addObserver:self forKeyPath:kKeyScrollViewVerticalIndicatorAlpha options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:kKeyScrollViewHorizontalIndicatorAlpha options:NSKeyValueObservingOptionNew context:NULL];
        
        if([self respondsToSelector:@selector(_adjustScrollerIndicators:alwaysShowingThem:)]) {
            [self performSelector:@selector(_adjustScrollerIndicators:alwaysShowingThem:) withObject:@(YES) withObject:@(YES)];
        }
    } else {
        [self removeObserver:self forKeyPath:kKeyScrollViewVerticalIndicatorAlpha];
        [self removeObserver:self forKeyPath:kKeyScrollViewHorizontalIndicatorAlpha];
    
        [self.verticalScroller setAlpha:0.0f];
        [self.horizontalScroller setAlpha:0.0f];
    }
}

- (void)setVerticalScrollerTintColor:(UIColor*)color
{
    [self.verticalScroller setImage:[[self tintImage:self.verticalScroller.image withColor:color] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 1, 3, 1)]];
}

- (void)setHorizontalScrollerTintColor:(UIColor*)color
{
    [self.horizontalScroller setImage:[[self tintImage:self.horizontalScroller.image withColor:color] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 3, 1, 3)]];
}

#pragma mark - Observing changes

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:kKeyScrollViewVerticalIndicatorAlpha] || [keyPath isEqualToString:kKeyScrollViewHorizontalIndicatorAlpha]) {
        if([[change objectForKey:NSKeyValueChangeNewKey] intValue] == 0) {
            [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                if(self.contentSize.height > self.frame.size.height)
                    [self.verticalScroller setAlpha:1.0f];
                
                if(self.contentSize.width > self.frame.size.width)
                    [self.horizontalScroller setAlpha:1.0f];
            } completion:nil];
        }
    }
}

#pragma mark - Properties

- (UIImageView*)verticalScroller
{
    if(objc_getAssociatedObject(self, _cmd) == nil) {
        objc_setAssociatedObject(self, _cmd, [self safeValueForKey:kKeyScrollViewVerticalIndicator], OBJC_ASSOCIATION_ASSIGN);
    }
    
    return objc_getAssociatedObject(self, _cmd);
}

- (UIImageView*)horizontalScroller
{
    if(objc_getAssociatedObject(self, _cmd) == nil) {
        objc_setAssociatedObject(self, _cmd, [self safeValueForKey:kKeyScrollViewHorizontalIndicator], OBJC_ASSOCIATION_ASSIGN);
    }
    
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Others

- (UIImage *)tintImage:(UIImage*)image withColor:(UIColor *)color
{
    if(image == nil || color == nil) {
        return nil;
    }

    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    UIGraphicsBeginImageContext([image size]);
    
    [color set];
    UIRectFill(rect);
    
    [image drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (id)safeValueForKey:(NSString*)key
{
    Ivar instanceVariable = class_getInstanceVariable([self class], [key cStringUsingEncoding:NSUTF8StringEncoding]);
    return object_getIvar(self, instanceVariable);
}

void SwizzleInstanceMethod(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
		method_exchangeImplementations(origMethod, newMethod);
}

@end
