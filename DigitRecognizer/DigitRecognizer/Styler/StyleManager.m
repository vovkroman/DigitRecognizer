#import "StyleManager.h"
#import "Defines.h"

@interface StyleManager()

@property(nonatomic, assign) Class _aClass;
@property(nonatomic, strong) NSMutableDictionary *_invocations;

@end

@implementation StyleManager

- (instancetype)init {
    self._invocations = [NSMutableDictionary dictionary];
    return self;
}

static StyleManager *proxy = nil;
+ (instancetype)shared:(Class)aClass {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        proxy = [[self alloc] init];
    });
    proxy._aClass = aClass;
    return proxy;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    let key = NSStringFromClass(self._aClass);
    self._invocations[key] = invocation;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [self._aClass instanceMethodSignatureForSelector:selector];
}

+ (void)invokeMethods:(__kindof UIView *)target {
    let key = NSStringFromClass([target class]);
    let invocation = [proxy._invocations objectForKey:key];
    if (invocation) {
        [invocation invokeWithTarget:target];
    }
}

@end
