
#import <SenTestingKit/SenTestingKit.h>
#import "CocoaPuffs.h"

@interface NURangeSliderTests : SenTestCase {
    NURangeSlider *_slider;
}
@end

@implementation NURangeSliderTests

- (void) setUp
{
    _slider = [[NURangeSlider alloc] init];
    _slider.frame = CGRectMake(0,0,400,16);
}

- (void) testDefaultProperties
{
    STAssertEquals(_slider.absoluteMinimum, 0.0, @"Values should match");
    STAssertEquals(_slider.rangeMinimum, 0.0, @"Values should match");
    STAssertEquals(_slider.rangeMaximum, 1.0, @"Values should match");
    STAssertEquals(_slider.absoluteMaximum, 1.0, @"Values should match");
    STAssertEquals(_slider.rounding, 0.01, @"Values should match");
}

- (void) testNSCoding
{
    NURangeSlider *copy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:_slider]];
    STAssertEquals(_slider.absoluteMinimum, copy.absoluteMinimum, @"Values should match");
    STAssertEquals(_slider.rangeMinimum, copy.rangeMinimum, @"Values should match");
    STAssertEquals(_slider.rangeMaximum, copy.rangeMaximum, @"Values should match");
    STAssertEquals(_slider.absoluteMaximum, copy.absoluteMaximum, @"Values should match");
    STAssertEquals(_slider.rounding, copy.rounding, @"Values should match");
}

- (void) testBoundaries
{
    _slider.rangeMinimum = _slider.absoluteMinimum - 0.2;
    STAssertEquals(_slider.rangeMinimum, _slider.absoluteMinimum, @"Values should match");
    
    _slider.absoluteMinimum = 0.25;
    STAssertEquals(_slider.rangeMinimum, _slider.absoluteMinimum, @"Values should match");

    _slider.rangeMaximum = _slider.absoluteMaximum + 0.2;
    STAssertEquals(_slider.rangeMaximum, _slider.absoluteMaximum, @"Values should match");
    
    _slider.absoluteMaximum = 0.75;
    STAssertEquals(_slider.rangeMaximum, _slider.absoluteMaximum, @"Values should match");
    
    _slider.rangeMinimum = 0.5;
    _slider.rangeMaximum = 0.5;
    _slider.rangeMinimum = 0.6; // Should clip to 0.5
    _slider.rangeMaximum = 0.4; // Should clip to 0.5
    STAssertEquals(_slider.rangeMinimum, 0.5, @"Values should match");
    STAssertEquals(_slider.rangeMaximum, 0.5, @"Values should match");
    
    
    _slider.absoluteMinimum = 100;
    STAssertEquals(_slider.rangeMinimum, 100.0, @"Values should match");
    STAssertEquals(_slider.rangeMaximum, 100.0, @"Values should match");
    STAssertEquals(_slider.absoluteMinimum, 100.0, @"Values should match");
    STAssertEquals(_slider.absoluteMaximum, 100.0, @"Values should match");
    
    _slider.absoluteMaximum = 200;
    STAssertEquals(_slider.rangeMinimum, 100.0, @"Values should match");
    STAssertEquals(_slider.rangeMaximum, 100.0, @"Values should match");
    STAssertEquals(_slider.absoluteMinimum, 100.0, @"Values should match");
    STAssertEquals(_slider.absoluteMaximum, 200.0, @"Values should match");
    
    _slider.absoluteMaximum = 50;
    STAssertEquals(_slider.rangeMinimum, 50.0, @"Values should match");
    STAssertEquals(_slider.rangeMaximum, 50.0, @"Values should match");
    STAssertEquals(_slider.absoluteMinimum, 50.0, @"Values should match");
    STAssertEquals(_slider.absoluteMaximum, 50.0, @"Values should match");
    
    _slider.absoluteMinimum = 0;
    STAssertEquals(_slider.rangeMinimum, 50.0, @"Values should match");
    STAssertEquals(_slider.rangeMaximum, 50.0, @"Values should match");
    STAssertEquals(_slider.absoluteMinimum,  0.0, @"Values should match");
    STAssertEquals(_slider.absoluteMaximum, 50.0, @"Values should match");
}

- (void) testTrackKnowVisibility
{
    // For Code coverage only.
    _slider.tracksKnobVisibility = YES;
    STAssertTrue(_slider.tracksKnobVisibility, @"Values should match");

    _slider.tracksKnobVisibility = NO;
    STAssertFalse(_slider.tracksKnobVisibility, @"Values should match");
}


@end
