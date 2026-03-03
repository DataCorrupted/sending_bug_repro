#import "Legacy.h"

// --- Payload ---

@implementation Payload
@end

// --- LegacyObjCHandler ---

@implementation LegacyObjCHandler
- (void)handle:(Payload *)value {
    NSLog(@"LegacyObjCHandler received: %@", value.name);
}
@end
