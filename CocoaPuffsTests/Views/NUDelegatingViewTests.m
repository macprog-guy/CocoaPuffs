
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

typedef enum NUDelegatedMouseEvent : NSUInteger {
    
    kMouseDown    = 1 << 0,
    kMouseDragged = 1 << 1,
    kMouseUp      = 1 << 2,
    kMouseEntered = 1 << 3,
    kMouseExited  = 1 << 4,
    kResetCursor  = 1 << 5,
    kDraggingEntered = 1 << 6,
    kDraggingUpdated = 1 << 7,
    kDraggingExited  = 1 << 8,
    kPrepareDragOp   = 1 << 9,
    kPerformDragOp   = 1 << 10,
    kConcludeDragOp  = 1 << 11,
    kDraggingEnded   = 1 << 12,
    kWantsDragUpdates = 1 << 13,
    kUpdateDragItems  = 1 << 14,
    kDrawRect         = 1 << 15,
    
} NUDelegatedMouseEvent;


@interface NUDelegatingViewTests : SenTestCase<NUViewDelegate> {
    
    NSWindow         *_window;
    NUDelegatingView *_delegatingView;
    NUDelegatingView *_nonDelegatingView;
    NSEvent          *_fakeEvent;
    NSObject         *_fakeDelegate;
    uint64_t          _flags;
}
@end

@implementation NUDelegatingViewTests

- (void) setUp
{
    _window = [[NSWindow alloc] initWithContentRect:CGRectMake(0, 0, 100, 100) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
    _window.contentView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    _fakeDelegate = [[NSObject alloc] init];
    _nonDelegatingView = [[NUDelegatingView alloc] initWithFrame:CGRectMake(0, 0, 50, 100)];
    _nonDelegatingView.delegate = _fakeDelegate;
    [_window.contentView addSubview:_nonDelegatingView];

    _delegatingView = [[NUDelegatingView alloc] initWithFrame:CGRectMake(50, 0, 50, 100)];
    _delegatingView.delegate = self;
    [_window.contentView addSubview:_delegatingView];
    
    _fakeEvent = [NSEvent mouseEventWithType:NSLeftMouseDown
                                    location:CGPointMake(50, 50)
                               modifierFlags:0
                                   timestamp:0
                                windowNumber:_window.windowNumber
                                     context:nil
                                 eventNumber:0
                                  clickCount:1
                                    pressure:0];
}

// -----------------------------------------------------------------------------
   #pragma mark - Delegating Methods
// -----------------------------------------------------------------------------

- (void) testDelegatingMouseDown
{
    [_delegatingView mouseDown:_fakeEvent];
    STAssertEquals(_flags, kMouseDown, @"Event should have been delegated");
}

- (void) testDelegatingMouseDragged
{
    [_delegatingView mouseDragged:_fakeEvent];
    STAssertEquals(_flags, kMouseDragged, @"Event should have been delegated");
}

- (void) testDelegatingMouseUp
{
    [_delegatingView mouseUp:_fakeEvent];
    STAssertEquals(_flags, kMouseUp, @"Event should have been delegated");
}

- (void) testDelegatingMouseEntered
{
    [_delegatingView mouseEntered:_fakeEvent];
    STAssertEquals(_flags, kMouseEntered, @"Event should have been delegated");
}

- (void) testDelegatingMouseExited
{
    [_delegatingView mouseExited:_fakeEvent];
    STAssertEquals(_flags, kMouseExited, @"Event should have been delegated");
}

- (void) testDelegatingResetMouseCursors
{
    [_delegatingView resetCursorRects];
    STAssertEquals(_flags, kResetCursor, @"Event should have been delegated");
}

- (void) testDelegatingDraggingEntered
{
    [_delegatingView draggingEntered:nil];
    STAssertEquals(_flags, kDraggingEntered, @"Event should have been delegated");
}

- (void) testDelegatingDraggingUpdated
{
    [_delegatingView draggingUpdated:nil];
    STAssertEquals(_flags, kDraggingUpdated, @"Event should have been delegated");
}

- (void) testDelegatingDraggingExited
{
    [_delegatingView draggingExited:nil];
    STAssertEquals(_flags, kDraggingExited, @"Event should have been delegated");
}

- (void) testDelegatingPrepareForDragOperation
{
    [_delegatingView prepareForDragOperation:nil];
    STAssertEquals(_flags, kPrepareDragOp, @"Event should have been delegated");
}

- (void) testDelegatingPerformDragOperation
{
    [_delegatingView performDragOperation:nil];
    STAssertEquals(_flags, kPerformDragOp, @"Event should have been delegated");
}

- (void) testDelegatingConcludeDragOperation
{
    [_delegatingView concludeDragOperation:nil];
    STAssertEquals(_flags, kConcludeDragOp, @"Event should have been delegated");
}

- (void) testDelegatingDraggingEnded
{
    [_delegatingView draggingEnded:nil];
    STAssertEquals(_flags, kDraggingEnded, @"Event should have been delegated");
}

- (void) testsWantsPeriodicDraggingUpdates
{
    [_delegatingView wantsPeriodicDraggingUpdates];
    STAssertEquals(_flags, kWantsDragUpdates, @"Event should have been delegated");
}

- (void) testDelegatingUpdateDraggingItems
{
    [_delegatingView updateDraggingItemsForDrag:nil];
    STAssertEquals(_flags, kUpdateDragItems, @"Event should have been delegated");
}

- (void) testDelegatingDrawRect
{
    [_delegatingView drawRect:CGRectMake(0, 0, 100, 100)];
    STAssertEquals(_flags, kDrawRect, @"Event should have been delegated");
}



// -----------------------------------------------------------------------------
   #pragma mark - Non Delegating Methods
// -----------------------------------------------------------------------------

- (void) testNonDelegatingMouseDown
{
    STAssertNoThrow([_nonDelegatingView mouseDown:_fakeEvent], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView mouseDown:_fakeEvent], @"Should not throw exception");
}

- (void) testNonDelegatingMouseDragged
{
    STAssertNoThrow([_nonDelegatingView mouseDragged:_fakeEvent], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView mouseDragged:_fakeEvent], @"Should not throw exception");
}

- (void) testNonDelegatingMouseUp
{
    STAssertNoThrow([_nonDelegatingView mouseUp:_fakeEvent], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView mouseUp:_fakeEvent], @"Should not throw exception");
}

- (void) testNonDelegatingMouseEntered
{
    STAssertNoThrow([_nonDelegatingView mouseEntered:_fakeEvent], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView mouseEntered:_fakeEvent], @"Should not throw exception");
}

- (void) testNonDelegatingMouseExited
{
    STAssertNoThrow([_nonDelegatingView mouseExited:_fakeEvent], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView mouseExited:_fakeEvent], @"Should not throw exception");
}

- (void) testNonDelegatingResetMouseCursors
{
    STAssertNoThrow([_nonDelegatingView resetCursorRects], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView resetCursorRects], @"Should not throw exception");
}

- (void) testNonDelegatingDraggingEntered
{
    STAssertNoThrow([_nonDelegatingView draggingEntered:nil], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView draggingEntered:nil], @"Should not throw exception");
}

- (void) testNonDelegatingDraggingUpdated
{
    STAssertNoThrow([_nonDelegatingView draggingUpdated:nil], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView draggingUpdated:nil], @"Should not throw exception");
}

- (void) testNonDelegatingDraggingExited
{
    STAssertNoThrow([_nonDelegatingView draggingExited:nil], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView draggingExited:nil], @"Should not throw exception");
}

- (void) testNonDelegatingPrepareForDragOperation
{
    STAssertNoThrow([_nonDelegatingView prepareForDragOperation:nil], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView prepareForDragOperation:nil], @"Should not throw exception");
}

- (void) testNonDelegatingPerformDragOperation
{
    STAssertNoThrow([_nonDelegatingView performDragOperation:nil], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView performDragOperation:nil], @"Should not throw exception");
}

- (void) testNonDelegatingConcludeDragOperation
{
    STAssertNoThrow([_nonDelegatingView concludeDragOperation:nil], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView concludeDragOperation:nil], @"Should not throw exception");
}

- (void) testNonDelegatingDraggingEnded
{
    STAssertNoThrow([_nonDelegatingView draggingEnded:nil], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView draggingEnded:nil], @"Should not throw exception");
}

- (void) testNonDelegatingWantsPeriodicDraggingUpdates
{
    STAssertNoThrow([_nonDelegatingView wantsPeriodicDraggingUpdates], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView wantsPeriodicDraggingUpdates], @"Should not throw exception");
}

- (void) testNonDelegatingUpdateDraggingItems
{
    STAssertNoThrow([_nonDelegatingView updateDraggingItemsForDrag:nil], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView updateDraggingItemsForDrag:nil], @"Should not throw exception");
}

- (void) testNonDelegatingDrawRect
{
    STAssertNoThrow([_nonDelegatingView drawRect:CGRectMake(0, 0, 100, 100)], @"Should not throw exception");
    _nonDelegatingView.delegate = nil;
    STAssertNoThrow([_nonDelegatingView drawRect:CGRectMake(0, 0, 100, 100)], @"Should not throw exception");
}



// -----------------------------------------------------------------------------
   #pragma mark - Delegate Methods
// -----------------------------------------------------------------------------

- (void) view:(NSView*)view mouseDown:(NSEvent *)theEvent
{
    _flags |= kMouseDown;
}

- (void) view:(NSView*)view mouseDragged:(NSEvent *)theEvent
{
    _flags |= kMouseDragged;
}

- (void) view:(NSView*)view mouseUp:(NSEvent *)theEvent
{
    _flags |= kMouseUp;
}

- (void) view:(NSView*)view mouseEntered:(NSEvent *)theEvent
{
    _flags |= kMouseEntered;
}

- (void) view:(NSView*)view mouseExited:(NSEvent *)theEvent
{
    _flags |= kMouseExited;
}

- (void) viewResetCursorRects:(NSView *)aView
{
    _flags |= kResetCursor;
}

- (NSDragOperation) view:(NSView*)view draggingEntered:(id<NSDraggingInfo>)sender
{
    _flags |= kDraggingEntered;
    return NSDragOperationGeneric;
}

- (NSDragOperation) view:(NSView*)view draggingUpdated:(id<NSDraggingInfo>)sender
{
    _flags |= kDraggingUpdated;
    return NSDragOperationGeneric;
}

- (void) view:(NSView*)view draggingExited:(id<NSDraggingInfo>)sender
{
    _flags |= kDraggingExited;
}

- (BOOL) view:(NSView *)aView prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    _flags |= kPrepareDragOp;
    return YES;
}

- (BOOL) view:(NSView *)aView performDragOperation:(id<NSDraggingInfo>)sender
{
    _flags |= kPerformDragOp;
    return YES;
}

- (void) view:(NSView *)aView concludeDragOperation:(id<NSDraggingInfo>)sender
{
    _flags |= kConcludeDragOp;
}

- (void) view:(NSView*)view draggingEnded:(id<NSDraggingInfo>)sender
{
    _flags |= kDraggingEnded;
}

- (BOOL) viewWantsPeriodicDraggingUpdates:(NSView *)aView
{
    _flags |= kWantsDragUpdates;
    return NO;
}

- (void) view:(NSView *)aView updateDraggingItemsForDrag:(id<NSDraggingInfo>)sender
{
    _flags |= kUpdateDragItems;
}

- (void) view:(NSView *)aView drawRect:(NSRect)dirtyRect
{
    _flags |= kDrawRect;
}

@end
