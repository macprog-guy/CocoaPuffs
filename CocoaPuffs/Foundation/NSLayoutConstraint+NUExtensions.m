
#import "NSLayoutConstraint+NUExtensions.h"

@implementation NSLayoutConstraint (NUExtensions)

+ (NSArray*) constraintsWithVisualFormats:(NSArray*)formats options:(NSLayoutFormatOptions)opts metrics:(NSDictionary *)metrics views:(NSDictionary *)views
{
    NSMutableArray *constraints = [NSMutableArray array];
    
    for (NSString *format in formats) {
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:format
                                                 options:opts
                                                 metrics:metrics
                                                   views:views]];
    }
        
    return constraints;
}

+ (NSArray*) constraintsForStackedItems:(NSArray*)items
                         withTopPadding:(NSString*)topPad
                             itemHeight:(NSString*)height
                                spacing:(NSString*)spacing
                          bottomPadding:(NSString*)bottomPad
{
    NSMutableArray    *visualParts = [NSMutableArray array];
    NSMutableDictionary *viewsDict = [NSMutableDictionary dictionary];
    
    topPad    = topPad    ? [topPad    isEqualToString:@"-"]? @"-" : [NSString stringWithFormat:@"-(%@)-", topPad]    : @"";
    height    = height    ?                                          [NSString stringWithFormat:@"(%@)"  , height]    : @"";
    spacing   = spacing   ? [spacing   isEqualToString:@"-"]? @"-" : [NSString stringWithFormat:@"-(%@)-", spacing]   : @"";
    bottomPad = bottomPad ? [bottomPad isEqualToString:@"-"]? @"-" : [NSString stringWithFormat:@"-(%@)-", bottomPad] : @"";
    
    NSInteger index = 0;
    for (NSView *view in items) {
        NSString *name = [NSString stringWithFormat:@"view%ld",index++];
        [visualParts addObject:[NSString stringWithFormat:@"[%@%@]",name, height]];
        [viewsDict setObject:view forKey:name];
    }
    
    NSString *visualFormat = [NSString stringWithFormat:@"V:|%@%@%@|", topPad, [visualParts componentsJoinedByString:spacing], bottomPad];
    
    return [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                                   metrics:nil
                                                     views:viewsDict];
}

+ (NSArray*) constraintsWithItem:(NSView*)aView havingWidth:(double)width
{
    return [NSArray arrayWithObject:
            [NSLayoutConstraint constraintWithItem:aView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1
                                          constant:width]];
}

+ (NSArray*) constraintsWithItem:(NSView*)aView havingHeight:(double)height
{
    return [NSArray arrayWithObject:
            [NSLayoutConstraint constraintWithItem:aView
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1
                                          constant:height]];
}

+ (NSArray*) constraintsWithItem:(NSView*)aView havingMinimumWidth:(double)minWidth
{
    return [NSArray arrayWithObject:
            [NSLayoutConstraint constraintWithItem:aView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1
                                          constant:minWidth]];
}

+ (NSArray*) constraintsWithItem:(NSView*)aView havingMinimumHeight:(double)minHeight
{
    return [NSArray arrayWithObject:
            [NSLayoutConstraint constraintWithItem:aView
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1
                                          constant:minHeight]];
}

+ (NSArray*) constraintsWithItem:(NSView*)item spanningWidthOfSuperviewWithPadding:(double)padding
{
    NSDictionary *views   = @{@"item":item};
    NSDictionary *metrics = @{@"padding":@(padding)};
    
    return [NSLayoutConstraint constraintsWithVisualFormat:@"|-(padding)-[item]-(padding)-|"
                                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                                   metrics:metrics
                                                     views:views];
}

+ (NSArray*) constraintsWithItemsHavingEqualWidth:(NSArray*)items
{
    NSMutableArray *constraints = [NSMutableArray array];
    
    id prevItem = nil;
    for (id item in items) {
        if (prevItem) {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:item
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:prevItem
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1.0
                                                                 constant:0.0]];

        }
        prevItem = item;
    }
    
    return constraints;
}

+ (NSArray*) constraintsWithItemsHavingEqualLeftEdges:(NSArray*)items
{
    NSMutableArray *constraints = [NSMutableArray array];
    
    id prevItem = nil;
    for (id item in items) {
        if (prevItem) {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:item
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:prevItem
                                                                attribute:NSLayoutAttributeLeft
                                                               multiplier:1.0
                                                                 constant:0.0]];
            
        }
        prevItem = item;
    }
    
    return constraints;
}

+ (NSArray*) constraintsWithItemsHavingEqualRightEdges:(NSArray*)items
{
    NSMutableArray *constraints = [NSMutableArray array];
    
    id prevItem = nil;
    for (id item in items) {
        if (prevItem) {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:item
                                                                attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:prevItem
                                                                attribute:NSLayoutAttributeRight
                                                               multiplier:1.0
                                                                 constant:0.0]];
            
        }
        prevItem = item;
    }
    
    return constraints;
}

+ (NSArray*) constraintsWithItems:(NSArray*)items eachSpanningWidthOfSuperviewWithPadding:(double)padding
{
    NSMutableArray *constraints = [NSMutableArray array];
    
    for (id item in items)
        [constraints addObjectsFromArray:[self constraintsWithItem:item spanningWidthOfSuperviewWithPadding:padding]];
    
    return constraints;
}

+ (NSArray*) constraintsWithItemsEachAlignedWithBaselineOfSuperview:(NSArray*)items
{
    NSMutableArray *constraints = [NSMutableArray array];
    
    for (NSView *item in items) {
        [constraints addObject:
         [NSLayoutConstraint constraintWithItem:item
                                      attribute:NSLayoutAttributeBaseline
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:item.superview
                                      attribute:NSLayoutAttributeBaseline
                                     multiplier:1.0
                                       constant:0.0]];
    }
    
    return constraints;
}

+ (NSArray*) constraintsWithItemsEachAlignedWithCenterYOfSuperview:(NSArray*)items
{
    NSMutableArray *constraints = [NSMutableArray array];
    
    for (NSView *item in items) {
        [constraints addObject:
         [NSLayoutConstraint constraintWithItem:item
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:item.superview
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0
                                       constant:0.0]];
    }
    
    return constraints;
}


@end
