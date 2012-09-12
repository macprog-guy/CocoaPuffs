#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NSViewController_NUExtensionsTests : SenTestCase

@end


@implementation NSViewController_NUExtensionsTests

- (void) testControllerWithColocatedNibNamed
{
    NSView *view = nil;
    // For coverage only
    NSViewController *controller = [NSViewController controllerWithColocatedNibNamed:@"Toto"];
    STAssertNotNil(controller, @"Should be not be nil");
    STAssertThrows(view = controller.view, @"Nib does not exist so should throw");
    STAssertNil(view, @"View should still be nil");
}

- (void) testBitmapImageForRect
{
    NSButton *button = [[NSButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    button.title = @"This is a button";
    
    NSImage *image = [button bitmapImage];
    STAssertNotNil(image, @"There should be an image");
    STAssertEquals(image.size.width , 100.0, @"Values should match");
    STAssertEquals(image.size.height,  30.0, @"Values should match");
    
    image = [button bitmapImageForVisibleRect];
    STAssertNotNil(image, @"There should be an image");
    STAssertEquals(image.size.width , 100.0, @"Values should match");
    STAssertEquals(image.size.height,  30.0, @"Values should match");

    image = [button bitmapImageForRect:CGRectMake(5, 5, 10, 10)];
    STAssertNotNil(image, @"There should be an image");
    STAssertEquals(image.size.width , 10.0, @"Values should match");
    STAssertEquals(image.size.height, 10.0, @"Values should match");
}

@end
