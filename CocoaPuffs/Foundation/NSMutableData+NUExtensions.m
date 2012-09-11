
#import "NSMutableData+NUExtensions.h"

@implementation NSMutableData (NUExtensions)

#define NUReverseBuffer(buffer, temp, n)\
    ({\
        for (uint64_t i=0;  i<n/2;  i++) {\
            temp = buffer[i];\
            buffer[i] = buffer[n-i-1];\
            buffer[n-i-1] = temp;\
        }\
    })
    
        

- (void) reverseBytesInChunksOfSize:(NSUInteger)sizeOfChunk
{
    const uint64_t n = self.length / sizeOfChunk;

    if (sizeOfChunk == 1) {
        uint8_t *buffer = self.mutableBytes, temp;
        NUReverseBuffer(buffer, temp, n);
    } 
    else if (sizeOfChunk == 2) {
        uint16_t *buffer = self.mutableBytes, temp;
        NUReverseBuffer(buffer, temp, n);
    }
    else if (sizeOfChunk == 4) {
        uint32_t *buffer = self.mutableBytes, temp;
        NUReverseBuffer(buffer, temp, n);
    }
    else if (sizeOfChunk == 8) {
        uint64_t *buffer = self.mutableBytes, temp;
        NUReverseBuffer(buffer, temp, n);
    }
    else {
        // COV_NF_START
        [NSException raise:NSInvalidArgumentException
                    format:@"The only valid values for sizeOfChunk are 1,2,4 and 8."];
        // COV_NF_END
    }
}


@end
