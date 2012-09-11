
#import <QuartzCore/QuartzCore.h>
#import "NUUserInterface.h"
#import "CGAdditions.h"
#import "NSString+NUExtensions.h"
#import "NUKeyboardUtils.h"
#import "NSObject+NUExtensions.h"

static NSUInteger gEventCounter = 0;

@interface NUUserInterface() {
    
    NSMutableArray  *_recordedEvents;
    NSMutableArray  *_recordedDurations;
    NUKeyboardUtils *_keyboardUtils;

    NSRunLoop      *_runLoop;
    NSTimeInterval  _previousInteractiveTimestamp;
    NSTimeInterval  _duration;
    NSTimeInterval  _defaultDuration;
    BOOL            _interactive;
    BOOL            _recording;
    BOOL            _silent;
    double          _speedup;

    AXUIElementRef	_systemWideElement;

    CFMachPortRef      _eventTap;
    CFRunLoopSourceRef _eventSource;
}

@end

@implementation NUUserInterface

// -----------------------------------------------------------------------------
   #pragma mark Static Functions
// -----------------------------------------------------------------------------

static CGEventRef callbackForRecorderEventTap(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *data) {

    NUUserInterface *recorder = (__bridge NUUserInterface*)data;
    if (recorder.recording && recorder.interactive)
        [recorder recordInteractiveEvent:[NSEvent eventWithCGEvent:event]];

    return event;
}

// -----------------------------------------------------------------------------
   #pragma mark Init & Dealloc
// -----------------------------------------------------------------------------

- (id) initWithRunLoop:(NSRunLoop*)runLoop
{
    if ((self = [super init])) {
        
        _runLoop = runLoop? runLoop : [NSRunLoop currentRunLoop];
        _recordedEvents = [NSMutableArray array];
        _recordedDurations = [NSMutableArray array];
        _duration = 0.0;
        _defaultDuration = 0.25;
        _speedup = 1.0;
        _silent = NO;
        _interactive = NO;
        _recording = NO;
        _systemWideElement = NULL;
        
        NSUInteger eventMask =
            CGEventMaskBit(kCGEventLeftMouseDown)    |
            CGEventMaskBit(kCGEventLeftMouseDragged) |
            CGEventMaskBit(kCGEventLeftMouseUp)      |
            CGEventMaskBit(kCGEventKeyDown)          |
            CGEventMaskBit(kCGEventKeyUp)            |
            CGEventMaskBit(kCGEventFlagsChanged);
        
        _eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, kCGEventTapOptionListenOnly, eventMask, callbackForRecorderEventTap, (__bridge void*)self);
        _eventSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, _eventTap, 0);
        CFRunLoopAddSource(_runLoop.getCFRunLoop, _eventSource, kCFRunLoopCommonModes);
        CGEventTapEnable(_eventTap, false);
    }
    return self;
}

+ (id) userInterfaceWithRunLoop:(NSRunLoop*)runLoop
{
    return [[self alloc] initWithRunLoop:runLoop];
}

+ (id) userInterfaceWithCurrentRunLoop
{
    return [[self alloc] initWithRunLoop:nil];
}

- (void) dealloc
{
    CFRunLoopRemoveSource(_runLoop.getCFRunLoop, _eventSource, kCFRunLoopCommonModes);
    CFRelease(_eventSource);
    CFRelease(_eventTap);
    _eventSource = NULL;
    _eventTap = NULL;
}

// -----------------------------------------------------------------------------
   #pragma mark Properties
// -----------------------------------------------------------------------------

- (BOOL) interactive
{
    return _interactive;
}

- (void) setInteractive:(BOOL)value
{
    if (value != _interactive) {
        if (value) {
            _interactive = YES;
            _previousInteractiveTimestamp = 0;
            CGEventTapEnable(_eventTap, true);
        } else {
            _interactive = NO;
            CGEventTapEnable(_eventTap, false);
            NSEvent *lastEvent = _recordedEvents.lastObject;
            if (lastEvent.type == NSLeftMouseDown || lastEvent.type == NSRightMouseDown)
                [_recordedEvents removeLastObject];
        }
    }
}

- (double) speedup
{
    return _speedup;
}

- (void) setSpeedup:(double)value
{
    if (value < 0.01)
        value = 0.01;
    else if (value > 100.0)
        value = 100.0;
    
    _speedup = value;
}



// -----------------------------------------------------------------------------
   #pragma mark Helpers
// -----------------------------------------------------------------------------

- (NSPoint) convertPointToScreen:(CGPoint)p fromView:(NSView*)aView flipY:(BOOL)shouldFlipY
{
    p = [aView.window convertRectToBacking:CGRectWithOriginAndSize([aView convertPoint:p toView:nil], CGSizeZero)].origin;
    p = [aView.window convertBaseToScreen:p];
    
    if (shouldFlipY) {
        
        CGRect screenFrame = CGRectNull;
        
        for (NSScreen *screen in NSScreen.screens) {
            if (NSPointInRect(p, screen.frame))
                screenFrame = screen.frame;
        }
        
        if (!CGRectIsNull(screenFrame))
             p = CGPointMake(p.x, screenFrame.size.height - p.y - 1);
    }
    
    return p;
}

- (NSRect) convertRectToScreen:(CGRect)r fromView:(NSView*)aView
{
    r = [aView.window convertRectToBacking:[aView convertRect:r toView:nil]];
    r = [aView.window convertRectToScreen:r];

    return r;
}

- (void) clear
{
    _recordedEvents = [NSMutableArray array];
    _recordedDurations = [NSMutableArray array];
}

+ (void) runScript:(void(^)(NUUserInterface *userInterface))script
{
    NUUserInterface *userInterface = [NUUserInterface userInterfaceWithCurrentRunLoop];
    
    dispatch_semaphore_t wait = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void) {
        script(userInterface);
        dispatch_semaphore_signal(wait);
    });
    
    while (!dispatch_semaphore_wait(wait, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.01)));
}

+ (void) runUsingEventLoopForModalWindow:(NSWindow*)aWindow script:(void(^)(NUUserInterface *userInterface))script
{
    NUUserInterface *userInterface = [NUUserInterface userInterfaceWithCurrentRunLoop];

    dispatch_async(dispatch_get_global_queue(0, 0), ^(void) {
        
        // Give the modal window enough time to show and become key
        usleep(USEC_PER_SEC * 0.1);
        
        if (script)
            script(userInterface);

        // FIXME: For some reason we need to send one last event?
        CGEventRef shiftDown = CGEventCreateKeyboardEvent(NULL, kVK_Shift, true);
        CGEventRef shiftUp = CGEventCreateKeyboardEvent(NULL, kVK_Shift, true);
        CGEventPost(kCGSessionEventTap, shiftDown);
        CGEventPost(kCGSessionEventTap, shiftUp);
        CFRelease(shiftDown);
        CFRelease(shiftUp);

        [NSApp stopModal];
        [aWindow orderOut:nil];
    });
    
    [NSApp runModalForWindow:aWindow];
}

- (AXUIElementRef) AXElementForView:(NSView*)aView
{
    if (_systemWideElement == NULL)
        _systemWideElement = AXUIElementCreateSystemWide();
    
    CGPoint p = [self convertPointToScreen:CGRectCenter(aView.bounds) fromView:aView flipY:YES];
    AXUIElementRef element = NULL;
    
    AXUIElementCopyElementAtPosition(_systemWideElement, p.x, p.y, &element);
    
    return element;
}



// -----------------------------------------------------------------------------
   #pragma mark Programmatic Recording
// -----------------------------------------------------------------------------

- (void) recordEvent:(NSEvent *)event withDuration:(NSTimeInterval)duration
{
    [_recordedEvents addObject:event? event : [NSNull null]];
    [_recordedDurations addObject:@(duration)];
}

- (void) doEvent:(NSEvent*)event withDuration:(NSTimeInterval)secs
{
    if (_recording && !_interactive)
        [self recordEvent:event withDuration:secs];
    
    if (!_silent)
        CGEventPost(kCGSessionEventTap, event.CGEvent);
    
    [self pause:secs];
}


- (void) doMouseEventOfType:(NSEventType)type atScreenLocation:(NSPoint)p withModifier:(int)modFlags duration:(NSTimeInterval)secs
{
    NSEvent *event = [NSEvent mouseEventWithType:type
                                        location:p
                                   modifierFlags:modFlags
                                       timestamp:_duration
                                    windowNumber:NSIntegerMax
                                         context:[NSGraphicsContext currentContext]
                                     eventNumber:++gEventCounter
                                      clickCount:1
                                        pressure:(type & (NSLeftMouseDownMask|NSLeftMouseDraggedMask|NSRightMouseDownMask|NSRightMouseDraggedMask))? 1.0 : 0.0];

    [self doEvent:event withDuration:secs];
}


- (void) doMouseEventOfType:(NSEventType)type
           fromScreenLocation:(NSPoint)a
           toScreenLocation:(NSPoint)b
               withModifier:(int)modFlags
                   duration:(NSTimeInterval)secs
{
    static const int kIntermediateStepCount = 64;
    
    if (secs <= 0.0)
        secs = _defaultDuration;
    
    CGPoint ab = CGPointDiff(b, a);
    
    ab.x /= kIntermediateStepCount;
    ab.y /= kIntermediateStepCount;
    
    for (int i=0;  i<kIntermediateStepCount;  i++) {
        
        [self doMouseEventOfType:NSLeftMouseDragged
                atScreenLocation:a
                    withModifier:modFlags
                        duration:secs/kIntermediateStepCount];
        
        a = CGPointOffset(a, ab.x, ab.y);
    }
}

- (void) doMouseEventOfType:(NSEventType)type inView:(NSView*)viewA atPosition:(NSPoint)p withModifier:(int)modFlags duration:(NSTimeInterval)secs
{
    [self doMouseEventOfType:type
            atScreenLocation:[self convertPointToScreen:p fromView:viewA flipY:NO]
                withModifier:modFlags
                    duration:secs];
}

- (void) doMouseDragFromView:(NSView*)viewA atPosition:(NSPoint)a toView:(NSView*)viewB atPosition:(NSPoint)b withModifier:(int)modFlags duration:(NSTimeInterval)secs
{
    a = [self convertPointToScreen:a fromView:viewA flipY:NO];
    b = [self convertPointToScreen:b fromView:viewB flipY:NO];
    
    if (secs <= 0.0)
        secs = _defaultDuration;
    
    NSTimeInterval dragDuration = secs * 0.9;
    NSTimeInterval stepDuration = (secs - dragDuration)/3;
    
    [self doMouseEventOfType:NSMouseMoved
            atScreenLocation:a
                withModifier:0
                    duration:stepDuration];
    
    [self doMouseEventOfType:NSLeftMouseDown
            atScreenLocation:a
                withModifier:0
                    duration:stepDuration];
    
    [self doMouseEventOfType:NSLeftMouseDragged
          fromScreenLocation:a
            toScreenLocation:b
                withModifier:modFlags
                    duration:dragDuration];

    [self doMouseEventOfType:NSLeftMouseUp
            atScreenLocation:b
                withModifier:0
                    duration:stepDuration];
}

- (void) doMouseMoveToView:(NSView*)viewA atPosition:(NSPoint)a duration:(NSTimeInterval)secs
{
    [self doMouseEventOfType:NSMouseMoved
          fromScreenLocation:[NSEvent mouseLocation]
            toScreenLocation:[self convertPointToScreen:a fromView:viewA flipY:NO]
                withModifier:0
                    duration:secs];
}

- (void) doMouseClickInView:(NSView*)viewA atPosition:(NSPoint)a duration:(NSTimeInterval)secs
{
    if (secs <= 0.0)
        secs = _defaultDuration;
    
    [self doMouseMoveToView:viewA atPosition:a duration:secs * 0.8];
    [self doMouseEventOfType:NSLeftMouseDown inView:viewA atPosition:a withModifier:0 duration:secs * 0.1];
    [self doMouseEventOfType:NSLeftMouseUp  inView:viewA atPosition:a withModifier:0 duration:secs * 0.1];
}

- (void) doMouseDoubleClickInView:(NSView*)viewA atPosition:(NSPoint)a duration:(NSTimeInterval)secs
{
    NSEvent *event = nil;
    
    if (secs <= 0.0)
        secs = _defaultDuration;
    
    NSTimeInterval clickDuration = [NSEvent doubleClickInterval];
    secs = MAX(secs - clickDuration * 2, 0.01);
    
    [self doMouseMoveToView:viewA atPosition:a duration:secs];
    
    event = [NSEvent mouseEventWithType:NSLeftMouseDown
                               location:[self convertPointToScreen:a fromView:viewA flipY:NO]
                          modifierFlags:0
                              timestamp:_duration
                           windowNumber:NSIntegerMax
                                context:[NSGraphicsContext currentContext]
                            eventNumber:++gEventCounter
                             clickCount:2
                               pressure:1.0];

    [self doEvent:event withDuration:clickDuration];

    event = [NSEvent mouseEventWithType:NSLeftMouseUp
                               location:[self convertPointToScreen:a fromView:viewA flipY:NO]
                          modifierFlags:0
                              timestamp:_duration
                           windowNumber:NSIntegerMax
                                context:[NSGraphicsContext currentContext]
                            eventNumber:++gEventCounter
                             clickCount:2
                               pressure:0.0];

    [self doEvent:event withDuration:clickDuration];
}



- (void) pause:(NSTimeInterval)secs
{
    if (secs <= 0.0)
        secs = _defaultDuration;
    
    if (!_silent)
        usleep(secs * USEC_PER_SEC / _speedup);
    
    if (_recording)
        [self recordEvent:nil withDuration:secs];
}

- (void) doButtonClick:(NSButton*)button
{
    [self doMouseClickInView:button
                  atPosition:CGRectCenter(button.bounds)
                    duration:_defaultDuration];
}

- (void) doButtonDoubleClick:(NSButton *)button
{
    [self doMouseDoubleClickInView:button
                        atPosition:CGRectCenter(button.bounds)
                          duration:_defaultDuration];
}

- (void) doMenu:(NSMenu*)menu clickItemPath:(NSString*)menuPath
{
    NSMenuItem *menuItem = nil;
    
    if (menu == nil)
        menu = [NSApp mainMenu];

    for (NSString *title in [menuPath componentsSeparatedByString:@"/"]) {
        menuItem = [menu itemWithTitle:title];
        menu = menuItem.submenu;
    }
    
    if (menuItem) {
        menu = menuItem.menu;
    }
}

- (void) doPopup:(NSPopUpButton*)popup clickMenuWithPath:(NSString*)menuPath
{
    CGRect  b = popup.bounds;
    CGPoint p = CGPointMake(CGRectGetMaxX(b) - 24, CGRectGetMidY(b));
    
    AXUIElementRef axPopup = [self AXElementForView:popup];
    CFArrayRef axPopupChildren = NULL;

    [self doMouseClickInView:popup
                  atPosition:p
                    duration:_defaultDuration];

    AXUIElementCopyAttributeValue(axPopup, (__bridge CFStringRef)NSAccessibilityChildrenAttribute, (CFTypeRef*)&axPopupChildren);
    AXUIElementRef axMenu = CFArrayGetValueAtIndex((CFArrayRef)axPopupChildren, 0);
    
    CFArrayRef axMenuChildren = NULL;
    AXUIElementCopyAttributeValue(axMenu, (__bridge CFStringRef)NSAccessibilityChildrenAttribute, (CFTypeRef*)&axMenuChildren);

    NSUInteger menuCount = CFArrayGetCount(axMenuChildren);
    for (NSUInteger i=0;  i<menuCount;  i++) {
        
        CFStringRef menuItemTitle = NULL;
        AXUIElementRef axMenuItem = CFArrayGetValueAtIndex((CFArrayRef)axMenuChildren, i);
        AXUIElementCopyAttributeValue(axMenuItem, (CFStringRef)NSAccessibilityTitleAttribute, (CFTypeRef*)&menuItemTitle);
        
        if ([menuPath isEqualToString:(__bridge NSString*)menuItemTitle]) {
            AXUIElementPerformAction(axMenuItem, kAXPressAction);
            break;
        }
        
        CFRelease(menuItemTitle);
    }
    
    CFRelease(axMenuChildren);
    CFRelease(axMenu);
    CFRelease(axPopupChildren);
}

- (void) doTextField:(NSTextField*)textfiled writeText:(NSString*)text
{
    // TODO: implement doTextField:writeText:
}

- (void) doTextView:(NSTextField*)textfiled writeText:(NSString*)text
{
    // TODO: implement doTextView:writeText:
}

- (void) doSegmentedView:(NUSegmentedView*)view clickSegmentWithTitle:(NSString*)title
{
    NSInteger segmentIndex = NSNotFound, index = 0;

    for (NUSegmentInfo *segment in view.segments) {
        if ([segment.label isEqualToString:title] || [segment.name isEqualToString:title]) {
            segmentIndex = index;
            break;
        }
        index++;
    }
    
    if (segmentIndex != NSNotFound) {
        
        CGRect segmentRect = [view selectionRectAtIndex:segmentIndex];
        
        [self doMouseClickInView:view
                      atPosition:CGRectCenter(segmentRect)
                        duration:_defaultDuration];
    }
}

- (void) doSendKeys:(NSString*)chars withModifierFlags:(int)modFlags
{
    for (NSUInteger i=0;  i<chars.length;  i++) {
        
        unichar keyStroke = [chars characterAtIndex:i];
        uint16_t  keyCode = [NUKeyboardUtils virtualKeyCodesForKey:keyStroke];
        
        CGEventRef keyDown = CGEventCreateKeyboardEvent(NULL, keyCode, true);
        CGEventSetFlags(keyDown, modFlags);
        
        CGEventRef keyUp = CGEventCreateKeyboardEvent(NULL, keyCode, false);
        CGEventSetFlags(keyUp, modFlags);

        [self doEvent:[NSEvent eventWithCGEvent:keyDown] withDuration:0.01];
        [self doEvent:[NSEvent eventWithCGEvent:keyUp] withDuration:0.01];
        
        CFRelease(keyDown);
        CFRelease(keyUp);
    }
}

- (void) doUndo:(NSInteger)ntimes
{
    for (NSInteger i=0;  i<ntimes;  i++) {
        [self doSendKeys:@"z" withModifierFlags:NSCommandKeyMask];
        [self pause:0.2];
    }
}

- (void) doRedo:(NSInteger)ntimes
{
    for (NSInteger i=0;  i<ntimes;  i++) {
        [self doSendKeys:@"z" withModifierFlags:NSCommandKeyMask|NSShiftKeyMask];
        [self pause:0.2];
    }
}




// -----------------------------------------------------------------------------
   #pragma mark Playback
// -----------------------------------------------------------------------------

- (void) playbackWithCompletionBlock:(NUScenarioBlock)completionBlock
{
    if (!_recording) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^(void){

            for (NSUInteger i=0, n=_recordedEvents.count;  i<n;  i++) {

                NSEvent  *event = _recordedEvents[i];
                NSNumber *duration = _recordedDurations[i];
             
                if ([event isKindOfClass:[NSEvent class]])
                    CGEventPost(kCGSessionEventTap, event.CGEvent);
                
                [self pause:duration.doubleValue];
            }
            
            if (completionBlock)
                completionBlock();
        });
    }
}



// -----------------------------------------------------------------------------
   #pragma mark Actions
// -----------------------------------------------------------------------------


- (void) recordInteractiveEvent:(NSEvent*)event
{
    if (_previousInteractiveTimestamp == 0)
        _previousInteractiveTimestamp = event.timestamp;
    
    NSTimeInterval duration = event.timestamp - _previousInteractiveTimestamp;
    _previousInteractiveTimestamp = event.timestamp;
    
    [self recordEvent:event withDuration:duration];
}



- (IBAction)startInteractiveRecording:(id)sender
{
    self.recording = YES;
    self.interactive = YES;
}

- (IBAction)stopInteractiveRecording:(id)sender
{
    self.interactive = NO;
    self.recording = NO;
}

- (IBAction)toggleInteractiveRecording:(id)sender
{
    self.interactive = !self.interactive;
    self.recording   = !self.recording;
}

- (IBAction)playback:(id)sender
{
    [self playbackWithCompletionBlock:nil];
}


@end
