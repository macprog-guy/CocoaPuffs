
#import "NSURL+NUExtensions.h"
#import <sys/stat.h>

@implementation NSURL (CompatibleUTTypes)


- (NSString*) URLTypeIdentifier
{
    NSString *uti = nil;
    
    if ([self getResourceValue:&uti forKey:NSURLTypeIdentifierKey error:nil] && uti)
        return uti;
    
    return nil;
}

- (BOOL) conformsToType:(NSString*)type
{
    return [self conformsToAnyTypeInTypes:@[type]];
}

- (BOOL) conformsToAnyTypeInTypes:(NSArray*)types
{
    NSString *urlType = self.URLTypeIdentifier;
    if (urlType) {
        for (NSString *type in types) {
            if (UTTypeConformsTo((__bridge CFStringRef)urlType, (__bridge CFStringRef)type))
                return YES;
        }
    }
    return NO;
}


- (NSUInteger) eachLine:(void(^)(uint64_t line_no, char *text, long length, BOOL *stop))handler
{
    NSUInteger line_count = 0;
    const char *file_path = self.path.UTF8String; 
    int fd = open(file_path, O_RDONLY);
    
    if (fd != -1) {
        @try {
            struct stat st;
            fcntl(fd, F_NOCACHE, YES);
            fstat(fd, &st);
            
            const blksize_t buffer_size = st.st_blksize;
            char *buffer = malloc(buffer_size * 2);
            ssize_t bytes_read = 1;
            BOOL  should_stop = NO;

            char *sol = buffer;
            char *eol = buffer;
            char *sob = buffer;
            char *lim = buffer + buffer_size * 2;
            char *eob = NULL;
            
            while (! should_stop) {
                
                // Read one full buffers worth of bytes but no more than 
                // our buffer can handle.
                bytes_read = read(fd, sob, MIN(buffer_size, lim - sob));
                
                // Stop if there are no more bytes to read.
                if (bytes_read == 0)
                    break;
                
                // Determine where the actual bytes end.
                eob = sob + bytes_read;
                    
                // Process the lines in this chunk of bytes
                while (eol < eob) {
                    
                    // Find the next new-line character or end-of-buffer
                    while (*eol != '\n' && eol < eob) eol++;
                    
                    if (*eol != '\n')
                        break;
                    
                    // Substitute the newline with null char before processing
                    *eol = '\0';
                    if (handler) handler(line_count++, sol, eol - sol, &should_stop);
                    
                    // Move the start-of-line pointer
                    sol = ++eol;
                    
                    // Exit the loop if caller indicated to stop
                    if (should_stop)
                        break;
                }
                
                // Copy the remaining bytes to the start of the buffer.
                // If we reached lim then no newlines found within buffer x 2
                // so just stop.
                if (eol < lim) {
                    
                    uint64_t remaining_bytes = eol - sol;
                    if (remaining_bytes > 0)
                        memcpy(buffer, sol, remaining_bytes);
                    
                    sol = buffer;
                    sob = buffer + remaining_bytes;
                    eol = sob;
                    
                } else {
                    should_stop = YES;
                }
            }
            
            free(buffer);
        }
        @finally {
            close(fd);
        }
    }
    
    return line_count;
}


- (NSUInteger) eachFieldSplitBy:(char)splitChar do:(void(^)(uint64_t line_no, uint64_t field_no, char *field, long length, BOOL *stop))handler
{
    return [self eachLine:^(uint64_t line_no, char *text, long line_length, BOOL *stop) {
       
        uint64_t field_no = 0;
        char *field = text;
        
        for (long i=0;  i<line_length+1;  i++) {
            if (text[i] == '\0' || text[i] == splitChar) {
                
                text[i] = '\0';
                
                if (handler)
                    handler(line_no, field_no++, field, &text[i] - field, stop);
                
                if (*stop)
                    break;
                
                field = &text[i+1];
            }
        }
    }];
}

- (NSUInteger) eachFieldSplitBy:(char)splitChar fieldCount:(uint64_t)fieldCount do:(void(^)(uint64_t line_no, uint64_t field_no, char *field, long length, BOOL *stop))handler
{
    return [self eachLine:^(uint64_t line_no, char *text, long line_length, BOOL *stop) {
        
        uint64_t field_no = 0;
        char *field = text;
        
        for (long i=0;  i<line_length+1;  i++) {
            if (text[i] == '\0' || text[i] == splitChar) {
                
                text[i] = '\0';
                
                if (handler && field_no < fieldCount)
                    handler(line_no, field_no++, field, &text[i] - field, stop);
                
                if (*stop)
                    break;
                
                field = &text[i+1];
            }
        }
        
        if (handler) {
            while (field_no < fieldCount &&  *stop==NO) {
                handler(line_no, field_no++, "", 0, stop);
            }
        }
    }];
}


@end
