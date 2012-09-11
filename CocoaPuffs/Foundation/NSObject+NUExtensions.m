
#import <objc/runtime.h>
#import "NSObject+NUExtensions.h"
#import "NSArray+NUExtensions.h"
#import "CATransaction+NoAnimation.h"

@interface NUObservedValue : NSObject
@property (retain) id value;
@property (copy) void(^deallocBlock)(id myself);
@end

@implementation NUObservedValue 
@synthesize value, deallocBlock;

- (void) dealloc
{
    if (deallocBlock)
        deallocBlock(self);
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    self.value = [object valueForKeyPath:keyPath];
}
@end


@implementation NSObject (NUExtensions)

- (void) getRootModelObject:(id*)rootObject 
                 andKeyPath:(NSString**)rootKeyPath
                  forObject:(id)object
                 andKeyPath:(NSString*)keyPath
{
    NSArray *chain = [keyPath componentsSeparatedByString:@"."];
    
    id endOfPathObject = object;
    id endOfPathKey = keyPath;
    
    if (chain.count > 1) {
        endOfPathObject = [object valueForKeyPath:[[chain arrayByRemovingLastObject] componentsJoinedByString:@"."]];
        endOfPathKey = chain.lastObject;
    }
    
    NSDictionary *info = [endOfPathObject infoForBinding:endOfPathKey];
    
    if (info == nil) {
        *rootObject  = object;
        *rootKeyPath = keyPath;
    } else {
        [self getRootModelObject:rootObject 
                      andKeyPath:rootKeyPath 
                       forObject:[info objectForKey:NSObservedObjectKey] 
                      andKeyPath:[info objectForKey:NSObservedKeyPathKey]];
    }
}



- (void) setValue:(id)value forPotentiallyBoundKeyPath:(NSString*)keyPath
{
    id rootObject  = nil;
    id rootKeyPath = nil;
    
    [self getRootModelObject:&rootObject andKeyPath:&rootKeyPath forObject:self andKeyPath:keyPath];
    [rootObject setValue:value forKeyPath:rootKeyPath];
}

- (void) bind:(NSString *)binding toArray:(NSArray*)array atIndex:(NSUInteger)index withKeyPath:(NSString*)keyPath options:(NSDictionary *)options
{
    // Lets create an observed value
    NUObservedValue *observedValue = [[NUObservedValue alloc] init];
    observedValue.deallocBlock = ^(id myself) {
        [array removeObserver:myself fromObjectsAtIndexes:[NSIndexSet indexSetWithIndex:index] forKeyPath:keyPath];
    };
    
    // Let our observed-value observe the array for the specified index
    [array addObserver:observedValue 
    toObjectsAtIndexes:[NSIndexSet indexSetWithIndex:index] 
            forKeyPath:keyPath 
               options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial 
               context:NULL];
    
    // Then we bind to the observed value
    // The binding will retain our observedValue, which will be realeased when unbind is called.
    [self bind:binding toObject:observedValue withKeyPath:@"value" options:options];
}

- (void) setUndoValue:(id)undoValue
            redoValue:(id)redoValue
           forKeyPath:(NSString *)keyPath
      withUndoManager:(NSUndoManager*)undoManager
        andActionName:(NSString*)actionName
    disableAnimations:(BOOL)shouldDisableAnimations
       skipAssignment:(BOOL)shouldSkipAssign
{
    if (! shouldSkipAssign) {
        [CATransaction begin];
        [CATransaction setDisableActions:shouldDisableAnimations];
        
        [self setValue:redoValue forPotentiallyBoundKeyPath:keyPath];
        
        [CATransaction commit];
    }
    
    [[undoManager prepareWithInvocationTarget:self]
              setUndoValue:redoValue
                 redoValue:undoValue
                forKeyPath:keyPath
           withUndoManager:undoManager
             andActionName:actionName
         disableAnimations:shouldDisableAnimations
            skipAssignment:NO];
    
    [undoManager setActionName:actionName];
}




- (void) willChangeValueForKeys:(NSString*)key,...
{
    va_list ap;
    va_start(ap, key);
    
    while (key) {
        [self willChangeValueForKey:key];
        key = va_arg(ap, NSString*);
    }
    
    va_end(ap);
}

- (void) didChangeValueForKeys:(NSString*)key,...
{
    NSMutableArray *keys = [NSMutableArray array];
    
    va_list ap;
    va_start(ap, key);
    
    while (key) {
        [keys addObject:key];
        key = va_arg(ap, NSString*);
    }

    va_end(ap);
    
    for (NSString *key in keys.reverseObjectEnumerator)
        [self didChangeValueForKey:key];
}

- (id) deepCopyIfPossible
{
    if ([self conformsToProtocol:@protocol(NSCoding)])
        return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    else if ([self conformsToProtocol:@protocol(NSCopying)])
        return [self copy]; // COV_NF_LINE
    
    return self;
}

- (NSString*) methodListDescrption
{
    Class aClass = self.class;
    
    NSMutableString *description = [NSMutableString stringWithFormat:@"Object is of class %@\n", NSStringFromClass(aClass)];
    
    while (aClass && (aClass != [NSObject class])) {
        
        unsigned int  count = 0;
        Method     *methods = class_copyMethodList(aClass, &count);
        
        [description appendFormat:@"\tMethods for %@\n", NSStringFromClass(aClass)];
        for(unsigned int i=0;  i<count;  i++)
            [description appendFormat:@"#%6d. %s\n", i, sel_getName(method_getName(methods[i]))];
        
        free(methods);
        
        aClass = class_getSuperclass(aClass);
    }
    
    return description;
}


@end
