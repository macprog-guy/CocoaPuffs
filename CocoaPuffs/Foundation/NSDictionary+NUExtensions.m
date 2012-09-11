
#import "NSDictionary+NUExtensions.h"

@implementation NSDictionary (NUExtensions)

- (BOOL) hasKey:(NSString*)aKey
{
    return ([self objectForKey:aKey] != nil);
}

@end
