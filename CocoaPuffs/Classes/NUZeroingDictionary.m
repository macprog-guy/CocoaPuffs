
#import "NUZeroingDictionary.h"
#import "NUWeakReference.h"


static NUZeroingDictionary *gSharedZeroingDict = nil;

@interface NUZeroingDictionary() {

    dispatch_source_t timer;
    dispatch_queue_t  queue;
    
    float timerInterval;
    
    NSMutableDictionary *dict;
}

@end




@implementation NUZeroingDictionary // COV_NF_LINE

// -----------------------------------------------------------------------------
   #pragma mark Init
// -----------------------------------------------------------------------------

- (id) initWithCapacity:(NSUInteger)NUmItems
{
    if ((self = [super init])) {
        dict  = [NSMutableDictionary dictionaryWithCapacity:NUmItems];
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        self.timerInterval = 1.0;
    }
    return self;
}

// COV_NF_START
- (void) dealloc
{
    // Has the side-effect of releasing the timer object.
    self.timerInterval = 0.0;
}
// COV_NF_END

// -----------------------------------------------------------------------------
   #pragma mark Properties
// -----------------------------------------------------------------------------

- (float) timerInterval
{
    return timerInterval;
}

- (void) setTimerInterval:(float)value
{
    if (value != timerInterval) {
        
        if (timer) {
            dispatch_source_cancel(timer);
            timer = NULL;
        }
        
        if (value >= 0.01) {
            timerInterval = value;
            timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue); 
            dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), timerInterval * 1e9, timerInterval * 1e8);
            dispatch_source_set_event_handler(timer, ^(void) {
                [self removeDeadReferences:self];
            });
            dispatch_resume(timer);
        }
    }
}

// -----------------------------------------------------------------------------
   #pragma mark Helpers
// -----------------------------------------------------------------------------

- (void) removeDeadReferences:(id)sender
{
    @synchronized(dict) {
        for (id key in self.keyEnumerator) {
            id object = [self objectForKey:key]; 
            if (object == nil) {
                [self removeObjectForKey:key];
            }
        }
    }
}

- (NSUInteger) count
{
    @synchronized(dict) {
        return dict.count;
    }
}

- (id) objectForKey:(id)aKey
{
    @synchronized(dict) {
        id value = [dict objectForKey:aKey];
        if ([value isKindOfClass:[NUWeakReference class]])
            value = [value ref];
        return value;
    }
}

- (void) setObject:(id)anObject forKey:(id)aKey
{
    [self setObject:anObject forKey:aKey weakReference:YES];
}

- (void) setObject:(id)anObject forKey:(id<NSCopying>)aKey weakReference:(BOOL)isWeak
{
    id storedObject = isWeak? [NUWeakReference weakReferenceToObject:anObject] : anObject;
    @synchronized(dict) {
        [dict setObject:storedObject forKey:aKey];
    }
}


- (void) removeObjectForKey:(id)aKey
{
    @synchronized(dict) {
        [dict removeObjectForKey:aKey];
    }
}

- (NSEnumerator*) keyEnumerator
{
    @synchronized(dict) {
        return dict.allKeys.objectEnumerator;
    }
}

- (NSArray*) allValues
{
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:self.count];
    for (id key in self.keyEnumerator) {
        id value = [self objectForKey:key];
        if (value)
            [values addObject:value];
    }
    return values;
}

+ (NUZeroingDictionary*) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gSharedZeroingDict = [NUZeroingDictionary dictionary];
    });
    
    return gSharedZeroingDict;
}

@end
