
#import "NUWeakReference.h"

@implementation NUWeakReference

- (id) initWithObject:(id)object
{
    if ((self = [super init])) {
        ref = object;
    }
    return self;
}

+ (id) weakReferenceToObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

- (id) ref
{
    return ref;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"<WeakReference:%@>",ref];
}

@end
