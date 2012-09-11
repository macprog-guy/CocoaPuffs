
#import "NSData+NUExtensions.h"

@implementation NSData (NUExtensions)

+ (id) rampWithUInt64StartingAt:(uint64_t)x increment:(uint64_t)dx count:(uint64_t)n
{
    uint64_t  bufferSize = sizeof(uint64_t) * n;
    uint64_t *buffer = malloc(bufferSize);
    
    for (uint64_t i=0;  i<n;  i++) {
        buffer[i] = x;
        x += dx;
    }
    
    return [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
}

+ (id) rampWithUInt64StartingAt:(uint64_t)x increment:(uint64_t)dx count:(uint64_t)n reverseOrder:(BOOL)reverse
{
    if (reverse) {
        x  = x + (n-1) * dx;
        dx = -dx;
    }
    
    return [self rampWithUInt64StartingAt:x increment:dx count:n];
}

- (NSString*) asciiArtOfWidth:(int)w andHeight:(int)h
{
    const uint8_t *bytes = self.bytes;
    int n = 0;
    
    NSMutableString *asciiArt = [NSMutableString string];
    NSMutableString *bar  = [NSMutableString stringWithString:@"+"];
    
    for (int i=0;  i<w;  i++)
        [bar appendString:@"-"];
    [bar appendString:@"+"];
    
    [asciiArt appendFormat:@"%@\n",bar];
    
    for (int j=0;  j<h;  j++) {

        NSMutableString *line = [NSMutableString string];
        
        for (int i=0;  i<w;  i++, n++) {

            NSString *charStr = @" ";
            
            if (bytes[n] == 0)
                charStr = @" ";
            else if (bytes[n] <= 32)
                charStr = @".";
            else if (bytes[n] <= 64)
                charStr = @"-";
            else if (bytes[n] <= 96)
                charStr = @"+";
            else if (bytes[n] <= 128)
                charStr = @"=";
            else if (bytes[n] <= 160)
                charStr = @"o";
            else if (bytes[n] <= 192)
                charStr = @"#";
            else if (bytes[n] <= 234)
                charStr = @"@";
            else
                charStr = @"8";
            
            [line appendString:charStr];
        }
        
        [asciiArt appendFormat:@"|%@|\n",line];
    }
    
    [asciiArt appendFormat:@"%@\n",bar];

    return asciiArt;
}


@end
