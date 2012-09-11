
#import "NSArray+NUExtensions.h"

@implementation NSArray (NUExtensions)

// ----------------------------------------------------------------------------
   #pragma mark Properties
// ----------------------------------------------------------------------------

- (id) firstObject
{
    return (self.count == 0)? nil : [self objectAtIndex:0];
}


- (BOOL) isEmpty
{
    return (self.count == 0);
}


- (BOOL) isNotEmpty
{
    return (self.count > 0);
}


// ----------------------------------------------------------------------------
   #pragma mark Creating Arrays
// ----------------------------------------------------------------------------

+ (NSArray*) arrayWithDoubles:(NSUInteger)count,...
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    
    va_list ap;
    va_start(ap, count);
    
    for (NSUInteger i=0;  i<count;  i++)
        [array addObject:@(va_arg(ap, double))];
         
    va_end(ap);
    
    return array;
}

+ (NSArray*) arrayWithInts:(NSUInteger)count,...
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    
    va_list ap;
    va_start(ap, count);
    
    for (NSUInteger i=0;  i<count;  i++) {
        int value = va_arg(ap, int);
        [array addObject:@(value)];
    }
    
    va_end(ap);
    
    return array;
}



// ----------------------------------------------------------------------------
   #pragma mark Generating Arrays
// ----------------------------------------------------------------------------

- (NSArray*) arrayByRemovingObjectAtIndex:(NSUInteger) index
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];
    [array removeObjectAtIndex:index];
    return array;
}

- (NSArray*) arrayByRemovingObject:(id)object
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];
    [array removeObject:object];
    return array;
}


- (NSArray*) arrayByRemovingFirstObject
{
    return [self arrayByRemovingObjectAtIndex:0];
}


- (NSArray*) arrayByRemovingLastObject
{
    return [self arrayByRemovingObjectAtIndex:self.count-1];
}


- (NSArray*) arrayInReverseOrder
{
    return [self reverseObjectEnumerator].allObjects;
}


- (NSArray*) objectsAtIndexesInArray:(NSArray*)indexes
{
    return [indexes map:^(id index) { return [self objectAtIndex:[index unsignedLongLongValue]]; }];
}


+ (NSArray*) arrayWithUniformDistributionFromValue:(double)startValue 
                                           toValue:(double)endValue 
                                             count:(NSUInteger)count
{
    // If count == 0 returns an empty array.
    NSMutableArray *values = [NSMutableArray array];

    if (count >= 1) {

        double dx = endValue - startValue;
        double x  = startValue;
        
        if (count >= 2)
            dx /= (count - 1);

        /*
           If count == 1 array will contain startValue only.
           If count == 2 array will contain startValue and endValue.
           For any other value of count intermediate values are generated.
        */
        for (NSUInteger i=0;  i<count;  i++) {
            [values addObject:@(x)];
            x += dx;
        }
    }
    
    return values;
}



// ----------------------------------------------------------------------------
   #pragma mark Mapping Methods
// ----------------------------------------------------------------------------

- (NSArray*) map:(id(^)(id object)) aBlock
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: self.count];
    NSNull *null = [NSNull null];
    id value;
    
    for (id object in self) {
        [result addObject:(value = aBlock(object))? value : null];
    }
    
    return result;
}


- (NSArray*) mapWithIndex:(id(^)(id object, NSUInteger index)) aBlock 
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: self.count];
    NSNull *null = [NSNull null];
    NSUInteger index = 0;
    id value;
    
    for (id object in self) {
        [result addObject:(value = aBlock(object, index++))? value : null];
    }
    
    return result;
}


- (NSArray*) mapKeyPath:(NSString*)aKeyPath
{
    return [self map:^(id object) {
        return [object valueForKeyPath:aKeyPath];
    }];
}


- (NSArray*) mapSelector:(SEL)aSelector;
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: self.count];
    NSNull *null = [NSNull null];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    for (id object in self) {
        id value = [object performSelector:aSelector];
        [result addObject:value ? value : null];
    }
    
#pragma clang diagnostic pop
    
    return result;
}



// ----------------------------------------------------------------------------
   #pragma mark Filtering Methods
// ----------------------------------------------------------------------------

- (NSArray*) filter:(BOOL(^)(id object)) aBlock
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: self.count];
    for (id object in self) {
        if (aBlock(object))
            [result addObject:object];
    }
    return result;
}


- (NSArray*) filterWithIndex:(BOOL(^)(id object, NSUInteger index)) aBlock
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: self.count];
    NSUInteger index = 0;
    
    for (id object in self) {
        if (aBlock(object, index++))
            [result addObject:object];
    }
    return result;
}


- (id) findFirst:(BOOL(^)(id object)) aBlock
{
    for (id object in self) {
        if (aBlock(object))
            return object;
    }
    return nil;
}


- (id) findFirstWithIndex:(BOOL(^)(id object, NSUInteger index)) aBlock
{
    NSUInteger index = 0;
    for (id object in self) {
        if (aBlock(object, index++))
            return object;
    }
    return nil;
}


// ----------------------------------------------------------------------------
   #pragma mark Sorting Methods
// ----------------------------------------------------------------------------

- (NSArray*) sortedArrayByKeyPaths:(NSString*)keyPath,...
{
    va_list ap;
    va_start(ap, keyPath);
    
    NSMutableArray *keyPaths = [NSMutableArray array];
    NSArray *sortedArray = self;
    
    while (keyPath) {
        [keyPaths addObject:keyPath];
        keyPath = va_arg(ap, NSString*);
    }
    
    va_end(ap);
    
    for (keyPath in keyPaths.reverseObjectEnumerator) {
        sortedArray = [sortedArray sortedArrayUsingComparator:^(id o1, id o2) {
            return [[o1 valueForKeyPath:keyPath] compare:[o2 valueForKeyPath:keyPath]];  }];
    }
    
    return sortedArray;    
}


// ----------------------------------------------------------------------------
   #pragma mark Miscellaneous Methods
// ----------------------------------------------------------------------------

- (NSIndexSet*) indexSetForObjectsInArray:(NSArray*)values
{
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    
    [values enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
         NSUInteger i = [self indexOfObject:object];
         if (i != NSNotFound)
             [indexes addIndex:i];
     }];
    
    return indexes;
}

@end
