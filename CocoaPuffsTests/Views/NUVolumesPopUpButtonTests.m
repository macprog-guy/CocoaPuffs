
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NUVolumesPopUpButtonTests : SenTestCase {
    NUVolumesPopUpButton *_volumesPopUp;
}
@end

@implementation NUVolumesPopUpButtonTests

- (void) setUp
{
    _volumesPopUp = [[NUVolumesPopUpButton alloc] initWithFrame:CGRectMake(0, 0, 200, 24) pullsDown:NO];
}

- (void) testDefaultVolumesPopUp
{
    STAssertNotNil(_volumesPopUp.menu, @"Should have a menu");
    
    NSMenuItem *menuItem = [_volumesPopUp.menu itemWithTitle:@"Home"];
    STAssertNotNil(menuItem, @"Value should not be nil");

    menuItem = [_volumesPopUp.menu itemWithTitle:@"Desktop"];
    STAssertNotNil(menuItem, @"Value should not be nil");

    menuItem = [_volumesPopUp.menu itemWithTitle:@"Documents"];
    STAssertNotNil(menuItem, @"Value should not be nil");

    menuItem = [_volumesPopUp.menu itemWithTitle:@"Pictures"];
    STAssertNotNil(menuItem, @"Value should not be nil");
}

- (void) testSerialization
{
    [_volumesPopUp selectItemAtIndex:1];
    
    NUVolumesPopUpButton *copy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:_volumesPopUp]];
    
    STAssertNotNil(_volumesPopUp.menu, @"Should have a menu");
    
    NSMenuItem *menuItem = [copy.menu itemWithTitle:@"Home"];
    STAssertNotNil(menuItem, @"Value should not be nil");
    
    menuItem = [copy.menu itemWithTitle:@"Desktop"];
    STAssertNotNil(menuItem, @"Value should not be nil");
    
    menuItem = [copy.menu itemWithTitle:@"Documents"];
    STAssertNotNil(menuItem, @"Value should not be nil");
    
    menuItem = [copy.menu itemWithTitle:@"Pictures"];
    STAssertNotNil(menuItem, @"Value should not be nil");
    
    STAssertEqualObjects(_volumesPopUp.selectedURL, copy.selectedURL, @"Values should match");
}

- (void) testSelectedURL
{
    STAssertEqualObjects(_volumesPopUp.selectedURL, [NSURL fileURLWithPath:@"/"], @"Values should match");
    
    NSURL *documentsURL = [NSURL fileURLWithPath:@"/Users/eric/Documents"];
    _volumesPopUp.selectedURL = documentsURL;
    STAssertEqualObjects(_volumesPopUp.selectedURL, documentsURL, @"Values should match");
    
    NSURL *anotherURL = [NSURL fileURLWithPath:@"/Users/eric/Development"];
    _volumesPopUp.selectedURL = anotherURL;
    STAssertEqualObjects(_volumesPopUp.selectedURL, documentsURL, @"Values should match");
}

- (void) testAddRemoveURL
{
    NSURL *devURL = [NSURL fileURLWithPath:@"/Users/eric/Development"];
    [_volumesPopUp addItemWithURL:devURL title:nil image:nil andAction:nil forTarget:nil];
    [_volumesPopUp selectItemWithTitle:@"Development"];
    
    STAssertEqualObjects(_volumesPopUp.selectedURL, devURL, @"Values should match");
    
    [_volumesPopUp removeURL:devURL];
    STAssertEqualObjects(_volumesPopUp.selectedURL, [NSURL fileURLWithPath:@"/"], @"Values should match");

    _volumesPopUp.selectedURL = devURL;
    STAssertEqualObjects(_volumesPopUp.selectedURL, [NSURL fileURLWithPath:@"/"], @"Values should match");
}




@end
