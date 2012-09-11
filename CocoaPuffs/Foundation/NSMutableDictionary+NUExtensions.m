
#import "NSMutableDictionary+NUExtensions.h"

@implementation NSMutableDictionary (LazyEvaluation)

- (id) objectForKey:(NSString*)key computeIfNil:(id(^)(void))block
{
    id value = [self objectForKey:key];
    
    if (value==nil  &&  block!=nil) {
        if ((value = block()))
            [self setObject:value forKey:key];
    }
    
    return value;
}

@end
