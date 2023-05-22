#ifndef OSActivityEvent_h
#define OSActivityEvent_h

#include <sys/time.h>
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface OSActivityEvent : NSObject

@property (readonly, nonatomic) NSUInteger activityID;
@property (copy, nonatomic) NSString *eventMessage;
@property (readonly, nonatomic) NSUInteger eventType;
@property (readonly, nonatomic) NSUInteger machTimestamp;
@property (readonly, nonatomic) NSUInteger parentActivityID;
@property (readonly, nonatomic) BOOL persisted;
@property (readonly, copy, nonatomic) NSString *process;
@property (readonly, nonatomic) int processID;
@property (readonly, copy, nonatomic) NSString *processImagePath;
@property (readonly, copy, nonatomic) NSUUID *processImageUUID;
@property (readonly, nonatomic) NSUInteger processUniqueID;
@property (readonly, copy, nonatomic) NSString *sender;
@property (readonly, copy, nonatomic) NSString *senderImagePath;
@property (readonly, copy, nonatomic) NSUUID *senderImageUUID;
@property (readonly, nonatomic) NSUInteger threadID;
@property (readonly, nonatomic) struct timeval timeGMT;
@property (readonly, copy, nonatomic) NSDate *timestamp;
@property (readonly, copy, nonatomic) NSTimeZone *timezone;
@property (retain, nonatomic) NSString *timezoneName;
@property (readonly, nonatomic) NSUInteger traceID;
@property (readonly, nonatomic) struct timezone tz;

-(BOOL)persisted;
-(id)description;
-(id)properties;
-(void)_addProperties:(id)arg0 ;
-(id)_initWithProperties:(id)arg0;

@end

NS_ASSUME_NONNULL_END


@interface OSActivityLogMessageEvent : OSActivityEvent

@property (readonly, copy, nonatomic) NSString * _Nullable category;
@property (readonly, nonatomic) unsigned char messageType;
@property (readonly, nonatomic) NSUInteger senderProgramCounter;
@property (readonly, copy, nonatomic) NSString * _Nullable subsystem;

-(instancetype _Nonnull)initWithEntry:(struct os_activity_stream_entry_s * _Nonnull)arg0 ;

@end


#endif /* OSActivityEvent_h */
