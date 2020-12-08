#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StyleManager: NSProxy

+ (void)invokeMethods:(__kindof UIView *)target NS_REFINED_FOR_SWIFT;
+ (instancetype)shared:(Class)aClass NS_REFINED_FOR_SWIFT;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
