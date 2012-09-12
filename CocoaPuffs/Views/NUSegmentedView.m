
#import "NUSegmentedView.h"
#import <CocoaPuffs/CocoaPuffs.h>

// -----------------------------------------------------------------------------
   #pragma mark - NUSegmentInfo
// -----------------------------------------------------------------------------

@implementation NUSegmentInfo

- (id) initWithObject:(id)anObject
{
    if ((self = [super init])) {
        
        _active = NO;
        _pushed = NO;
        _selected = NO;
        _selectable = YES;
        _enabled = YES;
        _representedObject = anObject;
        
        if ([anObject respondsToSelector:@selector(name)])
            _name = [[anObject name] copy];
        else if ([anObject isKindOfClass:[NSDictionary class]] && [anObject hasKey:@"name"])
            _name = [anObject valueForKey:@"name"];
        
        if ([anObject respondsToSelector:@selector(image)])
            _image = [anObject image];
        else if ([anObject isKindOfClass:[NSDictionary class]] && [anObject hasKey:@"image"])
            _image = [anObject valueForKey:@"image"];
        
        if ([anObject respondsToSelector:@selector(label)])
            _label = [[anObject label] copy];
        else if ([anObject isKindOfClass:[NSDictionary class]] && [anObject hasKey:@"label"])
            _label = [anObject valueForKey:@"label"];
    }
    return self;
}

+ (id) segmentWithObject:(id)anObject
{
    return [[self alloc] initWithObject:anObject];
}

- (id) init
{
    return [self initWithObject:nil];
}

+ (id) segment
{
    return [[self alloc] init];
}

- (id) valueForUndefinedKey:(NSString *)key
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

    if ([_representedObject respondsToSelector:NSSelectorFromString(key)])
        return [_representedObject performSelector:NSSelectorFromString(key)];
    else if ([_representedObject isKindOfClass:[NSDictionary class]] && [_representedObject hasKey:key])
        return [_representedObject valueForKey:key];

#pragma clang diagnostic pop
    
    return [super valueForUndefinedKey:key]; // COV_NF_LINE ?
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"<%p:%@ %@, %@,%@,%@,%@,object=%p>",
            self, 
            NSStringFromClass(self.class),
            _name,
            _pushed? @"pushed":@"not-pushed",
            _selected? @"selected":@"not-selected",
            _selectable? @"selectable":@"not-selectable",
            _enabled? @"enabled":@"disabled",
            _representedObject
            ];
}

@end

// -----------------------------------------------------------------------------
   #pragma mark - NUSegmentedView
// -----------------------------------------------------------------------------

@interface NUSegmentedView() {
    
    NSUInteger  _mouseDownSegment;
    NSInteger  *_trackers;
    NSIndexSet *_selectionIndexes;
    double      _segmentWidth;
    CGRect      _initialFrame;
    
    struct {
        uint8_t mouseDownAction:1;
        uint8_t mutationInProgress:1;
    } _flags;
}
- (void) startObservingSegments;
- (void) stopObservingSegments;
- (void) removeTrackingRects;
- (void) setupTrackingRects;
- (void) updateRects;

- (void) getSegmentIndex:(NSUInteger*)segmentIndex 
               andAction:(BOOL*)usedAction 
           forMouseEvent:(NSEvent*)theEvent
;

- (NUSegmentInfo*) segmentForTrackingTag:(NSInteger)tag;

@end


@implementation NUSegmentedView

// -----------------------------------------------------------------------------
   #pragma mark Init
// -----------------------------------------------------------------------------

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _allowsMultipleSelection  = NO;
        _segments = @[];
        _alignment = NSCenterTextAlignment;
        _selectionIndexes = [NSIndexSet indexSet];
        _flags.mutationInProgress = NO;
        _flags.mouseDownAction = NO;
        _initialFrame = frame;
    }
    
    return self;
}


- (void) dealloc
{
    [self stopObservingSegments];
    
    if (_selectRects)
        free(_selectRects);
    
    if (_actionRects)
        free(_actionRects);
    
    if (_trackers)
        free(_trackers);
}


// -----------------------------------------------------------------------------
   #pragma mark Properties
// -----------------------------------------------------------------------------

- (void) setSegments:(NSArray *)values
{
    [self stopObservingSegments];
    [self removeTrackingRects];
    
    _segments = [values copy];
    
    const NSUInteger count = _segments.count;
    _selectRects = realloc(_selectRects, count * sizeof(CGRect));
    _actionRects = realloc(_actionRects, count * sizeof(CGRect));
    _imageRects  = realloc(_imageRects,  count * sizeof(CGRect));
    _textRects   = realloc(_textRects,   count * sizeof(CGRect));
    _badgeRects  = realloc(_badgeRects,  count * sizeof(CGRect));
    _trackers    = realloc(_trackers,    count * sizeof(NSInteger));

    [self setupTrackingRects];
    [self updateSegmentRects];
    [self startObservingSegments];
    
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    uint64_t index=0;
    
    for (NUSegmentInfo *segment in _segments) {
        if (segment.selected)
            [indexes addIndex:index];
        index++;
    }

    [self setValue:indexes forPotentiallyBoundKeyPath:@"selectionIndexes"];
    [self setNeedsDisplay:YES];
}

- (NSUInteger) selectionIndex
{
    return _selectionIndexes.firstIndex;
}

- (void) setSelectionIndex:(NSUInteger)index
{
    NSIndexSet *indexes = (index != NSNotFound)? [NSIndexSet indexSetWithIndex:index] : [NSIndexSet indexSet];
    [self setValue:indexes forPotentiallyBoundKeyPath:@"selectionIndexes"];
}

- (id) selectedObject
{
    NSUInteger index = self.selectionIndex;
    return (index != NSNotFound)? [_segments objectAtIndex:self.selectionIndex] : nil;
}

- (void) setSelectedObject:(id)value
{
    NSUInteger    index = [_segments indexOfObject:value];
    NSIndexSet *indexes = (value && index != NSNotFound)? [NSIndexSet indexSetWithIndex:index] : [NSIndexSet indexSet];
    [self setValue:indexes forPotentiallyBoundKeyPath:@"selectionIndexes"];
}

- (void) setSelectionIndexes:(NSIndexSet *)indexes
{
    if (_flags.mutationInProgress == NO) {
        
        _flags.mutationInProgress = YES;

        NSMutableIndexSet *finalSet = [NSMutableIndexSet indexSet];
        
        if (_allowsMultipleSelection == NO && indexes.count > 1)
            indexes = [NSIndexSet indexSetWithIndex:indexes.firstIndex];
        
        NSUInteger index=0;
        for (NUSegmentInfo *segment in _segments) {
            
            BOOL shouldBeSelected = [indexes containsIndex:index];
            BOOL segmentSelected  = segment.selected;
            
            if (shouldBeSelected)
                [finalSet addIndex:index];
            
            if (segmentSelected != shouldBeSelected) {
                
                // We set it this way just in case selected is bound to something.
                [(id)segment setValue:@(shouldBeSelected) forPotentiallyBoundKeyPath:@"selected"];
                
                if (segment.selectAction)
                    segment.selectAction(segment);
            }
            
            index++;
        }
        
        [self setValue:finalSet forPotentiallyBoundKeyPath:@"selectionIndexes"];
        _selectionIndexes = finalSet;
        
        [self updateRects];
        [self setNeedsDisplay:YES];
        
        _flags.mutationInProgress = NO;
    }
}

- (NSArray*) selectedObjects
{
    return [_segments objectsAtIndexes:_selectionIndexes];
}

- (void) setSelectedObjects:(NSArray *)values
{
    [self setValue:[_segments indexSetForObjectsInArray:values] forPotentiallyBoundKeyPath:@"selectionIndexes"];
}

- (BOOL) supportsMultipleSelection
{
    return YES;
}

- (BOOL) supportsEmptySelection
{
    return NO;
}

- (void) setAlignment:(int)value
{
    _alignment = value;
    [self updateRects];
}

- (double) segmentWidth
{
    return _segmentWidth;
}

- (void) setSegmentWidth:(double)value
{
    _segmentWidth = value;
    [self updateRects];
}


// -----------------------------------------------------------------------------
   #pragma mark Helpers
// -----------------------------------------------------------------------------

- (void) mutateSelectionIndexesAtIndex:(NSUInteger)index
{
    if (_flags.mutationInProgress == NO) {
        
        NSIndexSet *selection = nil;
        
        if (_allowsMultipleSelection && self.supportsMultipleSelection) {
            
            if ([_selectionIndexes containsIndex:index])
                selection = [_selectionIndexes indexSetByRemovingIndex:index]; // COV_NF_LINE ??
            else
                selection = [_selectionIndexes indexSetByAddingIndex:index];
            
        } else {
            selection = [NSIndexSet indexSetWithIndex:index];
        }
        
        // In case selectionIndexes is a bound value...
        //
        // TODO: this doesn't work if selectionIndex is the bound value.
        //       find an elegant way to work around this.
        //
        [self setValue:selection forPotentiallyBoundKeyPath:@"selectionIndexes"];
    }
}

- (void) removeTrackingRects
{
    for (NSUInteger i=0, count=_segments.count;  i<count;  i++) {
        if (_trackers[i] != NSNotFound)
            [self removeTrackingRect:_trackers[i]];
    }
}

- (void) setupTrackingRects
{
    for (NSUInteger i=0, count=_segments.count;  i<count;  i++)
        _trackers[i] = [self addTrackingRect:_selectRects[i] owner:self userData:NULL assumeInside:NO];
}


- (void) updateSegmentRects
{
    const uint64_t count = _segments.count;
    
    CGRect originalFrame = self.frame;
    CGRect frame  = originalFrame;
    
    // Determine the rect in which all the selectRects will reside.
    if (_alignment != NSJustifiedTextAlignment) {
        
        if (_segmentWidth > 0.0)
            frame.size.width = _segmentWidth * count;
        else
            frame.size.width = fmin(floor(frame.size.height * 1.618 * count), _initialFrame.size.width);
        
        if (_alignment == NSRightTextAlignment)
            frame.origin.x += (originalFrame.size.width - frame.size.width);
        else if (_alignment == NSCenterTextAlignment)
            frame.origin.x += (originalFrame.size.width - frame.size.width)/2.0;
    }
    
    // Determine the size of one rect
    CGRect bounds = CGRectWithOriginAndSize(CGPointZero, frame.size);
    CGRect rect   = bounds;
    rect.size.width /= count;
    
    for (NSUInteger i=0;  i<count;  i++) {
        
        _selectRects[i] = rect;
        _actionRects[i] = CGRectNull;
        _badgeRects[i] = CGRectNull;
        
        if (_alignment == NSJustifiedTextAlignment) {
            CGRectDivide(_selectRects[i], &_imageRects[i], &_textRects[i], _selectRects[i].size.height, NSMinXEdge);
            CGRectDivide(_textRects[i], &_actionRects[i], &_textRects[i], _selectRects[i].size.height, NSMaxXEdge);
        } else {
            _imageRects[i] = _selectRects[i];
            _textRects[i] = _selectRects[i];
        }
        
        rect.origin.x += rect.size.width;
    }
    
    if (! CGRectEqualToRect(originalFrame, frame)) {
        self.frame  = frame;
        self.bounds = bounds;
    }
}

- (void) updateRects
{
    [self removeTrackingRects];
    [self updateSegmentRects];
    [self setupTrackingRects];
}


- (CGRect) selectionRectAtIndex:(NSInteger)index
{
    if (index < _segments.count && _selectRects)
        return _selectRects[index];
    
    return CGRectNull;
}

- (CGRect) actionRectAtIndex:(NSInteger)index
{
    if (index < _segments.count && _actionRects)
        return _actionRects[index];
    
    return CGRectNull;
}

- (void) viewDidMoveToSuperview
{
    [super viewDidMoveToSuperview];
    [self updateRects];
}


// COV_NF_START

- (void) getSegmentIndex:(NSUInteger*)segmentIndex 
               andAction:(BOOL*)usedAction 
           forMouseEvent:(NSEvent*)theEvent
{
    NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:nil];
    
    *segmentIndex = NSNotFound;
    *usedAction   = NO;
    
    for (NSUInteger i=0, n=_segments.count;  i<n;  i++) {
        if (CGRectContainsPoint(_selectRects[i], point)) {
            *segmentIndex = i;
            *usedAction = CGRectContainsPoint(_actionRects[i], point);
            break;
        }
    }
}

- (NUSegmentInfo *) segmentForTrackingTag:(NSInteger)tag
{
    for (NSUInteger i=0, count=_segments.count;  i<count;  i++) {
        if (_trackers[i] == tag)
            return [_segments objectAtIndex:i];
    }
    return nil;
}




// -----------------------------------------------------------------------------
   #pragma mark Events
// -----------------------------------------------------------------------------

- (void) resizeWithOldSuperviewSize:(NSSize)oldSize
{
    [super resizeWithOldSuperviewSize:oldSize];
    [self updateRects];
}

- (void) mouseDown:(NSEvent *)theEvent
{
    BOOL mouseDownAction = NO;
    [self getSegmentIndex:&_mouseDownSegment andAction:&mouseDownAction forMouseEvent:theEvent];
    _flags.mouseDownAction = mouseDownAction;

    if (_mouseDownSegment != NSNotFound) {
        NUSegmentInfo * segment = [_segments objectAtIndex:_mouseDownSegment];
        segment.pushed = YES;
    }
}

- (void) mouseUp:(NSEvent *)theEvent
{
    NSUInteger mouseUpSegment;
    BOOL mouseUpAction;
    
    [self getSegmentIndex:&mouseUpSegment andAction:&mouseUpAction forMouseEvent:theEvent];

    if (_mouseDownSegment!=NSNotFound) {
        
        NUSegmentInfo *segment = [_segments objectAtIndex:_mouseDownSegment];
        
        if (mouseUpSegment == _mouseDownSegment) {
            if (segment.enabled) {
                if (_flags.mouseDownAction && mouseUpAction && segment.buttonAction) {
                    segment.buttonAction(segment);
                } else {
                    if (segment.selectable)
                        [self mutateSelectionIndexesAtIndex:[_segments indexOfObject:segment]];
                    else
                        segment.selectAction(segment);
                }
            }
        }
        
        segment.pushed = NO;
    }
}

- (void) mouseDragged:(NSEvent*)theEvent
{
    // Do nothing except prevent the dragging event from bubbling up the
    // responder chain.
}

- (void) mouseEntered:(NSEvent *)theEvent
{
    NUSegmentInfo *segment = [self segmentForTrackingTag:theEvent.trackingNumber];
    segment.active = YES;
}

- (void) mouseExited:(NSEvent *)theEvent
{
    NUSegmentInfo *segment = [self segmentForTrackingTag:theEvent.trackingNumber];
    segment.active = NO;
}



// -----------------------------------------------------------------------------
   #pragma mark Drawing
// -----------------------------------------------------------------------------

- (void) drawBackground
{
}

- (void) drawSegment:(NUSegmentInfo *)segment atIndex:(NSUInteger)index
{
}

- (void) drawOverlay
{
}

- (void)drawRect:(NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];
    [self drawBackground];
    
    NSUInteger index = 0;
    for (NUSegmentInfo *segmentInfo in _segments)
        [self drawSegment:segmentInfo atIndex:index++];
    
    [self drawOverlay];
    [NSGraphicsContext restoreGraphicsState];
}


// -----------------------------------------------------------------------------
   #pragma mark KVO
// -----------------------------------------------------------------------------

+ (NSSet*) keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    static NSSet *selectedIndexesDeps = nil;
    
    if (selectedIndexesDeps == nil)
        selectedIndexesDeps = [NSSet setWithObjects:@"selectedIndex",@"selectedObject",@"selectedObjects", nil];
    
    if ([selectedIndexesDeps containsObject:key])
        return [NSSet setWithObject:@"selectionIndexes"];
    
    return [super keyPathsForValuesAffectingValueForKey:key];
}

// COV_NF_END


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([_segments containsObject:object]) {
        [self setNeedsDisplay:YES];
        
        if ([keyPath isEqualToString:@"selected"])
            [self mutateSelectionIndexesAtIndex:[_segments indexOfObject:object]];
    }
}


- (void) startObservingSegments
{
    for (NUSegmentInfo *segmentInfo in _segments) {
        [(id)segmentInfo addObserver:self forKeyPath:@"label" options:NSKeyValueObservingOptionNew context:NULL];
        [(id)segmentInfo addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
        [(id)segmentInfo addObserver:self forKeyPath:@"active" options:NSKeyValueObservingOptionNew context:NULL];
        [(id)segmentInfo addObserver:self forKeyPath:@"pushed" options:NSKeyValueObservingOptionNew context:NULL];
        [(id)segmentInfo addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:NULL];
        [(id)segmentInfo addObserver:self forKeyPath:@"selectable" options:NSKeyValueObservingOptionNew context:NULL];
        [(id)segmentInfo addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void) stopObservingSegments
{
    for (NUSegmentInfo *segmentInfo in _segments) {
        [(id)segmentInfo removeObserver:self forKeyPath:@"label"];
        [(id)segmentInfo removeObserver:self forKeyPath:@"image"];
        [(id)segmentInfo removeObserver:self forKeyPath:@"active"];
        [(id)segmentInfo removeObserver:self forKeyPath:@"pushed"];
        [(id)segmentInfo removeObserver:self forKeyPath:@"selected"];
        [(id)segmentInfo removeObserver:self forKeyPath:@"selectable"];
        [(id)segmentInfo removeObserver:self forKeyPath:@"enabled"];
    }
}

@end
