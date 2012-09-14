
#import "NUSimpleXPCService.h"
#import <xpc/xpc.h>

NSString *kSimpleXPCMessageNameKey = @"_messageName";
NSString *kSimpleXPCTimestampKey = @"_timestamp";
NSString *kSimpleXPCPayloadKey = @"_payload";
NSString *kSimpleXPCReplyExpectedKey = @"_replyExpected";

// COV_NF_START

// -----------------------------------------------------------------------------
   #pragma mark - NUSimpleXPCEvent
// -----------------------------------------------------------------------------

@interface NUSimpleXPCEvent() {
    
    NUSimpleXPCPeer *peer;
    xpc_connection_t xpc_reply_connnection;
    xpc_object_t xpc_message;
    
    NSString     *name;
    NSDate       *timestamp;
    NSDictionary *message;
    BOOL replyExpected;
}

@end

@implementation NUSimpleXPCEvent

@synthesize source=peer, name, timestamp, message, replyExpected;

// -----------------------------------------------------------------------------
   #pragma mark Init & Dealloc
// -----------------------------------------------------------------------------

- (id) initWithXPCMessage:(xpc_object_t)xpc_msg withPeer:(NUSimpleXPCPeer*)aPeer
{
    if ((self = [super init])) {
        
        peer = aPeer;
        
        if (xpc_msg) {
            
            xpc_message = xpc_msg;
        
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[NSObject objectFromXPCObject:xpc_message]];
        
            name = [info objectForKey:kSimpleXPCMessageNameKey];
            message = [info objectForKey:kSimpleXPCPayloadKey];
            timestamp = [info objectForKey:kSimpleXPCTimestampKey];
            replyExpected = [[info objectForKey:kSimpleXPCReplyExpectedKey] boolValue];
        }
    }
    return self;
}

+ (id) eventWithXPCMessage:(xpc_object_t)xpc_msg withPeer:(NUSimpleXPCPeer*)aPeer
{
    return [[self alloc] initWithXPCMessage:xpc_msg withPeer:aPeer];
}

- (id) initFromPeer:(NUSimpleXPCPeer*)aPeer
{
    return [self initWithXPCMessage:NULL withPeer:aPeer];
}

+ (id) eventFromPeer:(NUSimpleXPCPeer*)peer
{
    return [[self alloc] initFromPeer:peer];
}


// -----------------------------------------------------------------------------
   #pragma mark Posting/Replying
// -----------------------------------------------------------------------------

- (void) postMessage:(NSDictionary*)msg withName:(NSString*)aName handleReply:(NUSimpleXPCPeerEventHandler)replyBlock
{
    xpc_object_t     xpc_post = NULL;
    xpc_connection_t xpc_conn = NULL;
    
    if (xpc_message && replyExpected) {
        xpc_post = xpc_dictionary_create_reply(xpc_message);
        xpc_conn = xpc_dictionary_get_remote_connection(xpc_message);
    } else {
        xpc_post = xpc_dictionary_create(NULL, NULL, 0);
        xpc_conn = peer.connection;
    }

    xpc_object_t xpc_timestamp = [[NSDate date] xpcObject];
    xpc_dictionary_set_string(xpc_post, kSimpleXPCMessageNameKey.UTF8String, aName.UTF8String);
    xpc_dictionary_set_value(xpc_post, kSimpleXPCTimestampKey.UTF8String, xpc_timestamp);
    xpc_dictionary_set_bool(xpc_post, kSimpleXPCReplyExpectedKey.UTF8String, (replyBlock!=nil));

    if (msg) {
        xpc_object_t xpc_payload = [msg xpcObject];
        xpc_dictionary_set_value(xpc_post, kSimpleXPCPayloadKey.UTF8String, xpc_payload);
    }

    if (replyBlock) {
        xpc_connection_send_message_with_reply(xpc_conn, xpc_post, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(xpc_object_t xpc_reply) {
            [peer processMessage:xpc_reply withReplyBlock:replyBlock];
        });
    } else {
        xpc_connection_send_message(xpc_conn, xpc_post);
    }
}

- (void) postMessage:(NSDictionary*)msg withName:(NSString*)aName
{
    [self postMessage:msg withName:aName handleReply:nil];
}

+ (void) postMessage:(NSDictionary*)msg withName:(NSString*)aName fromPeer:(NUSimpleXPCPeer*)aPeer handleReply:(NUSimpleXPCPeerEventHandler)replyBlock
{
    NUSimpleXPCEvent *event = [NUSimpleXPCEvent eventFromPeer:aPeer];
    [event postMessage:msg withName:aName handleReply:replyBlock];
}


@end





// -----------------------------------------------------------------------------
   #pragma mark - NUSimpleXPCPeer
// -----------------------------------------------------------------------------

@interface NUSimpleXPCPeer() {
    xpc_connection_t connection;
}

- (void) processMessage:(xpc_object_t)message 
         withReplyBlock:(NUSimpleXPCPeerEventHandler)replyBlock;

@end


@implementation NUSimpleXPCPeer

@synthesize eventHandler, connection;

// -----------------------------------------------------------------------------
   #pragma mark Init & Dealloc
// -----------------------------------------------------------------------------

- (id) initWithConnection:(xpc_connection_t)aConnection
{
    if ((self = [super init])) {
        if (aConnection) {
            connection = aConnection;
            xpc_connection_set_event_handler(connection, ^(xpc_object_t message) {
                [self processMessage:message withReplyBlock:nil];
            });
            xpc_connection_resume(connection);
        }
    }
    return self;
}

- (id) init
{
    return [self initWithConnection:nil];
}

+ (id) peerWithConnection:(xpc_connection_t)aConnection
{
    return [[self alloc] initWithConnection:aConnection];
}

- (id) initPeerWithServiceName:(NSString*)serviceName onDispactchQueue:(dispatch_queue_t)queue
{
    xpc_connection_t c = xpc_connection_create(serviceName.UTF8String, queue);
    id service = [self initWithConnection:c];
    return service;
}

+ (id) peerWithServiceName:(NSString*)serviceName onDispactchQueue:(dispatch_queue_t)queue
{
    return [[self alloc] initPeerWithServiceName:serviceName onDispactchQueue:queue];
}
    
+ (id) peerWithServiceName:(NSString*)serviceName
{ 
    return [[self alloc] initPeerWithServiceName:serviceName 
                                onDispactchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}


// -----------------------------------------------------------------------------
   #pragma mark Properties
// -----------------------------------------------------------------------------

- (NSString*) name
{
    return [NSString stringWithFormat:@"%s.%d", xpc_connection_get_name(connection),xpc_connection_get_pid(connection)];
}

// -----------------------------------------------------------------------------
   #pragma mark Helpers
// -----------------------------------------------------------------------------

- (void) processMessage:(xpc_object_t)message withReplyBlock:(NUSimpleXPCPeerEventHandler)replyBlock
{
    xpc_type_t type = xpc_get_type(message);
    
    if (type == XPC_TYPE_ERROR) {
        if (message == XPC_ERROR_CONNECTION_INTERRUPTED) {
            // The service has either cancaled itself, crashed, or been
            // terminated.  The XPC connection is still valid and sending a
            // message to it will re-launch the service.  If the service is
            // state-full, this is the time to initialize the new service.
            [self handleInterruptedConnection];
            
        } else if (message == XPC_ERROR_CONNECTION_INVALID) {
            // The service is invalid. Either the service name supplied to
            // xpc_connection_create() is incorrect or we (this process) have
            // canceled the service; we can do any cleanup of appliation
            // state at this point.
            [self handleInvalidConnection];
            
        } else if (message == XPC_ERROR_TERMINATION_IMMINENT) {
            // Handle per-connection termination cleanup.
            [self handleTerminationImminent];
            
        } else {
            // We should not be getting here but if we do then handle it!
            [self handleUnknownError:message];
        }
    } else {
        
        // We have a regular message so lets process it!
        NUSimpleXPCEvent *event = [NUSimpleXPCEvent eventWithXPCMessage:message withPeer:self];
        
        if (replyBlock) {
            replyBlock(event);
        }
        else if (event.name == nil) {
            [self handleUnknownEvent:event];
        } 
        else {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            
            SEL action = NSSelectorFromString([NSString stringWithFormat:@"handle%@:", event.name]);
            
            if ([self respondsToSelector:action]) {
                [self performSelector:action withObject:event];
            }
            else if (self.eventHandler) {
                self.eventHandler(event);
            }
            else if ([self respondsToSelector:@selector(handleUnknownEvent:)])
                [self handleUnknownEvent:event];

#pragma clang diagnostic pop
        
        }
    }
}

// -----------------------------------------------------------------------------
   #pragma mark Posting Messages
// -----------------------------------------------------------------------------

- (void) postMessage:(NSDictionary*)msg withName:(NSString*)name handleReply:(NUSimpleXPCPeerEventHandler)replyBlock
{
    [NUSimpleXPCEvent postMessage:msg withName:name fromPeer:self handleReply:replyBlock];
}

- (void) postMessage:(NSDictionary*)msg withName:(NSString*)name
{
    [NUSimpleXPCEvent postMessage:msg withName:name fromPeer:self handleReply:nil];
}


// -----------------------------------------------------------------------------
   #pragma mark Handling Messages
// -----------------------------------------------------------------------------

- (void) handleInterruptedConnection
{
#ifdef NUSIMPLEXPC_DEBUG
    NSLog(@"%@ => %@", self, NSStringFromSelector(_cmd));
#endif
}

- (void) handleInvalidConnection
{
#ifdef NUSIMPLEXPC_DEBUG
    NSLog(@"%@ => %@", self, NSStringFromSelector(_cmd));
#endif
    [self cleanup];
}

- (void) handleTerminationImminent
{
#ifdef NUSIMPLEXPC_DEBUG
    NSLog(@"%@ => %@", self, NSStringFromSelector(_cmd));
#endif
    [self cleanup];
}

- (void) handleUnknownError:(xpc_object_t)error
{
#ifdef NUSIMPLEXPC_DEBUG
    NSLog(@"%@ => %@", self, NSStringFromSelector(_cmd));
#endif
}

- (void) handleUnknownEvent:(NUSimpleXPCEvent*)event
{
#ifdef NUSIMPLEXPC_DEBUG
    NSLog(@"%@ => %@", self, NSStringFromSelector(_cmd));
#endif
}

- (void) cleanup
{
#ifdef NUSIMPLEXPC_DEBUG
    NSLog(@"%@ => %@", self, NSStringFromSelector(_cmd));
#endif
}


@end



// -----------------------------------------------------------------------------
   #pragma mark - NUSimpleXPCServer
// -----------------------------------------------------------------------------

static NUSimpleXPCServer *gXPCServer = nil;
static NSMutableArray    *gXPCPeers  = nil;

static void NUSimpleXPCServer_connection_handler(xpc_connection_t connection)
{
    NUSimpleXPCPeer *peer = [gXPCServer serverWithConnection:connection];

    xpc_connection_set_event_handler(peer.connection, ^(xpc_object_t message) {
        
        // First process the message normally.
        [peer processMessage:message withReplyBlock:nil];

        // Then do some clean-up if necessary.
        if (xpc_get_type(message) == XPC_TYPE_ERROR) {
            @synchronized(gXPCPeers) {
                [gXPCPeers removeObject:peer];
            }
        } 
    });
    
    [gXPCPeers addObject:peer];
}

void NUSimpleXPCServer_main(NUSimpleXPCServer *server)
{
    gXPCServer = server;
    gXPCPeers  = [NSMutableArray array];
    xpc_main(NUSimpleXPCServer_connection_handler);
}


@implementation NUSimpleXPCServer

+ (id) server
{
    return [[self alloc] init];
}

+ (id) serverWithEventHandler:(NUSimpleXPCPeerEventHandler)eventHandler
{
    NUSimpleXPCServer *server = [self server];
    server.eventHandler = eventHandler;
    return server;
}

- (id) serverWithConnection:(xpc_connection_t)aConnection
{
    id server = [[self class] peerWithConnection:aConnection];
    [server setEventHandler:self.eventHandler];
    return server;
}

@end


// COV_NF_END





// -----------------------------------------------------------------------------
   #pragma mark - NSObject Category (Boxing)
// -----------------------------------------------------------------------------

xpc_object_t xpcObjectFromObject(id object);

static xpc_object_t xpcObjectFromDictionary(NSDictionary *dict)
{
    xpc_object_t xpc_dict = xpc_dictionary_create(NULL, NULL, 0);
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]]) {        
            xpc_object_t xpc_value = xpcObjectFromObject(value);
            xpc_dictionary_set_value(xpc_dict, [key cStringUsingEncoding:NSUTF8StringEncoding], xpc_value);
        }
    }];
    
    return xpc_dict;
}

static xpc_object_t xpcObjectFromArray(NSArray *array)
{
    xpc_object_t xpc_array = xpc_array_create(NULL, 0);
    
	[array enumerateObjectsUsingBlock:^(id value, NSUInteger index, BOOL *stop) {
        xpc_object_t xpc_item = xpcObjectFromObject(value);
        if (xpc_item) {
            xpc_array_set_value(xpc_array, XPC_ARRAY_APPEND, xpc_item);
        }
    }];
    
    return xpc_array;
}

static xpc_object_t xpcObjectFromnumber(NSNumber *number)
{
    xpc_object_t xpc_number = NULL;
    
    if(number == (NSNumber*)kCFBooleanTrue)
        xpc_number = xpc_bool_create(true);
    else if(number == (NSNumber*)kCFBooleanFalse)
        xpc_number = xpc_bool_create(false);
    else {
        const char* objCType = number.objCType;
        if (strcmp(objCType, @encode(unsigned long long)) == 0 ||
            strcmp(objCType, @encode(unsigned long     )) == 0 ||
            strcmp(objCType, @encode(unsigned int      )) == 0 ||
            strcmp(objCType, @encode(unsigned short    )) == 0 ||
            strcmp(objCType, @encode(unsigned char     )) == 0 ||
            strcmp(objCType, @encode(NSUInteger        )) == 0 )
            xpc_number = xpc_uint64_create([number unsignedLongLongValue]);
        else if(strcmp(objCType, @encode(long long)) == 0 ||
                strcmp(objCType, @encode(long     )) == 0 ||
                strcmp(objCType, @encode(int      )) == 0 ||
                strcmp(objCType, @encode(short    )) == 0 ||
                strcmp(objCType, @encode(char     )) == 0 ||
                strcmp(objCType, @encode(NSInteger)) == 0 )
            xpc_number = xpc_int64_create([number longLongValue]);
        else
            xpc_number = xpc_double_create([number doubleValue]);
    }
    
    return xpc_number;
}

xpc_object_t xpcObjectFromObject(id object)
{
    xpc_object_t xpc_object = NULL;
    
    if ([object isKindOfClass:[NSDictionary class]])
        xpc_object = xpcObjectFromDictionary(object);
    else if ([object isKindOfClass:[NSArray class]])
        xpc_object = xpcObjectFromArray(object);
    else if ([object isKindOfClass:[NSNumber class]])
        xpc_object = xpcObjectFromnumber(object);
    else if ([object isKindOfClass:[NSString class]])
        xpc_object = xpc_string_create([object cStringUsingEncoding:NSUTF8StringEncoding]);
    else if ([object isKindOfClass:[NSDate class]])
        xpc_object = xpc_date_create((int64_t)([object timeIntervalSince1970] * 1000000000));
    else if ([object isKindOfClass:[NSData class]])
        xpc_object = xpc_data_create([object bytes], [object length]);
    else if (object == [NSNull null])
        xpc_object = xpc_null_create();
    // COV_NF_START
    else if ([object isKindOfClass:[NSFileHandle class]])
        xpc_object = xpc_fd_create([object fileDescriptor]);
    else
        [NSException raise:NSInvalidArgumentException format:@"xpcObjectFromObject: class %@ is not supported", NSStringFromClass([object class])];
    // COV_NF_END
    
    return xpc_object;
}



// -----------------------------------------------------------------------------
   #pragma mark - NSObject Category (Unboxing)
// -----------------------------------------------------------------------------

id objectFromXPCObject(xpc_object_t xpc_object);

static NSDictionary* dictionaryFromXPCDictionary(xpc_object_t xpc_object)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    xpc_dictionary_apply(xpc_object, ^(const char *key, xpc_object_t xpc_item){
        
        NSString *aKey = @(key);
        id aValue = objectFromXPCObject(xpc_item);
        
        if(aKey && aValue)
            [dict setObject:aValue forKey:aKey];
        
        return (bool)YES;
    });
    
    return dict;
}

static NSArray* arrayFromXPCArray(xpc_object_t xpc_object)
{
    NSMutableArray *array = [NSMutableArray array];
    
	xpc_array_apply(xpc_object, ^(size_t index, xpc_object_t xpc_item) {
		id item = objectFromXPCObject(xpc_item);
		if (item)
			[array insertObject:item atIndex:index];
		return (_Bool)YES;
	});
    
    return array;
}

static NSData* dataFromXPCData(xpc_object_t xpc_object)
{
    return [NSData dataWithBytes:xpc_data_get_bytes_ptr(xpc_object)
                          length:xpc_data_get_length(xpc_object)];
}

static NSDate* dateFromXPCDate(xpc_object_t xpc_object)
{
    NSTimeInterval secondsSince1970 = xpc_date_get_value(xpc_object) / 1000000000.0;
    return [NSDate dateWithTimeIntervalSince1970:secondsSince1970];
}

// COV_NF_START

static NSFileHandle *fileHandleFromXPCFD(xpc_object_t xpc_object)
{
	return [[NSFileHandle alloc] initWithFileDescriptor:xpc_fd_dup(xpc_object) 
                                         closeOnDealloc:YES];
}

static NSData* dataFromXPCShMem(xpc_object_t xpc_object)
{
    [NSException raise:NSInvalidArgumentException 
                format:@"Shared Memory Objects are not yet supported"];
    return nil;
}

static NSString* stringFromXPCUUID(xpc_object_t xpc_object)
{
    const uint8_t *uuid_bytes = xpc_uuid_get_bytes(xpc_object);
    CFUUIDRef uuid = CFUUIDCreateFromUUIDBytes(NULL, *((CFUUIDBytes*)uuid_bytes));
    NSString *uuidStr = (__bridge_transfer NSString*) CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return uuidStr;
}

// COV_NF_END

id objectFromXPCObject(xpc_object_t xpc_object)
{
    id object = nil;
    
    xpc_type_t type = xpc_get_type(xpc_object);
    
    if (type == XPC_TYPE_DICTIONARY) {
        object = dictionaryFromXPCDictionary(xpc_object);
    } else if (type == XPC_TYPE_ARRAY) {
        object = arrayFromXPCArray(xpc_object);
    } else if (type == XPC_TYPE_BOOL) {
        object = @(xpc_bool_get_value(xpc_object));
    } else if (type == XPC_TYPE_DATA) {
        object = dataFromXPCData(xpc_object);
    } else if (type == XPC_TYPE_DATE) {
        object = dateFromXPCDate(xpc_object);
    } else if (type == XPC_TYPE_DOUBLE) {
        object = @(xpc_double_get_value(xpc_object));
    } else if (type == XPC_TYPE_INT64) {
        object = @(xpc_int64_get_value(xpc_object));
    } else if (type == XPC_TYPE_NULL) {
        object = [NSNull null];
    } else if (type == XPC_TYPE_STRING) {
        object = @(xpc_string_get_string_ptr(xpc_object));
    } else if (type == XPC_TYPE_UINT64) {
        object = @(xpc_uint64_get_value(xpc_object));
    }
    
    // COV_NF_START   GCOV_EXCL_START
    else if (type == XPC_TYPE_FD) {
        object = fileHandleFromXPCFD(xpc_object);
    } else if (type == XPC_TYPE_UUID) {
        object = stringFromXPCUUID(xpc_object);
    } else if (type == XPC_TYPE_SHMEM) {
        object = dataFromXPCShMem(xpc_object);
    } else if (type == XPC_TYPE_ENDPOINT) {
        [NSException raise:NSInvalidArgumentException format:@"Unsupported xpc_type_t XPC_TYPE_ENDPOINT"]; // COV_NF_LINE
    } else if (type == XPC_TYPE_CONNECTION) {
        [NSException raise:NSInvalidArgumentException format:@"Unsupported xpc_type_t XPC_TYPE_CONNECTION"]; // COV_NF_LINE
    }
    // COV_NF_END   GCOV_EXCL_END
    
    return object;
}


@implementation NSObject (XPCService)

+ (id) objectFromXPCObject:(xpc_object_t)xpc_object
{
    return objectFromXPCObject(xpc_object);
}

- (xpc_object_t) xpcObject
{
    return xpcObjectFromObject(self);
}

@end

