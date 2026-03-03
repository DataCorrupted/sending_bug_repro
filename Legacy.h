#import <Foundation/Foundation.h>

@class Payload;

// --- Payload ---

@interface Payload : NSObject
@property (nonatomic, copy) NSString *name;
@end

// --- Handler protocol ---

NS_SWIFT_SENDABLE
@protocol Handler <NSObject>
- (void)handle:(NS_SWIFT_SENDING Payload *)value;
@end

// --- LegacyObjCHandler (a pure-ObjC Handler — does NOT trigger the bug) ---

@interface LegacyObjCHandler : NSObject <Handler>
@end
