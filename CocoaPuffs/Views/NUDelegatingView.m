
#import "NUDelegatingView.h"

@implementation NUDelegatingView

@synthesize delegate;

// -----------------------------------------------------------------------------
   #pragma mark Mouse Events
// -----------------------------------------------------------------------------

- (void) mouseDown:(NSEvent *)theEvent
{
    if (delegate && [delegate respondsToSelector:@selector(view:mouseDown:)])
        [delegate performSelector:@selector(view:mouseDown:) withObject:self withObject:theEvent];
}

- (void) mouseUp:(NSEvent *)theEvent
{
    if (delegate && [delegate respondsToSelector:@selector(view:mouseUp:)])
        [delegate performSelector:@selector(view:mouseUp:) withObject:self withObject:theEvent];
}

- (void) mouseDragged:(NSEvent *)theEvent
{
    if (delegate && [delegate respondsToSelector:@selector(view:mouseDragged:)])
        [delegate performSelector:@selector(view:mouseDragged:) withObject:self withObject:theEvent];
}

- (void) mouseEntered:(NSEvent *)theEvent
{
    if (delegate && [delegate respondsToSelector:@selector(view:mouseEntered:)])
        [delegate performSelector:@selector(view:mouseEntered:) withObject:self withObject:theEvent];
}

- (void) mouseExited:(NSEvent *)theEvent
{
    if (delegate && [delegate respondsToSelector:@selector(view:mouseExited:)])
        [delegate performSelector:@selector(view:mouseExited:) withObject:self withObject:theEvent];
}

- (void) resetCursorRects
{
    if (delegate && [delegate respondsToSelector:@selector(viewResetCursorRects:)])
        [delegate performSelector:@selector(viewResetCursorRects:) withObject:self];
}



// -----------------------------------------------------------------------------
   #pragma mark Drag & Drop
// -----------------------------------------------------------------------------

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if (delegate && [delegate respondsToSelector:@selector(view:draggingEntered:)])
        return [delegate view:self draggingEntered:sender];
    
    return  NSDragOperationNone;
}

#ifndef NUDELEGATINGVIEW_EXCLUDE_DRAGGING_UPDATE

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    if (delegate && [delegate respondsToSelector:@selector(view:draggingUpdated:)])
        return [delegate view:self draggingUpdated:sender];
    
    return  NSDragOperationNone;
}

#endif

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    if (delegate && [delegate respondsToSelector:@selector(view:draggingExited:)])
        [delegate view:self draggingExited:sender];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    if (delegate && [delegate respondsToSelector:@selector(view:prepareForDragOperation:)])
        return [delegate view:self prepareForDragOperation:sender];
    
    return  NO;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    if (delegate && [delegate respondsToSelector:@selector(view:performDragOperation:)])
        return [delegate view:self performDragOperation:sender];
    
    return  NO;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    if (delegate && [delegate respondsToSelector:@selector(view:concludeDragOperation:)])
        [delegate view:self concludeDragOperation:sender];    
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
    if (delegate && [delegate respondsToSelector:@selector(view:draggingEnded:)])
        [delegate view:self draggingEnded:sender];
}

- (BOOL)wantsPeriodicDraggingUpdates
{
    if (delegate && [delegate respondsToSelector:@selector(viewWantsPeriodicDraggingUpdates:)])
        return [delegate viewWantsPeriodicDraggingUpdates:self];
    
    return  NO;
}

- (void)updateDraggingItemsForDrag:(id <NSDraggingInfo>)sender
{
    if (delegate && [delegate respondsToSelector:@selector(view:updateDraggingItemsForDrag:)])
        [delegate view:self updateDraggingItemsForDrag:sender];
}




// -----------------------------------------------------------------------------
   #pragma mark Drawing
// -----------------------------------------------------------------------------

- (void) drawRect:(NSRect)dirtyRect
{
    if (delegate && [delegate respondsToSelector:@selector(view:drawRect:)])
        [delegate performSelector:@selector(view:drawRect:) withObject:self withObject:[NSValue valueWithRect:dirtyRect]];
}


@end
