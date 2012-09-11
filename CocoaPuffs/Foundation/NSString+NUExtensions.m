
#import "NSString+NUExtensions.h"

static NSRegularExpression *gRegexpForUpperCaseLetters  = nil;
static NSRegularExpression *gRegexpForConsecutiveSpaces = nil;


@implementation NSString (NUExtensions)

+ (NSString*) stringForPathToTemporaryFileWithTemplate:(NSString*)template andExtension:(NSString*)ext
{
    NSString *temporaryFilename = nil;
    
    // Prefix the template with the temp directory.
    template = [NSTemporaryDirectory() stringByAppendingPathComponent:template];
    
    // Make it into a CString
    const char *templateCString = [template fileSystemRepresentation];
    
    // Copy the result to the filenameCString buffer
    char *filenameCString = malloc(strlen(templateCString)+1);
    strcpy(filenameCString, templateCString);
        
    @synchronized(self) {
        mktemp(filenameCString);
    }
    
    temporaryFilename = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:filenameCString length:strlen(filenameCString)];
    
    free(filenameCString);
    
    return ext ? [NSString stringWithFormat:@"%@.%@", temporaryFilename,ext] : temporaryFilename;
}

+ (NSString*) stringForPathToTemporaryFileWithExtension:(NSString*)ext
{
    return [self stringForPathToTemporaryFileWithTemplate:@"XXXXXXXXXXXXXXXX" andExtension:ext];
}


+ (NSString*) stringForPathToTemporaryFileWithTemplate:(NSString*)template
{
    return [self stringForPathToTemporaryFileWithTemplate:template andExtension:nil];
}


+ (NSString*) stringForPathToTemporaryFile
{
    return [self stringForPathToTemporaryFileWithTemplate:@"XXXXXXXXXXXXXXXX" andExtension:nil];
}

- (NSString*) stringWithTitleCase
{
    NSString *titleCase = self;
    
    if (gRegexpForUpperCaseLetters == nil) {
        @synchronized(self.class) {
            gRegexpForUpperCaseLetters = [NSRegularExpression regularExpressionWithPattern:@"([A-Z])" options:0 error:NULL];
            gRegexpForConsecutiveSpaces = [NSRegularExpression regularExpressionWithPattern:@"\\s{2,}" options:0 error:NULL];
        }
    }

    titleCase = [gRegexpForUpperCaseLetters stringByReplacingMatchesInString:titleCase options:0 range:NSMakeRange(0, titleCase.length) withTemplate:@" $1"];
    titleCase = [titleCase stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    titleCase = [gRegexpForConsecutiveSpaces stringByReplacingMatchesInString:titleCase options:0 range:NSMakeRange(0, titleCase.length) withTemplate:@" "]; 
    titleCase = [titleCase stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    titleCase = [titleCase capitalizedString];

    return titleCase;
}

- (NSString*) stringByRemovingAccents
{
    return [[NSString alloc] initWithData:[self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] encoding:NSASCIIStringEncoding];
}

+ (NSString*) stringFromUUID
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    
    return uuidString;
}

@end
