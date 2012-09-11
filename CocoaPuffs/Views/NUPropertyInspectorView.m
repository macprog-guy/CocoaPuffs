
#import "NUPropertyInspectorView.h"

@interface NUPropertyInspectorView() {
    
    NSString *_name;
    NSString *_label;
    NSString *_units;
    BOOL      _resizableControl;
    
    NSTextField *_labelField;
    NSControl   *_valueControl;
    NSTextField *_textField;
    NSTextField *_unitsField;
    
    NSArray     *_constraints;
}
@end

@implementation NUPropertyInspectorView // COV_NF_LINE

// -----------------------------------------------------------------------------
   #pragma mark Init & Dealloc
// -----------------------------------------------------------------------------

- (id) initWithName:(NSString*)aName label:(NSString*)aLabel andControl:(NSControl*)aControl
{
    if ((self = [super initWithFrame:CGRectZero])) {
        
        _name  = aName;
        _label = aLabel;
        _valueControl = (id)[self processedControl:aControl];
        _textField  = nil;
        _unitsField = nil;
        _resizableControl = YES;
        
        _labelField = (id)[self processedControl:[[NSTextField alloc] init]];
        [_labelField.cell setAlignment:NSRightTextAlignment];
        [_labelField setStringValue:_label ? _label : @""];
        [_labelField setEditable:NO];
        [_labelField setDrawsBackground:NO];
        [_labelField setBordered:NO];
        [_labelField setSelectable:NO];
        [_labelField sizeToFit];

        NSDictionary *views   = NSDictionaryOfVariableBindings(_valueControl);
        NSDictionary *metrics = @{@"minWidth": @(_labelField.intrinsicContentSize.width)};
        
        [_valueControl addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"[_valueControl(>=120,>=minWidth)]" options:0 metrics:metrics views:views]];
        
        self.subviews = @[_labelField, aControl];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setNeedsUpdateConstraints:YES];
    }
    
    return self;
}

+ (id) propertyInspectorWithName:(NSString*)aName label:(NSString*)aLabel andControl:(NSControl*)aControl
{
    return [[self alloc] initWithName:aName label:aLabel andControl:aControl];
}



// -----------------------------------------------------------------------------
   #pragma mark Properties
// -----------------------------------------------------------------------------

+ (BOOL) requiresConstraintBasedLayout
{
    return YES;
}

- (NSString*) label
{
    return _label;
}

- (void) setLabel:(NSString *)value
{
    _label = [value copy];
    _labelField.stringValue = _label;
}

- (NSString*) units
{
    return _units;
}

- (void) setUnits:(NSString *)value
{
    if (_unitsField == nil && value) {
     
        _unitsField = [[NSTextField alloc] init];
        _unitsField.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_unitsField.cell setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
        [_unitsField.cell setAlignment:NSLeftTextAlignment];
        [_unitsField.cell setControlSize:NSSmallControlSize];
        [_unitsField setFocusRingType:NSFocusRingTypeNone];
        [_unitsField setEditable:NO];
        [_unitsField setDrawsBackground:NO];
        [_unitsField setBordered:NO];
        [_unitsField setSelectable:NO];
        
        [self addSubview:_unitsField];
        [self setNeedsUpdateConstraints:YES];
        
    } else if (value == nil) {
        
        [_unitsField removeFromSuperview];
        _unitsField = nil;
    }

    _units = [value copy];
    _unitsField.stringValue = _units;
    
    [self setNeedsUpdateConstraints:YES];
}

- (NSTextField*) unitsField
{
    return _unitsField;
}


- (NSTextField*) textField
{
    return _textField;
}

- (void) setTextField:(NSTextField *)value
{
    [_textField removeFromSuperview];
    _textField = value;
    
    if (_textField) {
        
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        [_textField.cell setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
        [_textField.cell setControlSize:NSSmallControlSize];
        [_textField setFocusRingType:NSFocusRingTypeNone];
        [self addSubview:_textField];
    }
    [self setNeedsUpdateConstraints:YES];
}

- (double) baselineOffsetFromBottom
{
    return 10.0;
}


// -----------------------------------------------------------------------------
   #pragma mark Helpers
// -----------------------------------------------------------------------------

- (NSControl*) processedControl:(NSControl*)control
{
    control.translatesAutoresizingMaskIntoConstraints = NO;
    [control.cell setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
    [control.cell setControlSize:NSSmallControlSize];
    [control setFocusRingType:NSFocusRingTypeNone];

    return control;
}


// -----------------------------------------------------------------------------
   #pragma mark Layout
// -----------------------------------------------------------------------------

- (NSArray*) verticalConstraintsForSubview:(NSView*)subview
{
    return [NSArray arrayWithObjects:
    
            [NSLayoutConstraint constraintWithItem:subview
                                         attribute:NSLayoutAttributeBaseline
                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeBaseline
                                        multiplier:1.0
                                          constant:0.0],
 
            [NSLayoutConstraint constraintWithItem:subview
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:subview.intrinsicContentSize.height],
            nil];
}

- (void) updateConstraints
{
    [super updateConstraints];
    
    if (self.superview) {
        
        if (_constraints)
            [self removeConstraints:_constraints];

        NSString *visualFormat = nil;
        NSMutableArray *constraints   = [NSMutableArray array];
        NSMutableDictionary *views    = [NSMutableDictionary dictionaryWithDictionary:@{
                                          @"labelField"   : _labelField,
                                          @"valueControl" : _valueControl
                                      }];
        
        NSDictionary *metrics = @{@"minLabelWidth": @(_labelField.intrinsicContentSize.width)};

        [constraints addObjectsFromArray:[self verticalConstraintsForSubview:_labelField]];
        [constraints addObjectsFromArray:[self verticalConstraintsForSubview:_valueControl]];
        
        if (_textField && _unitsField) {
            visualFormat = @"H:|-(8)-[labelField(>=minLabelWidth)]-(8)-[valueControl(>=120)]-(8)-[textField(64)]-(8)-[unitsField(32)]-(8)-|";
            [views setObject:_textField forKey:@"textField"];
            [views setObject:_unitsField forKey:@"unitsField"];
            [constraints addObjectsFromArray:[self verticalConstraintsForSubview:_textField]];
            [constraints addObjectsFromArray:[self verticalConstraintsForSubview:_unitsField]];
        } else if (_textField) {
            visualFormat = @"H:|-(8)-[labelField(>=minLabelWidth)]-(8)-[valueControl(>=120)]-(8)-[textField(64)]-(>=8)-|";
            [views setObject:_textField forKey:@"textField"];
            [constraints addObjectsFromArray:[self verticalConstraintsForSubview:_textField]];
        } else if (_unitsField) {
            visualFormat = @"H:|-(8)-[labelField(>=minLabelWidth)]-(8)-[valueControl(>=120)]-(8)-[unitsField(48)]-(>=8)-|";
            [views setObject:_unitsField forKey:@"unitsField"];
            [constraints addObjectsFromArray:[self verticalConstraintsForSubview:_unitsField]];
        } else {
            visualFormat = @"H:|-(8)-[labelField(>=minLabelWidth)]-(8)-[valueControl(>=120)]-(>=8)-|";
        }
        
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        
        [self addConstraints:constraints];
        _constraints = constraints;
    }
}



@end
